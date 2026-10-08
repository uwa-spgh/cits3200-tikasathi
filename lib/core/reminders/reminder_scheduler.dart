import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/reminders/reminder_message.dart';
import 'package:tikasathi/core/services/notification_service.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/settings_repository.dart';

part 'reminder_scheduler.g.dart';

/// Keeps the device's scheduled notifications in step with the reminders table.
///
/// The table is the source of truth. Only a window of it is registered with the
/// device, because iOS holds at most 64 pending local notifications.
class ReminderScheduler {
  ReminderScheduler(this._database, this._notifications, this._settings);

  static const int registrationLimit = 60;

  /// The id a missed-dose notification is raised under, for the [index]th child.
  ///
  /// Deliberately not the reminder's own id. Settling a reminder makes it
  /// unwanted, so the next reconcile cancels that id — and cancelling dismisses
  /// a notification already on screen, not just a scheduled one. Sitting in the
  /// one-off band keeps these clear of reconciliation entirely.
  static int missedNotificationId(int index) =>
      NotificationService.oneOffIdFloor + 100 + index;

  final AppDatabase _database;
  final NotificationService _notifications;
  final SettingsRepository _settings;

  StreamSubscription<void>? _subscription;

  /// The wording for [reminder], in the caregiver's chosen language.
  ///
  /// Returns null when the child or the due has gone; the foreign keys make
  /// that impossible in practice, but a reminder with nothing to name is not
  /// worth raising.
  Future<ReminderMessage?> _messageFor(Reminder reminder) async {
    await ensureReminderDateFormatting();
    final AppLanguage language = await _settings.getLanguage();
    final AppLocalizations localizations =
        lookupAppLocalizations(language.locale);

    final ChildProfile? child = await (_database.select(_database.childProfiles)
          ..where((row) => row.id.equals(reminder.childId)))
        .getSingleOrNull();
    final VaccinationDue? due =
        await (_database.select(_database.vaccinationDues)
              ..where((row) => row.id.equals(reminder.dueId)))
            .getSingleOrNull();
    if (child == null || due == null) {
      return null;
    }
    final HealthFacilitator? facility =
        await _database.healthFacilitatorsDao.getLocalFacilitator();

    return buildReminderMessage(
      localizations: localizations,
      languageCode: language.code,
      childName: child.name,
      vaccineCode: due.vaccineCode,
      doseNumber: due.doseNumber,
      dueDate: due.dueDate,
      kind: reminder.kind,
      facility: describeFacility(
        name: facility?.name,
        address: facility?.address,
        phone: facility?.phone,
      ),
    );
  }

  /// Registers reminders now, and again whenever the table changes.
  void start() {
    _subscription ??= _database.remindersDao
        .watchPendingReminders(limit: registrationLimit)
        .asyncMap(sync)
        .listen(
      null,
      onError: (Object error) {
        debugPrint('reminder scheduling failed: $error');
      },
    );
  }

  /// Raises reminders whose time passed without the device delivering them.
  ///
  /// Covers the app being closed, the phone being off, or the clock jumping
  /// forward. Only the most recent per child is raised: a dose overdue for
  /// months leaves a long trail of reminders, and raising all of them would
  /// bury the caregiver under notifications for one missed dose. The rest are
  /// still settled so they never reappear.
  ///
  /// Reminders the device already showed are settled without being raised
  /// again: one that was queued with the device and has since left its queue
  /// was shown, because the device only drops a reminder once it fires. One
  /// still in the queue was never shown, for instance after a force-stop
  /// cancelled the alarm.
  Future<void> catchUpMissed({DateTime? asOf}) async {
    final DateTime now = asOf ?? DateTime.now();
    final List<Reminder> missed =
        await _database.remindersDao.getPendingRemindersDueBy(now);
    if (missed.isEmpty) {
      return;
    }

    final Set<int> stillQueued =
        await _notifications.registeredNotificationIds();
    final Iterable<Reminder> unseen = missed.where(
      (Reminder reminder) =>
          reminder.registeredAt == null ||
          stillQueued.contains(reminder.notificationId),
    );

    final Map<String, Reminder> latestPerChild = <String, Reminder>{};
    for (final Reminder reminder in unseen) {
      final Reminder? held = latestPerChild[reminder.childId];
      if (held == null || reminder.scheduledFor.isAfter(held.scheduledFor)) {
        latestPerChild[reminder.childId] = reminder;
      }
    }

    final List<String> childIds = latestPerChild.keys.toList()..sort();
    for (int index = 0; index < childIds.length; index++) {
      final ReminderMessage? message =
          await _messageFor(latestPerChild[childIds[index]]!);
      if (message == null) {
        continue;
      }
      await _notifications.showNotificationNow(
        notificationId: missedNotificationId(index),
        title: message.title,
        body: message.body,
        childId: childIds[index],
      );
    }

    await _database.remindersDao.markRemindersDelivered(
      missed.map((Reminder reminder) => reminder.id).toList(),
      deliveredAt: now,
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Makes the device's schedule match [pending].
  ///
  /// Reminders already past are left alone: the device would raise them the
  /// moment they were registered, so catching those up is handled separately.
  Future<void> sync(List<Reminder> pending) async {
    final DateTime now = DateTime.now();
    final Map<int, Reminder> wanted = <int, Reminder>{
      for (final Reminder reminder in pending)
        if (reminder.scheduledFor.isAfter(now))
          reminder.notificationId: reminder,
    };

    final Set<int> registered =
        (await _notifications.registeredNotificationIds())
            .where((int id) => id < NotificationService.oneOffIdFloor)
            .toSet();

    final List<int> cancelled =
        registered.difference(wanted.keys.toSet()).toList();
    for (final int notificationId in cancelled) {
      await _notifications.cancelReminder(notificationId);
    }
    // Taken off the queue before the device could show them, so the catch-up
    // must still treat them as unseen.
    await _database.remindersDao.clearRemindersRegistered(cancelled);

    // Every wanted reminder is registered again rather than assumed present.
    // The plugin's pending list is its own bookkeeping, and Android drops the
    // real alarms on force-stop or reboot without telling it, so trusting the
    // list leaves the app believing it is scheduled when nothing is queued.
    // Scheduling an id that already exists replaces it, so this is idempotent.
    for (final Reminder reminder in wanted.values) {
      final ReminderMessage? message = await _messageFor(reminder);
      if (message == null) {
        continue;
      }
      await _notifications.scheduleReminder(
        notificationId: reminder.notificationId,
        when: reminder.scheduledFor,
        title: message.title,
        body: message.body,
        childId: reminder.childId,
      );
    }

    await _database.remindersDao.markRemindersRegistered(
      wanted.keys.toList(),
      registeredAt: now,
    );
  }
}

@Riverpod(keepAlive: true)
ReminderScheduler reminderScheduler(ReminderSchedulerRef ref) {
  return ReminderScheduler(
    ref.watch(appDatabaseProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(settingsRepositoryProvider),
  );
}
