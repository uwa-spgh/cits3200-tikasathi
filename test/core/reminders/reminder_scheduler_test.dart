import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/reminders/reminder_scheduler.dart';
import 'package:tikasathi/core/reminders/reminder_schedule.dart';
import 'package:tikasathi/core/services/notification_service.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';
import 'package:tikasathi/features/settings/domain/settings_repository.dart';

class _MockNotificationService extends Mock implements NotificationService {}

class _FakeSettingsRepository implements SettingsRepository {
  AppLanguage language = AppLanguage.english;

  @override
  Future<AppLanguage> getLanguage() async => language;

  @override
  Future<void> setLanguage(AppLanguage language) async {
    this.language = language;
  }
}

void main() {
  group('ReminderScheduler.sync', () {
    late AppDatabase database;
    late _MockNotificationService notifications;
    late _FakeSettingsRepository settings;
    late ReminderScheduler scheduler;

    final DateTime now = DateTime.now();

    tearDown(() async {
      await database.close();
    });

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      notifications = _MockNotificationService();
      settings = _FakeSettingsRepository();
      scheduler = ReminderScheduler(database, notifications, settings);

      // The scheduler names the child and the vaccine, so the rows a reminder
      // points at have to exist.
      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'child-1',
          name: 'Aarav',
          dateOfBirth: DateTime(2026, 7, 26),
          sex: 'male',
        ),
      );
      await database.vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'due-1',
          childId: 'child-1',
          vaccineCode: 'BCG',
          doseNumber: 1,
          dueDate: DateTime(2026, 10, 4),
        ),
      );
      when(() => notifications.registeredNotificationIds())
          .thenAnswer((_) async => <int>{});
      when(() => notifications.cancelReminder(any())).thenAnswer((_) async {});
      when(
        () => notifications.scheduleReminder(
          notificationId: any(named: 'notificationId'),
          when: any(named: 'when'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          childId: any(named: 'childId'),
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
          childId: any(named: 'childId'),
        ),
      ).called(1);
    });

    // The plugin's pending list survives Android dropping the real alarms on
    // force-stop or reboot, so a reminder it claims to hold is registered again
    // rather than skipped.
    test('registers reminders again even when the plugin claims to hold them',
        () async {
      when(() => notifications.registeredNotificationIds())
          .thenAnswer((_) async => <int>{7});

      await scheduler.sync([
        reminder(
          notificationId: 7,
          scheduledFor: now.add(const Duration(days: 1)),
        ),
      ]);

      verify(
        () => notifications.scheduleReminder(
          notificationId: 7,
          when: any(named: 'when'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          childId: any(named: 'childId'),
        ),
      ).called(1);
      verifyNever(() => notifications.cancelReminder(any()));
    });

    test('names the saved health facility in the reminder', () async {
      await database.healthFacilitatorsDao.saveLocalFacilitator(
        name: 'Bhaktapur Health Post',
        address: 'Ward 4',
        phone: '9812345678',
      );

      await scheduler.sync([
        reminder(
          notificationId: 7,
          scheduledFor: now.add(const Duration(days: 1)),
        ),
      ]);

      final String body = verify(
        () => notifications.scheduleReminder(
          notificationId: 7,
          when: any(named: 'when'),
          title: any(named: 'title'),
          body: captureAny(named: 'body'),
          childId: any(named: 'childId'),
        ),
      ).captured.single as String;
      expect(
        body,
        endsWith(
          'Your saved health facility: '
          'Bhaktapur Health Post, Ward 4, 9812345678.',
        ),
      );
    });

    test("carries each reminder's child so a tap can open it", () async {
      await scheduler.sync([
        reminder(
          notificationId: 7,
          scheduledFor: now.add(const Duration(days: 1)),
        ),
      ]);

      verify(
        () => notifications.scheduleReminder(
          notificationId: 7,
          when: any(named: 'when'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          childId: 'child-1',
        ),
      ).called(1);
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

    group('registration bookkeeping', () {
      Future<Reminder> storedReminder() async {
        return database.remindersDao.insertReminderAt(
          dueId: 'due-1',
          scheduledFor: now.add(const Duration(days: 1)),
        );
      }

      Future<Reminder> reload(Reminder reminder) {
        return (database.select(database.reminders)
              ..where((row) => row.id.equals(reminder.id)))
            .getSingle();
      }

      test('records the reminders it queues with the device', () async {
        final Reminder stored = await storedReminder();
        expect(stored.registeredAt, isNull);

        await scheduler.sync(<Reminder>[stored]);

        expect((await reload(stored)).registeredAt, isNotNull);
      });

      test('forgets a registration it takes off the queue', () async {
        final Reminder stored = await storedReminder();
        await database.remindersDao
            .markRemindersRegistered(<int>[stored.notificationId]);
        when(() => notifications.registeredNotificationIds())
            .thenAnswer((_) async => <int>{stored.notificationId});

        // Nothing is wanted any more, so the device's copy is cancelled.
        await scheduler.sync(<Reminder>[]);

        verify(() => notifications.cancelReminder(stored.notificationId))
            .called(1);
        expect((await reload(stored)).registeredAt, isNull);
      });
    });

    group('refreshing wording', () {
      Future<Reminder> queuedReminder() {
        return database.remindersDao.insertReminderAt(
          dueId: 'due-1',
          scheduledFor: now.add(const Duration(days: 1)),
        );
      }

      Future<String> lastScheduledBody(int notificationId) async {
        return verify(
          () => notifications.scheduleReminder(
            notificationId: notificationId,
            when: any(named: 'when'),
            title: any(named: 'title'),
            body: captureAny(named: 'body'),
          ),
        ).captured.last as String;
      }

      // The device keeps the text a reminder was queued with, so a new
      // language only reaches it if the reminder is registered again.
      test('re-registers queued reminders in the current language', () async {
        final Reminder queued = await queuedReminder();

        await scheduler.refresh();
        expect(await lastScheduledBody(queued.notificationId),
            contains('vaccination day'));

        settings.language = AppLanguage.nepali;
        await scheduler.refresh();
        expect(
            await lastScheduledBody(queued.notificationId), contains('खुराक'));
      });

      test('re-registers when the saved facility changes', () async {
        final Reminder queued = await queuedReminder();
        scheduler.start();
        await pumpEventQueue();

        await database.healthFacilitatorsDao.saveLocalFacilitator(
          name: 'Bhaktapur Health Post',
          address: 'Ward 4',
          phone: '9812345678',
        );
        await pumpEventQueue();
        await scheduler.stop();

        expect(await lastScheduledBody(queued.notificationId),
            contains('Bhaktapur Health Post'));
      });

      test('re-registers when the caregiver switches language', () async {
        final Reminder queued = await queuedReminder();
        final ProviderContainer container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            notificationServiceProvider.overrideWithValue(notifications),
            settingsRepositoryProvider.overrideWithValue(settings),
          ],
        );
        addTearDown(container.dispose);
        container.read(reminderSchedulerProvider);
        await container.read(languageControllerProvider.future);

        await container
            .read(languageControllerProvider.notifier)
            .setLanguage(AppLanguage.nepali);
        await pumpEventQueue();

        expect(
            await lastScheduledBody(queued.notificationId), contains('खुराक'));
      });
    });

    group('catchUpMissed', () {
      final DateTime pastDue = DateTime(2024, 6, 20);
      final DateTime wellBefore = DateTime(2024, 1, 1);

      setUp(() {
        when(
          () => notifications.showNotificationNow(
            notificationId: any(named: 'notificationId'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            childId: any(named: 'childId'),
          ),
        ).thenAnswer((_) async {});
      });

      Future<void> seedMissedReminders(String childId) async {
        await database.childProfilesDao.insertChildProfile(
          ChildProfilesCompanion.insert(
            id: childId,
            name: 'Aarav',
            dateOfBirth: DateTime(2023, 4, 15),
            sex: 'male',
          ),
        );
        await database.vaccinationDuesDao.insertVaccinationDue(
          VaccinationDuesCompanion.insert(
            id: 'due-$childId',
            childId: childId,
            vaccineCode: 'BCG',
            doseNumber: 1,
            dueDate: pastDue,
          ),
        );
        await database.remindersDao
            .scheduleRemindersForChild(childId, from: wellBefore);
      }

      test('raises one notification per child and settles the rest', () async {
        await seedMissedReminders('missed-1');
        final List<Reminder> before =
            await database.remindersDao.getPendingReminders();
        expect(before.length, greaterThan(1));

        await scheduler.catchUpMissed();

        verify(
          () => notifications.showNotificationNow(
            notificationId: any(named: 'notificationId'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            childId: any(named: 'childId'),
          ),
        ).called(1);
        expect(await database.remindersDao.getPendingReminders(), isEmpty);
      });

      // Reminder ids are cancelled the moment their row is settled, which would
      // dismiss the notification we just raised.
      test('raises missed notifications outside the reminder id range',
          () async {
        await seedMissedReminders('missed-1');

        await scheduler.catchUpMissed();

        verify(
          () => notifications.showNotificationNow(
            notificationId: ReminderScheduler.missedNotificationId(0),
            title: any(named: 'title'),
            body: any(named: 'body'),
            childId: any(named: 'childId'),
          ),
        ).called(1);
        expect(
          ReminderScheduler.missedNotificationId(0),
          greaterThanOrEqualTo(NotificationService.oneOffIdFloor),
        );
      });

      test('covers each child separately', () async {
        await seedMissedReminders('missed-1');
        await seedMissedReminders('missed-2');

        await scheduler.catchUpMissed();

        verify(
          () => notifications.showNotificationNow(
            notificationId: any(named: 'notificationId'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            childId: any(named: 'childId'),
          ),
        ).called(2);
      });

      Future<void> markAllRegistered() async {
        final List<Reminder> pending =
            await database.remindersDao.getPendingReminders();
        await database.remindersDao.markRemindersRegistered(
          pending.map((Reminder reminder) => reminder.notificationId).toList(),
        );
      }

      // The device drops a reminder from its queue once it shows it, so a
      // queued reminder that has left the queue was already seen.
      test('does not raise again what the device already showed', () async {
        await seedMissedReminders('missed-1');
        await markAllRegistered();
        when(() => notifications.registeredNotificationIds())
            .thenAnswer((_) async => <int>{});

        await scheduler.catchUpMissed();

        verifyNever(
          () => notifications.showNotificationNow(
            notificationId: any(named: 'notificationId'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            childId: any(named: 'childId'),
          ),
        );
        expect(await database.remindersDao.getPendingReminders(), isEmpty);
      });

      // A force-stop cancels the alarm but leaves the plugin's queue intact.
      test('raises a queued reminder the device never got to show', () async {
        await seedMissedReminders('missed-1');
        await markAllRegistered();
        final List<Reminder> pending =
            await database.remindersDao.getPendingReminders();
        when(() => notifications.registeredNotificationIds()).thenAnswer(
          (_) async => pending
              .map((Reminder reminder) => reminder.notificationId)
              .toSet(),
        );

        await scheduler.catchUpMissed();

        verify(
          () => notifications.showNotificationNow(
            notificationId: any(named: 'notificationId'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            childId: any(named: 'childId'),
          ),
        ).called(1);
      });

      test('raises reminders the device was never given', () async {
        await seedMissedReminders('missed-1');

        await scheduler.catchUpMissed();

        verify(
          () => notifications.showNotificationNow(
            notificationId: any(named: 'notificationId'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            childId: any(named: 'childId'),
          ),
        ).called(1);
      });

      test('carries the child with a caught-up reminder', () async {
        await seedMissedReminders('missed-1');

        await scheduler.catchUpMissed();

        verify(
          () => notifications.showNotificationNow(
            notificationId: any(named: 'notificationId'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            childId: 'missed-1',
          ),
        ).called(1);
      });

      group('choosing which reminder to raise', () {
        // The morning a dose became overdue was also the week-before reminder
        // for the next doses; the routine one used to win and hide the warning.
        final DateTime sameMorning = DateTime(2026, 11, 5, 9);

        Future<void> seedTwoDues() async {
          await database.childProfilesDao.insertChildProfile(
            ChildProfilesCompanion.insert(
              id: 'tie-child',
              name: 'Aarav',
              dateOfBirth: DateTime(2026, 9, 3),
              sex: 'male',
            ),
          );
          await database.vaccinationDuesDao.insertVaccinationDue(
            VaccinationDuesCompanion.insert(
              id: 'penta-1',
              childId: 'tie-child',
              vaccineCode: 'PENTA',
              doseNumber: 1,
              dueDate: DateTime(2026, 10, 15),
            ),
          );
          await database.vaccinationDuesDao.insertVaccinationDue(
            VaccinationDuesCompanion.insert(
              id: 'bopv-2',
              childId: 'tie-child',
              vaccineCode: 'BOPV',
              doseNumber: 2,
              dueDate: DateTime(2026, 11, 12),
            ),
          );
        }

        Future<String> raisedBody() async {
          return verify(
            () => notifications.showNotificationNow(
              notificationId: any(named: 'notificationId'),
              title: any(named: 'title'),
              body: captureAny(named: 'body'),
            ),
          ).captured.single as String;
        }

        test('an overdue dose beats a routine reminder the same morning',
            () async {
          await seedTwoDues();
          await database.remindersDao.insertReminderAt(
            dueId: 'bopv-2',
            scheduledFor: sameMorning,
            kind: ReminderKind.advance,
          );
          await database.remindersDao.insertReminderAt(
            dueId: 'penta-1',
            scheduledFor: sameMorning,
            kind: ReminderKind.overdueRecurring,
          );

          await scheduler.catchUpMissed(asOf: DateTime(2026, 11, 6, 19));

          expect(await raisedBody(), startsWith('PENTA (Dose 1) is overdue.'));
        });

        test('an overdue dose beats a later routine reminder', () async {
          await seedTwoDues();
          await database.remindersDao.insertReminderAt(
            dueId: 'penta-1',
            scheduledFor: sameMorning,
            kind: ReminderKind.overdueRecurring,
          );
          await database.remindersDao.insertReminderAt(
            dueId: 'bopv-2',
            scheduledFor: DateTime(2026, 11, 11, 9),
            kind: ReminderKind.preparation,
          );

          await scheduler.catchUpMissed(asOf: DateTime(2026, 11, 11, 19));

          expect(await raisedBody(), startsWith('PENTA (Dose 1) is overdue.'));
        });

        test('between equally urgent reminders the later wins', () async {
          await seedTwoDues();
          await database.remindersDao.insertReminderAt(
            dueId: 'penta-1',
            scheduledFor: DateTime(2026, 10, 14, 9),
            kind: ReminderKind.preparation,
          );
          await database.remindersDao.insertReminderAt(
            dueId: 'bopv-2',
            scheduledFor: DateTime(2026, 11, 11, 9),
            kind: ReminderKind.preparation,
          );

          await scheduler.catchUpMissed(asOf: DateTime(2026, 11, 11, 19));

          expect(await raisedBody(), contains('BOPV (Dose 2)'));
        });

        test('still settles every missed reminder, not just the one raised',
            () async {
          await seedTwoDues();
          await database.remindersDao.insertReminderAt(
            dueId: 'bopv-2',
            scheduledFor: sameMorning,
            kind: ReminderKind.advance,
          );
          await database.remindersDao.insertReminderAt(
            dueId: 'penta-1',
            scheduledFor: sameMorning,
            kind: ReminderKind.overdueRecurring,
          );

          await scheduler.catchUpMissed(asOf: DateTime(2026, 11, 6, 19));

          expect(
            await database.remindersDao
                .getPendingRemindersDueBy(DateTime(2026, 11, 6, 19)),
            isEmpty,
          );
        });
      });

      test('does nothing when no reminder was missed', () async {
        await scheduler.catchUpMissed();

        verifyNever(
          () => notifications.showNotificationNow(
            notificationId: any(named: 'notificationId'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            childId: any(named: 'childId'),
          ),
        );
      });

      test('leaves reminders that are still in the future pending', () async {
        await seedMissedReminders('missed-1');

        await scheduler.catchUpMissed(asOf: DateTime(2024, 6, 14));

        final List<Reminder> stillPending =
            await database.remindersDao.getPendingReminders();
        expect(stillPending, isNotEmpty);
        expect(
          stillPending.every(
            (Reminder reminder) =>
                reminder.scheduledFor.isAfter(DateTime(2024, 6, 14)),
          ),
          isTrue,
        );
      });
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
          childId: any(named: 'childId'),
        ),
      );
    });
  });
}
