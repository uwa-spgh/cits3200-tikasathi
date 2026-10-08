import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/reminders/reminder_message.dart';
import 'package:tikasathi/core/reminders/reminder_schedule.dart';
import 'package:tikasathi/core/services/notification_service.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';
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
  StreamSubscription<void>? _facilitySubscription;

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

  /// Registers reminders now, and again whenever the table changes or the
  /// saved health facility does.
  void start() {
    _subscription ??= _database.remindersDao
        .watchPendingReminders(limit: registrationLimit)
        .asyncMap(sync)
        .listen(null, onError: _reportFailure);

    // The first value is the facility as it stands, which the reminders
    // stream above has already registered with, so only changes matter.
    _facilitySubscription ??= _database.healthFacilitatorsDao
        .watchLocalFacilitator()
        .skip(1)
        .asyncMap((_) => refresh())
        .listen(null, onError: _reportFailure);
  }

  /// Registers the queued window again with up-to-date wording.
  ///
  /// The device keeps the text a reminder was registered with. Changing the
  /// language or the saved facility writes nothing to the reminders table, so
  /// without this the old wording would stay until the app next opened.
  Future<void> refresh() async {
    await sync(
      await _database.remindersDao.getPendingReminders(
        limit: registrationLimit,
      ),
    );
  }

  void _reportFailure(Object error) {
    debugPrint('reminder scheduling failed: $error');
  }

  /// Raises reminders whose time passed without the device delivering them.
  ///
  /// Covers the app being closed, the phone being off, or the clock jumping
  /// forward. Only one per child is raised: a dose overdue for months leaves
  /// a long trail of reminders, and raising all of them would bury the
  /// caregiver under notifications for one missed dose. The one raised is the
  /// most urgent (see [_outranks]), so an overdue dose is never hidden behind
  /// a routine reminder for another. The rest are still settled so they never
  /// reappear.
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

    final Map<String, Reminder> chosenPerChild = <String, Reminder>{};
    for (final Reminder reminder in unseen) {
      final Reminder? held = chosenPerChild[reminder.childId];
      if (held == null || _outranks(reminder, held)) {
        chosenPerChild[reminder.childId] = reminder;
      }
    }

    final List<String> childIds = chosenPerChild.keys.toList()..sort();
    for (int index = 0; index < childIds.length; index++) {
      final ReminderMessage? message =
          await _messageFor(chosenPerChild[childIds[index]]!);
      if (message == null) {
        continue;
      }
      await _notifications.showNotificationNow(
        notificationId: missedNotificationId(index),
        title: message.title,
        body: message.body,
      );
    }

    await _database.remindersDao.markRemindersDelivered(
      missed.map((Reminder reminder) => reminder.id).toList(),
      deliveredAt: now,
    );
  }

  /// Whether [candidate] is the better single reminder to raise for a child.
  ///
  /// The more urgent kind wins, and between equally urgent ones the later.
  /// Recency alone let a routine "due next week" reminder for one dose hide an
  /// overdue warning for another when both fell on the same morning.
  static bool _outranks(Reminder candidate, Reminder held) {
    final int byUrgency =
        _urgency(candidate.kind).compareTo(_urgency(held.kind));
    if (byUrgency != 0) {
      return byUrgency > 0;
    }
    return candidate.scheduledFor.isAfter(held.scheduledFor);
  }

  static int _urgency(ReminderKind kind) {
    return switch (kind) {
      ReminderKind.advance => 0,
      ReminderKind.preparation => 1,
      ReminderKind.sameDay => 2,
      ReminderKind.followUpDay => 3,
      ReminderKind.followUpWeek => 4,
      ReminderKind.overdueRecurring => 5,
    };
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    await _facilitySubscription?.cancel();
    _subscription = null;
    _facilitySubscription = null;
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
  final ReminderScheduler scheduler = ReminderScheduler(
    ref.watch(appDatabaseProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(settingsRepositoryProvider),
  );

  // The language is saved before the controller announces it, so by the time
  // this runs the new language is what the reminders will be built in.
  ref.listen<AsyncValue<AppLanguage>>(languageControllerProvider, (
    AsyncValue<AppLanguage>? previous,
    AsyncValue<AppLanguage> next,
  ) {
    final AppLanguage? before = previous?.valueOrNull;
    final AppLanguage? after = next.valueOrNull;
    if (before != null && after != null && before != after) {
      scheduler.refresh().catchError(scheduler._reportFailure);
    }
  });

  return scheduler;
}
