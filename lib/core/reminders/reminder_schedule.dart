import 'dart:core';

/// Which of the reminder rules produced a given reminder.
enum ReminderKind {
  advance, // one week before due date
  preparation, // one day before due date, to prep the visit
  sameDay, // on the due date itself
  followUpDay, // one day after a missed due date
  followUpWeek, // one week after a missed due date, when the dose becomes overdue
  overdueRecurring, // fortnightly once the dose is overdue
}

/// hour of the local day at which reminders fire (e.g. 9am)
const int reminderHourOfDay = 9;

/// how long after the due date a dose is considered overdue
const Duration overdueAfter = Duration(days: 7);

/// cadence of reminders once a dose is overdue.
const Duration overdueReminderInterval = Duration(days: 14);

/// how far past the due date recurring overdue reminders keep being scheduled.
const Duration overdueReminderHorizon = Duration(days: 365);

/// A single reminder the app should raise for a vaccination due.
typedef PlannedReminder = ({ReminderKind kind, DateTime scheduledFor});

/// The reminders for a dose due on [dueDate], in chronological order.
///
/// Only reminders strictly after [from] are returned, so scheduling a dose that
/// is already a month late does not replay reminders the caregiver has missed.
/// [from] defaults to [DateTime.now].
List<PlannedReminder> planReminders(DateTime dueDate, {DateTime? from}) {
  final DateTime now = from ?? DateTime.now();
  final DateTime due = _atReminderHour(dueDate);

  final List<PlannedReminder> planned = <PlannedReminder>[
    (kind: ReminderKind.advance, scheduledFor: _shift(due, days: -7)),
    (kind: ReminderKind.preparation, scheduledFor: _shift(due, days: -1)),
    (kind: ReminderKind.sameDay, scheduledFor: due),
    (kind: ReminderKind.followUpDay, scheduledFor: _shift(due, days: 1)),
    (kind: ReminderKind.followUpWeek, scheduledFor: _shift(due, days: 7)),
  ];

  for (Duration offset = overdueAfter + overdueReminderInterval;
      offset <= overdueReminderHorizon;
      offset += overdueReminderInterval) {
    planned.add(
      (
        kind: ReminderKind.overdueRecurring,
        scheduledFor: _shift(due, days: offset.inDays),
      ),
    );
  }

  return planned
      .where((reminder) => reminder.scheduledFor.isAfter(now))
      .toList();
}

/// Whether a dose due on [dueDate] is overdue as at [asOf].
bool isOverdue(DateTime dueDate, {DateTime? asOf}) {
  final DateTime now = asOf ?? DateTime.now();
  return now.isAfter(_atReminderHour(dueDate).add(overdueAfter));
}

/// The reminder instant on the calendar day of [date].
///
/// Built from the date parts rather than by adding a [Duration] so the result
/// stays at [reminderHourOfDay] local time across daylight saving changes.
DateTime _atReminderHour(DateTime date) {
  return DateTime(date.year, date.month, date.day, reminderHourOfDay);
}

DateTime _shift(DateTime from, {required int days}) {
  return DateTime(
    from.year,
    from.month,
    from.day + days,
    from.hour,
    from.minute,
  );
}
