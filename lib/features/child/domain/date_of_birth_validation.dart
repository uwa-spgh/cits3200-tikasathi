enum ChildDateOfBirthError {
  invalid,
  future,
  tooOld,
}

class ChildDateOfBirthValidation {
  const ChildDateOfBirthValidation.valid(this.dateOfBirth) : error = null;

  const ChildDateOfBirthValidation.invalid(this.error) : dateOfBirth = null;

  final DateTime? dateOfBirth;
  final ChildDateOfBirthError? error;

  bool get isValid => dateOfBirth != null;
}

ChildDateOfBirthValidation validateChildDateOfBirth({
  required int day,
  required int month,
  required int year,
  DateTime? today,
}) {
  if (day < 1 || month < 1 || year < 1) {
    return const ChildDateOfBirthValidation.invalid(
      ChildDateOfBirthError.invalid,
    );
  }

  final DateTime dob;
  try {
    dob = DateTime(year, month, day);
  } on ArgumentError {
    return const ChildDateOfBirthValidation.invalid(
      ChildDateOfBirthError.invalid,
    );
  }

  if (dob.year != year || dob.month != month || dob.day != day) {
    return const ChildDateOfBirthValidation.invalid(
      ChildDateOfBirthError.invalid,
    );
  }

  final DateTime currentDate = today ?? DateTime.now();
  final DateTime currentDay =
      DateTime(currentDate.year, currentDate.month, currentDate.day);

  if (dob.isAfter(currentDay)) {
    return const ChildDateOfBirthValidation.invalid(
      ChildDateOfBirthError.future,
    );
  }

  var age = currentDay.year - dob.year;
  final birthdayThisYear = DateTime(
    currentDay.year,
    dob.month,
    dob.day,
  );
  if (birthdayThisYear.isAfter(currentDay)) {
    age--;
  }

  if (age >= 18) {
    return const ChildDateOfBirthValidation.invalid(
      ChildDateOfBirthError.tooOld,
    );
  }

  return ChildDateOfBirthValidation.valid(dob);
}

DateTime? parseValidChildDateOfBirth({
  required int day,
  required int month,
  required int year,
  DateTime? today,
}) {
  return validateChildDateOfBirth(
    day: day,
    month: month,
    year: year,
    today: today,
  ).dateOfBirth;
}
