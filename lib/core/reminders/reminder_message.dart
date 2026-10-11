import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/nip/vaccine_display.dart';
import 'package:tikasathi/core/reminders/reminder_schedule.dart';

/// The wording of one reminder notification.
typedef ReminderMessage = ({String title, String body});

/// Loads the date symbols [buildReminderMessage] formats dates with.
///
/// Widgets get these from the localization delegates, but reminders are built
/// outside the widget tree — before `runApp`, in fact — where nothing has
/// loaded them yet. Calling it more than once is harmless.
Future<void> ensureReminderDateFormatting() => initializeDateFormatting();

/// The vaccine as the rest of the app names it, e.g. `PENTA (Dose 2)`.
///
/// Dues carry a code and a dose number rather than a display name, and the
/// vaccine records screen builds the label this same way.
String reminderVaccineName(
  AppLocalizations localizations,
  String vaccineCode,
  int doseNumber,
) {
  return formatVaccineDisplayName(localizations, vaccineCode, doseNumber);
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
/// [facility] is the caregiver's saved health facility, already formatted by
/// [describeFacility]. The brief asks the reminders before a due date to say
/// where to go "if available", so it is added to those three and left out when
/// nothing is saved.
///
/// TODO(facility locator): the brief means the nearest immunisation service or
/// outreach session. The app has no such data, only the facility the caregiver
/// saves by hand, so that is what reminders name for now.
ReminderMessage buildReminderMessage({
  required AppLocalizations localizations,
  required String languageCode,
  required String childName,
  required String vaccineCode,
  required int doseNumber,
  required DateTime dueDate,
  required ReminderKind kind,
  String? facility,
}) {
  final String vaccineName = reminderVaccineName(
    localizations,
    vaccineCode,
    doseNumber,
  );
  final String date = DateFormat('d MMMM y', languageCode).format(dueDate);
  final String due = localizations.reminderUpcoming(vaccineName, date);
  final String where =
      facility == null ? '' : ' ${localizations.reminderFacility(facility)}';

  // The brief's 3-touch approach: the day before reinforces that tomorrow is
  // the day, and the day itself opens with its own quoted phrase. Both lead
  // into the client's fixed sentence rather than rewording it.
  return switch (kind) {
    ReminderKind.advance => (
        title: localizations.reminderTitleUpcoming(childName),
        body: '$due$where',
      ),
    ReminderKind.preparation => (
        title: localizations.reminderTitleUpcoming(childName),
        body: '${localizations.reminderLeadTomorrow} $due$where',
      ),
    ReminderKind.sameDay => (
        title: localizations.reminderTitleUpcoming(childName),
        body: '${localizations.reminderLeadToday} $due$where',
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

/// The saved facility as one line, e.g. `Bhaktapur Health Post, Ward 4, 98...`.
///
/// Returns null when nothing usable is saved, so callers can leave the
/// sentence out rather than print an empty one.
String? describeFacility({String? name, String? address, String? phone}) {
  final List<String> parts = <String>[
    for (final String? part in <String?>[name, address, phone])
      if (part != null && part.trim().isNotEmpty) part.trim(),
  ];
  return parts.isEmpty ? null : parts.join(', ');
}
