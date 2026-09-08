part of 'vaccine_catalogue.dart';

typedef GeneratedDue = ({
  String vaccineCode,
  int doseNumber,
  DateTime dueDate,
});

typedef AdministeredDose = ({
  String vaccineCode,
  int doseNumber,
  DateTime administeredDate,
});

typedef GenerateDues = List<GeneratedDue> Function(
  DateTime dob,
  DateTime today,
  List<AdministeredDose> records,
);

enum VaccineStatus { completed, ongoing, overdue }

/// A map of the vaccination catch-up schedule.
/// 
/// Each vaccination is a list of CatchUpRule, where each rule defines an age range that it is applicable to, 
/// the number of doses needed in that age range, and the minimum interval between each dose.
final Map<String, List<CatchUpRule>> _catchUp = Map.unmodifiable({
  'BCG': [CatchUpRule(maxAge: DayDuration(years: 5))],
  'PENTA': <CatchUpRule>[], // no catch-up mentioned
  'BOPV': [CatchUpRule(doses: 3, minInterval: DayDuration(months: 1))],
  'FIPV': [CatchUpRule(doses: 2, minInterval: DayDuration(months: 4))],
  'ROTA': [
    CatchUpRule(
        maxAge: DayDuration(years: 2),
        doses: 2,
        minInterval: DayDuration(months: 1))
  ],
  'PCV': [
    CatchUpRule(
        maxAge: DayDuration(months: 12),
        doses: 3,
        minInterval: DayDuration(months: 1)),
    CatchUpRule(
        minAge: DayDuration(months: 12),
        maxAge: DayDuration(months: 23),
        doses: 2,
        minInterval: DayDuration(months: 2))
  ],
  'MR': [
    CatchUpRule(
        minAge: DayDuration(months: 9),
        maxAge: DayDuration(years: 5),
        doses: 2,
        minInterval: DayDuration(months: 1))
  ],
  'JE': <CatchUpRule>[], // no catch-up mentioned
  'TCV': [
    CatchUpRule(minAge: DayDuration(months: 15), maxAge: DayDuration(years: 5))
  ]
});

/// Represents a part of the catch-up schedule for a particular vaccination.
/// 
/// Contains fields for the number of required doses, the minimum interval between doses, and the minimum and maximum age that this schedule applies to,
/// The default values, when nothing is passed, is 0 - 100 years for the age range, 1 required dose, and no minimum interval.
class CatchUpRule {
  final DayDuration minAge;
  final DayDuration maxAge;
  final int doses;
  final DayDuration minInterval;

  CatchUpRule(
      {DayDuration? minAge,
      DayDuration? maxAge,
      this.doses = 1,
      DayDuration? minInterval})
      : minAge = minAge ?? DayDuration(),
        maxAge = maxAge ?? DayDuration(years: 100),
        minInterval = minInterval ?? DayDuration();
}

/// Produces a vaccination schedule, automatically applying the catch-up schedule for overdue vaccinations.
/// 
/// Takes the date of birth, today's date, and a list of vaccination records as input,
/// and produces a list of vaccination due dates as outputs.
/// Completed vaccinations do not generate any due dates.
/// Ongoing vaccinations only generate upcoming due dates.
/// Overdue vaccinations generate due dates via _generateCatchUp()
List<GeneratedDue> generate(
  DateTime dob,
  DateTime today,
  List<AdministeredDose> records,
) {
  final List<GeneratedDue> result = [];

  final age = today.difference(dob);
  _niP.forEach((vaccine, ages) {
    for (final (dose, doseAge) in ages.indexed) {
      if (records.any((AdministeredDose record) =>
          record.vaccineCode == vaccine && record.doseNumber == dose + 1)) {
        // dose is completed, ignore
        continue;
      }
      if (age <= doseAge.duration) {
        // dose is ongoing and on-time, add due date according to NIP schedule
        result.add((
          vaccineCode: vaccine,
          doseNumber: dose + 1,
          dueDate: dob.add(doseAge.duration)
        ));
        continue;
      }
      // dose is overdue, replace all overdue doses with the catch-up schedule
      result.addAll(_generateCatchUp(vaccine, dose, age, today));
      break;
    }
  });

  return result;
}

/// The status of a particular vaccine.
/// 
/// Takes a vaccination due dates and filters for doses that match the given vaccine code,
/// then compares them with today's date to return if a vaccine is completed, ongoing, or overdue.
VaccineStatus status(
    DateTime today,
    List<GeneratedDue> dues, // better name for GeneratedDue?
    String vaccineCode) {
  final vaccineDues =
      dues.where((GeneratedDue due) => due.vaccineCode == vaccineCode);
  // no due dates, vaccine is completed
  if (vaccineDues.isEmpty) return VaccineStatus.completed;
  final isOverdue =
      vaccineDues.any((GeneratedDue due) => due.dueDate.isBefore(today));
  //if any due date exists that is before today, then it is overdue, otherwise it is ongoing
  return isOverdue ? VaccineStatus.overdue : VaccineStatus.ongoing;
}

/// Generates the catch-up schedule for an overdue vaccine.
/// 
/// Schedules the first overdue dose's due date to tomorrow, then schedules following due dates with the vaccine's minimum interval between each one.
/// Doses that exceed the maximum age for the catch-up schedule are excluded.
List<GeneratedDue> _generateCatchUp(
    String vaccineCode, int dosesTaken, Duration age, DateTime today) {
  final List<GeneratedDue> result = [];

  final CatchUpRule rule;
  try {
    rule = _catchUp[vaccineCode]!.firstWhere((CatchUpRule rule) {
      return rule.minAge.duration <= age && age < rule.maxAge.duration;
    });
  } on StateError catch (_) {
    // vaccination has no catch-up schedule, return early with no due dates.
    return result;
  }

  for (int i = dosesTaken; i < rule.doses; i++) {
    // For now, only vaccinations under the maxAge are added to results, which may result in incomplete vaccination schedules
    if (age + rule.minInterval.duration * i + const Duration(days: 1) >
        rule.maxAge.duration) {
      break;
    }
    result.add((
      vaccineCode: vaccineCode,
      doseNumber: i + 1,
      dueDate: today.add(rule.minInterval.duration * (i - dosesTaken) +
          const Duration(days: 1))
    ));
  }
  return result;
}
