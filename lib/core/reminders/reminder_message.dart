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
/// The upcoming and overdue wording is specified by the client brief and must
/// not be reworded without them. The two follow-up variants and every title are
/// ours; see the notes in `app_en.arb`.
///
/// TODO(client sign-off): the "For {childName}:" prefix, both follow-up
/// messages, every title and all the Nepali copy are drafts awaiting client
/// and native-speaker review.
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

  return switch (kind) {
    ReminderKind.advance ||
    ReminderKind.preparation ||
    ReminderKind.sameDay =>
      (
        title: localizations.reminderTitleUpcoming,
        body: localizations.reminderUpcoming(childName, vaccineName, date),
      ),
    ReminderKind.followUpDay => (
        title: localizations.reminderTitleMissed,
        body: localizations.reminderMissedYesterday(
          childName,
          vaccineName,
          date,
        ),
      ),
    ReminderKind.followUpWeek => (
        title: localizations.reminderTitleMissed,
        body: localizations.reminderMissedWeek(childName, vaccineName),
      ),
    ReminderKind.overdueRecurring => (
        title: localizations.reminderTitleOverdue,
        body: localizations.reminderOverdue(childName, vaccineName),
      ),
  };
}
