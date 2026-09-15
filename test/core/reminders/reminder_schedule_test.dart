import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/reminders/reminder_schedule.dart';

void main() {
  group('planReminders', () {
    final DateTime dueDate = DateTime(2024, 6, 20);
    final DateTime wellBefore = DateTime(2024, 1, 1);

    List<PlannedReminder> plan({DateTime? from}) {
      return planReminders(dueDate, from: from ?? wellBefore);
    }

    DateTime scheduledFor(ReminderKind kind) {
      return plan()
          .firstWhere((reminder) => reminder.kind == kind)
          .scheduledFor;
    }

    test('raises the three pre-due touches', () {
      expect(
        scheduledFor(ReminderKind.advance),
        DateTime(2024, 6, 13, reminderHourOfDay),
      );
      expect(
        scheduledFor(ReminderKind.preparation),
        DateTime(2024, 6, 19, reminderHourOfDay),
      );
      expect(
        scheduledFor(ReminderKind.sameDay),
        DateTime(2024, 6, 20, reminderHourOfDay),
      );
    });

    test('follows up one day and one week after a missed dose', () {
      expect(
        scheduledFor(ReminderKind.followUpDay),
        DateTime(2024, 6, 21, reminderHourOfDay),
      );
      expect(
        scheduledFor(ReminderKind.followUpWeek),
        DateTime(2024, 6, 27, reminderHourOfDay),
      );
    });

    test('drops to a fortnightly cadence once overdue', () {
      final recurring = plan()
          .where((reminder) => reminder.kind == ReminderKind.overdueRecurring)
          .map((reminder) => reminder.scheduledFor)
          .toList();

      expect(recurring.first, DateTime(2024, 7, 11, reminderHourOfDay));
      expect(recurring[1], DateTime(2024, 7, 25, reminderHourOfDay));

      for (var i = 1; i < recurring.length; i++) {
        expect(
          recurring[i].difference(recurring[i - 1]),
          overdueReminderInterval,
        );
      }
    });

    test('stops scheduling overdue reminders past the horizon', () {
      final reminders = plan();

      expect(reminders, isNotEmpty);
      expect(
        reminders.last.scheduledFor
            .difference(DateTime(2024, 6, 20, reminderHourOfDay)),
        lessThanOrEqualTo(overdueReminderHorizon),
      );
    });

    test('returns reminders in chronological order', () {
      final reminders = plan();

      for (var i = 1; i < reminders.length; i++) {
        expect(
          reminders[i].scheduledFor.isAfter(reminders[i - 1].scheduledFor),
          isTrue,
        );
      }
    });

    test('skips reminders that already passed', () {
      final reminders = plan(from: DateTime(2024, 6, 19, 12));

      expect(
        reminders.map((reminder) => reminder.kind),
        isNot(contains(ReminderKind.advance)),
      );
      expect(
        reminders.map((reminder) => reminder.kind),
        isNot(contains(ReminderKind.preparation)),
      );
      expect(reminders.first.kind, ReminderKind.sameDay);
    });

    test('returns nothing for a dose missed beyond the horizon', () {
      expect(plan(from: DateTime(2026, 1, 1)), isEmpty);
    });

    test('schedules every reminder at the reminder hour', () {
      for (final reminder in plan()) {
        expect(reminder.scheduledFor.hour, reminderHourOfDay);
        expect(reminder.scheduledFor.minute, 0);
      }
    });

    test('defaults to now when no reference time is given', () {
      final past = planReminders(DateTime(2000, 1, 1));

      expect(past, isEmpty);
    });
  });

  group('isOverdue', () {
    final DateTime dueDate = DateTime(2024, 6, 20);

    test('is false on the due date', () {
      expect(isOverdue(dueDate, asOf: DateTime(2024, 6, 20, 23)), isFalse);
    });

    test('is false within a week of the due date', () {
      expect(isOverdue(dueDate, asOf: DateTime(2024, 6, 26)), isFalse);
    });

    test('is true more than a week after the due date', () {
      expect(isOverdue(dueDate, asOf: DateTime(2024, 6, 28)), isTrue);
    });
  });
}
