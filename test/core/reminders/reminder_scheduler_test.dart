import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/reminders/reminder_scheduler.dart';
import 'package:tikasathi/core/reminders/reminder_schedule.dart';
import 'package:tikasathi/core/services/notification_service.dart';

class _MockNotificationService extends Mock implements NotificationService {}

void main() {
  group('ReminderScheduler.sync', () {
    late AppDatabase database;
    late _MockNotificationService notifications;
    late ReminderScheduler scheduler;

    final DateTime now = DateTime.now();

    tearDown(() async {
      await database.close();
    });

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      notifications = _MockNotificationService();
      scheduler = ReminderScheduler(database, notifications);
      when(() => notifications.registeredNotificationIds())
          .thenAnswer((_) async => <int>{});
      when(() => notifications.cancelReminder(any())).thenAnswer((_) async {});
      when(
        () => notifications.scheduleReminder(
          notificationId: any(named: 'notificationId'),
          when: any(named: 'when'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {});
    });

    Reminder reminder({
      required int notificationId,
      required DateTime scheduledFor,
    }) {
      return Reminder(
        id: 'reminder-$notificationId',
        childId: 'child-1',
        dueId: 'due-1',
        kind: ReminderKind.advance,
        scheduledFor: scheduledFor,
        notificationId: notificationId,
      );
    }

    test('registers reminders the device does not hold yet', () async {
      final DateTime soon = now.add(const Duration(days: 1));

      await scheduler.sync([reminder(notificationId: 7, scheduledFor: soon)]);

      verify(
        () => notifications.scheduleReminder(
          notificationId: 7,
          when: soon,
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).called(1);
    });

    test('leaves reminders the device already holds alone', () async {
      when(() => notifications.registeredNotificationIds())
          .thenAnswer((_) async => <int>{7});

      await scheduler.sync([
        reminder(
          notificationId: 7,
          scheduledFor: now.add(const Duration(days: 1)),
        ),
      ]);

      verifyNever(
        () => notifications.scheduleReminder(
          notificationId: any(named: 'notificationId'),
          when: any(named: 'when'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      );
      verifyNever(() => notifications.cancelReminder(any()));
    });

    test('cancels registrations that are no longer wanted', () async {
      when(() => notifications.registeredNotificationIds())
          .thenAnswer((_) async => <int>{7, 8});

      await scheduler.sync([
        reminder(
          notificationId: 7,
          scheduledFor: now.add(const Duration(days: 1)),
        ),
      ]);

      verify(() => notifications.cancelReminder(8)).called(1);
      verifyNever(() => notifications.cancelReminder(7));
    });

    test('leaves one-off notifications registered', () async {
      when(() => notifications.registeredNotificationIds()).thenAnswer(
        (_) async => <int>{NotificationService.oneOffIdFloor + 1},
      );

      await scheduler.sync([
        reminder(
          notificationId: 7,
          scheduledFor: now.add(const Duration(days: 1)),
        ),
      ]);

      verifyNever(() => notifications.cancelReminder(any()));
    });

    test('skips reminders whose time has already passed', () async {
      await scheduler.sync([
        reminder(
          notificationId: 7,
          scheduledFor: now.subtract(const Duration(days: 1)),
        ),
      ]);

      verifyNever(
        () => notifications.scheduleReminder(
          notificationId: any(named: 'notificationId'),
          when: any(named: 'when'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      );
    });
  });
}
