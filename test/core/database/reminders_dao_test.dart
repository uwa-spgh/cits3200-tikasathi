import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/reminders/reminder_schedule.dart';

void main() {
  group('RemindersDao', () {
    late AppDatabase database;
    late ChildProfilesDao childProfilesDao;
    late VaccinationDuesDao vaccinationDuesDao;
    late RemindersDao remindersDao;

    final DateTime dueDate = DateTime(2024, 6, 20);
    final DateTime wellBefore = DateTime(2024, 1, 1);

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      childProfilesDao = database.childProfilesDao;
      vaccinationDuesDao = database.vaccinationDuesDao;
      remindersDao = database.remindersDao;
    });

    tearDown(() async {
      await database.close();
    });

    Future<void> insertChild(String id) {
      return childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: id,
          name: 'Aarav',
          dateOfBirth: DateTime(2023, 4, 15),
          sex: 'male',
        ),
      );
    }

    Future<void> insertDue({
      required String id,
      required String childId,
      String vaccineCode = 'BCG',
      int doseNumber = 1,
      DateTime? date,
    }) {
      return vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: id,
          childId: childId,
          vaccineCode: vaccineCode,
          doseNumber: doseNumber,
          dueDate: date ?? dueDate,
        ),
      );
    }

    Future<void> insertChildWithDue({
      String childId = 'child-1',
      String dueId = 'due-1',
      String vaccineCode = 'BCG',
      int doseNumber = 1,
      DateTime? date,
    }) async {
      await insertChild(childId);
      await insertDue(
        id: dueId,
        childId: childId,
        vaccineCode: vaccineCode,
        doseNumber: doseNumber,
        date: date,
      );
    }

    test('schedules the planned reminders for a due', () async {
      await insertChildWithDue();

      final scheduled = await remindersDao.scheduleRemindersForDue(
        'due-1',
        from: wellBefore,
      );
      final expected = planReminders(dueDate, from: wellBefore);

      expect(
        scheduled.map((reminder) => reminder.scheduledFor),
        expected.map((reminder) => reminder.scheduledFor),
      );
      expect(
        scheduled.map((reminder) => reminder.kind),
        expected.map((reminder) => reminder.kind),
      );
      expect(
        scheduled.every((reminder) => reminder.childId == 'child-1'),
        isTrue,
      );
      expect(scheduled.every((reminder) => reminder.dueId == 'due-1'), isTrue);
      expect(
        scheduled.every((reminder) => reminder.deliveredAt == null),
        isTrue,
      );
    });

    test('gives every reminder a distinct notification id', () async {
      await insertChildWithDue();
      await insertChildWithDue(
        childId: 'child-2',
        dueId: 'due-2',
        vaccineCode: 'MR',
      );

      await remindersDao.scheduleRemindersForDue('due-1', from: wellBefore);
      await remindersDao.scheduleRemindersForDue('due-2', from: wellBefore);

      final all = await remindersDao.getPendingReminders();
      final ids = all.map((reminder) => reminder.notificationId).toSet();

      expect(all, isNotEmpty);
      expect(ids, hasLength(all.length));
    });

    test('replaces reminders when a due is rescheduled', () async {
      await insertChildWithDue();
      await remindersDao.scheduleRemindersForDue('due-1', from: wellBefore);

      final rescheduled = await remindersDao.scheduleRemindersForDue(
        'due-1',
        from: DateTime(2024, 6, 19, 12),
      );

      final all = await remindersDao.getPendingReminders();
      expect(all, hasLength(rescheduled.length));
      expect(rescheduled.first.kind, ReminderKind.sameDay);
    });

    test('rejects scheduling for a due that does not exist', () async {
      expect(
        () => remindersDao.scheduleRemindersForDue('missing-due'),
        throwsA(isA<Exception>()),
      );
    });

    test('leaves no reminders when every reminder has passed', () async {
      await insertChildWithDue();

      final scheduled = await remindersDao.scheduleRemindersForDue(
        'due-1',
        from: DateTime(2026, 1, 1),
      );

      expect(scheduled, isEmpty);
      expect(await remindersDao.getPendingReminders(), isEmpty);
    });

    test('returns pending reminders that are due by an instant', () async {
      await insertChildWithDue();
      await remindersDao.scheduleRemindersForDue('due-1', from: wellBefore);

      final raisedByNow = await remindersDao.getPendingRemindersDueBy(
        DateTime(2024, 6, 21, 12),
      );

      expect(
        raisedByNow.map((reminder) => reminder.kind),
        [
          ReminderKind.advance,
          ReminderKind.preparation,
          ReminderKind.sameDay,
          ReminderKind.followUpDay,
        ],
      );
    });

    test('excludes delivered reminders from pending queries', () async {
      await insertChildWithDue();
      final scheduled = await remindersDao.scheduleRemindersForDue(
        'due-1',
        from: wellBefore,
      );

      await remindersDao.markReminderDelivered(
        scheduled.first.id,
        deliveredAt: DateTime(2024, 6, 13, 9),
      );

      final pending = await remindersDao.getPendingReminders();

      expect(
        pending.map((reminder) => reminder.id),
        isNot(contains(scheduled.first.id)),
      );
      expect(pending, hasLength(scheduled.length - 1));
    });

    test('records when a reminder was delivered', () async {
      await insertChildWithDue();
      final scheduled = await remindersDao.scheduleRemindersForDue(
        'due-1',
        from: wellBefore,
      );
      final deliveredAt = DateTime(2024, 6, 13, 9, 5);

      await remindersDao.markReminderDelivered(
        scheduled.first.id,
        deliveredAt: deliveredAt,
      );

      final all = await remindersDao.watchRemindersForChild('child-1').first;
      final delivered =
          all.firstWhere((reminder) => reminder.id == scheduled.first.id);

      expect(delivered.deliveredAt, deliveredAt);
    });

    test("does not return another child's reminders", () async {
      await insertChildWithDue();
      await insertChildWithDue(
        childId: 'child-2',
        dueId: 'due-2',
        vaccineCode: 'MR',
      );
      await remindersDao.scheduleRemindersForDue('due-1', from: wellBefore);
      await remindersDao.scheduleRemindersForDue('due-2', from: wellBefore);

      final forChildOne =
          await remindersDao.watchRemindersForChild('child-1').first;

      expect(forChildOne, isNotEmpty);
      expect(
        forChildOne.every((reminder) => reminder.childId == 'child-1'),
        isTrue,
      );
    });

    test('emits again when reminders are scheduled', () async {
      await insertChildWithDue();

      final events = <List<Reminder>>[];
      final subscription =
          remindersDao.watchRemindersForChild('child-1').listen(events.add);

      await pumpEventQueue();
      expect(events.last, isEmpty);

      await remindersDao.scheduleRemindersForDue('due-1', from: wellBefore);

      await pumpEventQueue();
      expect(events.last, isNotEmpty);

      await subscription.cancel();
    });

    test('drops reminders for a single due', () async {
      await insertChildWithDue();
      await insertDue(id: 'due-2', childId: 'child-1', vaccineCode: 'MR');
      await remindersDao.scheduleRemindersForDue('due-1', from: wellBefore);
      await remindersDao.scheduleRemindersForDue('due-2', from: wellBefore);

      await remindersDao.deleteRemindersForDue('due-1');

      final remaining = await remindersDao.getPendingReminders();
      expect(remaining, isNotEmpty);
      expect(remaining.every((reminder) => reminder.dueId == 'due-2'), isTrue);
    });

    test('drops reminders for a child', () async {
      await insertChildWithDue();
      await remindersDao.scheduleRemindersForDue('due-1', from: wellBefore);

      await remindersDao.deleteRemindersForChild('child-1');

      expect(await remindersDao.getPendingReminders(), isEmpty);
    });

    test('rejects a reminder without a matching due', () async {
      await insertChild('child-1');

      expect(
        () => remindersDao.into(remindersDao.reminders).insert(
              RemindersCompanion.insert(
                id: 'reminder-1',
                childId: 'child-1',
                dueId: 'missing-due',
                kind: ReminderKind.sameDay,
                scheduledFor: dueDate,
                notificationId: 1,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
