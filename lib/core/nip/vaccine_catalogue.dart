import 'dart:core';

// Note: The dose of a vaccine corresponds to the index of each due-at-age. Ergo, to determine if a particular doseNumber exists, 
// check if it is within the length of the list for the particular vaccine. Likewise, to determine if a particular vaccineCode exists,
// check if the key exists in the NIP map
const NIP = {
  'BCG': [DayDuration()],
  'PENTA': [DayDuration(weeks: 6), DayDuration(weeks: 10), DayDuration(weeks: 14)],
  'BOPV': [DayDuration(weeks: 6), DayDuration(weeks: 10), DayDuration(weeks: 14)],
  'FIPV': [DayDuration(weeks: 14), DayDuration(months: 9)],
  'ROTA': [DayDuration(weeks: 6), DayDuration(weeks: 10)],
  'PCV': [DayDuration(weeks: 6), DayDuration(weeks: 10), DayDuration(months: 9)],
  'MR': [DayDuration(months: 9), DayDuration(months: 15)],
  'JE': [DayDuration(months: 12)],
  'TCV': [DayDuration(months: 15)],
};

class DayDuration {
  final int years;
  final int months;
  final int weeks;
  final int days;

  const DayDuration({
    this.years = 0,
    this.months = 0,
    this.weeks = 0,
    this.days = 0,
  });
}

extension AddDayDuration on DateTime {
  DateTime addDayDuration(DayDuration duration) {
    return DateTime(year + duration.years, month + duration.months, day + (duration.days + duration.weeks * 7));
  }
}