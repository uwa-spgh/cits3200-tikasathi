import 'dart:core';

// Note: The dose of a vaccine corresponds to the index of each due-at-age. Ergo, to determine if a particular doseNumber exists, 
// check if it is within the length of the list for the particular vaccine. Likewise, to determine if a particular vaccineCode exists,
// check if the key exists in the NIP map
final Map<String, List<DayDuration>> _NIP = Map.unmodifiable({
  'BCG': [DayDuration()],
  'PENTA': [DayDuration(weeks: 6), DayDuration(weeks: 10), DayDuration(weeks: 14)],
  'BOPV': [DayDuration(weeks: 6), DayDuration(weeks: 10), DayDuration(weeks: 14)],
  'FIPV': [DayDuration(weeks: 14), DayDuration(months: 9)],
  'ROTA': [DayDuration(weeks: 6), DayDuration(weeks: 10)],
  'PCV': [DayDuration(weeks: 6), DayDuration(weeks: 10), DayDuration(months: 9)],
  'MR': [DayDuration(months: 9), DayDuration(months: 15)],
  'JE': [DayDuration(months: 12)],
  'TCV': [DayDuration(months: 15)],
});

class DayDuration {
  final Duration duration;

  DayDuration({
    int years = 0,
    int months = 0,
    int weeks = 0,
    int days = 0,
  }) : duration = Duration(days: days + weeks * 7 + (months * 30.44 + years * 365.25).toInt());
}

bool doesDoseExist(String vaccineCode, int doseNumber) {
  return getDoseAge(vaccineCode, doseNumber) != null;
}

DayDuration? getDoseAge(String vaccineCode, int doseNumber) {
  return _NIP[vaccineCode]?.elementAtOrNull(doseNumber - 1);
}

typedef DoseRecord = ({int doseNumber, Duration dueAge, String vaccineCode});

List<DoseRecord> getAllDoses() {
  final List<({String vaccineCode, int doseNumber, Duration dueAge})> result = [];

  _NIP.forEach((vaccine, ages) {
    for (final (dose, age) in ages.indexed) {
      result.add((
        vaccineCode: vaccine,
        doseNumber: dose + 1,
        dueAge: age.duration
      ));
    }
  });
  
  return result;
}