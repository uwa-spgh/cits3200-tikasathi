import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/services/notification_service.dart';

part 'reminder_scheduler.g.dart';

/// Keeps the device's scheduled notifications in step with the reminders table.
///
/// The table is the source of truth. Only a window of it is registered with the
/// device, because iOS holds at most 64 pending local notifications.
class ReminderScheduler {
  ReminderScheduler(this._database, this._notifications);

  static const int registrationLimit = 60;

  final AppDatabase _database;
  final NotificationService _notifications;

  StreamSubscription<void>? _subscription;

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

    for (final int notificationId
        in registered.difference(wanted.keys.toSet())) {
      await _notifications.cancelReminder(notificationId);
    }

    for (final Reminder reminder in wanted.values) {
      if (registered.contains(reminder.notificationId)) {
        continue;
      }
      await _notifications.scheduleReminder(
        notificationId: reminder.notificationId,
        when: reminder.scheduledFor,
        title: reminderTitle,
        body: reminderBody,
      );
    }
  }
}

// Placeholder wording: naming the vaccine and translating it comes later.
const String reminderTitle = 'Vaccination reminder';
const String reminderBody = 'Your child has a vaccination due.';

@Riverpod(keepAlive: true)
ReminderScheduler reminderScheduler(ReminderSchedulerRef ref) {
  return ReminderScheduler(
    ref.watch(appDatabaseProvider),
    ref.watch(notificationServiceProvider),
  );
}
