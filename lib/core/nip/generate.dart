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

// minAge inclusive, maxAge exclusive
final Map<String, List<CatchUpRule>> _catchUp = Map.unmodifiable({
  'BCG': [
    CatchUpRule(maxAge: DayDuration(years: 5))
  ],
  'PENTA': <CatchUpRule>[], // no catch-up mentioned
  'BOPV': [
    CatchUpRule(doses: 3, minInterval: DayDuration(months: 1))
  ],
  'FIPV': [
    CatchUpRule(doses: 2, minInterval: DayDuration(months: 4))
  ],
  'ROTA': [
    CatchUpRule(maxAge: DayDuration(years: 2), doses: 2, minInterval: DayDuration(months: 1))
  ],
  'PCV': [
    CatchUpRule(maxAge: DayDuration(months: 12), doses: 3, minInterval: DayDuration(months: 1)),
    CatchUpRule(minAge: DayDuration(months: 12), maxAge: DayDuration(months: 23), doses: 2, minInterval: DayDuration(months: 2))
  ],
  'MR': [
    CatchUpRule(minAge: DayDuration(months: 9), maxAge: DayDuration(years: 5), doses: 2, minInterval: DayDuration(months: 1))
  ],
  'JE': <CatchUpRule>[], // no catch-up mentioned
  'TCV': [
    CatchUpRule(minAge: DayDuration(months: 15), maxAge: DayDuration(years: 5))
  ]
});

class CatchUpRule {
  final DayDuration minAge;
  final DayDuration maxAge;
  final int doses;
  final DayDuration minInterval;

  CatchUpRule({
    DayDuration? minAge,
    DayDuration? maxAge,
    this.doses = 1,
    DayDuration? minInterval
  }) : 
    minAge = minAge ?? DayDuration(),
    maxAge = maxAge ?? DayDuration(years: 100),
    minInterval = minInterval ?? DayDuration();
}

List<GeneratedDue> generate(
  DateTime dob,
  DateTime today,
  List<AdministeredDose> records,
) {
  final List<GeneratedDue> result = [];

  final age = today.difference(dob);
  _niP.forEach((vaccine, ages) {
    for (final (dose, doseAge) in ages.indexed) {
      // dose completed
      if (records.any((AdministeredDose record) => record.vaccineCode == vaccine && record.doseNumber == dose + 1)) continue;
      // dose ongoing
      if (age <= doseAge.duration) {
        result.add((vaccineCode: vaccine, doseNumber: dose + 1, dueDate: dob.add(doseAge.duration)));
        continue;
      }
      // dose overdue
      result.addAll(_generateCatchUp(vaccine, dose, age, today));
      break;
    }
  });

  return result;
}

VaccineStatus status(
  DateTime today,
  List<GeneratedDue> dues, // better name for GeneratedDue?
  String vaccineCode
) {
  final vaccineDues = dues.where((GeneratedDue due) => due.vaccineCode == vaccineCode);
  if (vaccineDues.isEmpty) return VaccineStatus.completed;
  final isOverdue = vaccineDues.any((GeneratedDue due) => due.dueDate.isBefore(today));
  return isOverdue ? VaccineStatus.overdue : VaccineStatus.ongoing;
}

List<GeneratedDue> _generateCatchUp(
  String vaccineCode,
  int dosesTaken,
  Duration age,
  DateTime today
) {
  final List<GeneratedDue> result = [];

  final CatchUpRule rule;
  try {
    rule = _catchUp[vaccineCode]!.firstWhere((CatchUpRule rule) {
      return rule.minAge.duration <= age && age < rule.maxAge.duration;
    });
  } on StateError catch(_) {
    return result;
  }

  for (int i = dosesTaken; i < rule.doses; i++) {
    // For now, only vaccinations under the maxAge are added to results, which may result in incomplete vaccination schedules
    if (age + rule.minInterval.duration * i + const Duration(days: 1) > rule.maxAge.duration) break;
    result.add((vaccineCode: vaccineCode, doseNumber: i + 1, dueDate: today.add(rule.minInterval.duration * (i - dosesTaken) + const Duration(days: 1))));
  }
  return result;
}