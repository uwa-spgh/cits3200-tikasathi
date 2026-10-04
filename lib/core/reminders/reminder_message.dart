import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/reminders/reminder_schedule.dart';

/// The wording of one reminder notification.
typedef ReminderMessage = ({String title, String body});

/// Loads the date symbols [buildReminderMessage] formats dates with.
///
/// Widgets get these from the localization delegates, but reminders are built
/// outside the widget tree — before `runApp`, in fact — where nothing has
/// loaded them yet. Calling it more than once is harmless.
Future<void> ensureReminderDateFormatting() => initializeDateFormatting();

/// The vaccine as the rest of the app names it, e.g. `BCG (Dose 1)`.
///
/// Dues carry a code and a dose number rather than a display name, and the
/// vaccine records screen builds the label this same way.
String reminderVaccineName(
  AppLocalizations localizations,
  String vaccineCode,
  int doseNumber,
) {
  return '$vaccineCode (${localizations.dose} $doseNumber)';
}

/// The text to show for a reminder of [kind].
///
/// Built when the notification is raised rather than stored on the reminder
/// row, so renaming a child or changing a due date cannot leave stale wording
/// behind.
///
/// The upcoming and overdue bodies are the client brief's exact wording and must
/// not be reworded. The child's name goes in the title instead, which the brief
/// leaves open, so caregivers with several children can tell reminders apart.
/// The two follow-up bodies and every title are ours; see `app_en.arb`.
///
/// TODO(facility locator): the brief wants the nearest immunisation service or
/// outreach session in the advance reminder. The app has no such data yet —
/// only the one facility a caregiver saves by hand — so it is not included.
ReminderMessage buildReminderMessage({
  required AppLocalizations localizations,
  required String languageCode,
  required String childName,
  required String vaccineCode,
  required int doseNumber,
  required DateTime dueDate,
  required ReminderKind kind,
}) {
  final String vaccineName = reminderVaccineName(
    localizations,
    vaccineCode,
    doseNumber,
  );
  final String date = DateFormat('d MMMM y', languageCode).format(dueDate);
  final String due = localizations.reminderUpcoming(vaccineName, date);

  // The brief's 3-touch approach: the day before reinforces that tomorrow is
  // the day, and the day itself opens with its own quoted phrase. Both lead
  // into the client's fixed sentence rather than rewording it.
  return switch (kind) {
    ReminderKind.advance => (
        title: localizations.reminderTitleUpcoming(childName),
        body: due,
      ),
    ReminderKind.preparation => (
        title: localizations.reminderTitleUpcoming(childName),
        body: '${localizations.reminderLeadTomorrow} $due',
      ),
    ReminderKind.sameDay => (
        title: localizations.reminderTitleUpcoming(childName),
        body: '${localizations.reminderLeadToday} $due',
      ),
    ReminderKind.followUpDay => (
        title: localizations.reminderTitleMissed(childName),
        body: localizations.reminderMissedYesterday(vaccineName, date),
      ),
    ReminderKind.followUpWeek => (
        title: localizations.reminderTitleMissed(childName),
        body: localizations.reminderMissedWeek(vaccineName),
      ),
    ReminderKind.overdueRecurring => (
        title: localizations.reminderTitleOverdue(childName),
        body: localizations.reminderOverdue(vaccineName),
      ),
  };
}
