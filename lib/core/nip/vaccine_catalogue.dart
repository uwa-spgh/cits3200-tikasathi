import 'dart:core';

part 'generate.dart';

/// A map of the National Immunisation Program
///
/// Each vaccination is a list of durations representing the age of the child each dose should be administered by,
/// where the first age corresponds to the first dose, the second age to the second dose, etc.
final Map<String, List<DayDuration>> _niP = Map.unmodifiable({
  // Note: The dose of a vaccine corresponds to the index of each due-at-age. Ergo, to determine if a particular doseNumber exists,
  // check if it is within the length of the list for the particular vaccine. Likewise, to determine if a particular vaccineCode exists,
  // check if the key exists in the NIP map
  'BCG': [DayDuration()],
  'PENTA': [
    DayDuration(weeks: 6),
    DayDuration(weeks: 10),
    DayDuration(weeks: 14)
  ],
  'BOPV': [
    DayDuration(weeks: 6),
    DayDuration(weeks: 10),
    DayDuration(weeks: 14)
  ],
  'FIPV': [DayDuration(weeks: 14), DayDuration(months: 9)],
  'ROTA': [DayDuration(weeks: 6), DayDuration(weeks: 10)],
  'PCV': [
    DayDuration(weeks: 6),
    DayDuration(weeks: 10),
    DayDuration(months: 9)
  ],
  'MR': [DayDuration(months: 9), DayDuration(months: 15)],
  'JE': [DayDuration(months: 12)],
  'TCV': [DayDuration(months: 15)],
});

/// A wrapper around Duration to input days, weeks, months, and years.
///
/// Stores a Duration field that is calculated using the average number of days for each period of time.
/// This means that a duration of 1 month added to a particular day may not result in the same day one month later,
/// since the length of each month varies.
class DayDuration {
  final Duration duration;

  DayDuration({
    int years = 0,
    int months = 0,
    int weeks = 0,
    int days = 0,
  }) : duration = Duration(
            days: days + weeks * 7 + (months * 30.44 + years * 365.25).toInt());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayDuration && other.duration == duration;
  }

  @override
  int get hashCode => duration.hashCode;
}

/// Queries the NIP to determine if a particular combination of vaccine code and dose number exists.
bool doesDoseExist(String vaccineCode, int doseNumber) {
  return getDoseAge(vaccineCode, doseNumber) != null;
}

/// Queries the NIP to find the required age for a particular dosage, or null if that dosage doesn't exist.
DayDuration? getDoseAge(String vaccineCode, int doseNumber) {
  return _niP[vaccineCode]?.elementAtOrNull(doseNumber - 1);
}
