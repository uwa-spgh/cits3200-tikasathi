enum ChildSex {
  male,
  female,
}

String formatAge(DateTime dateOfBirth, {bool isNp = false}) {
  final DateTime today = DateTime.now();
  final int totalDays = today.difference(dateOfBirth).inDays;

  if (totalDays < 30) {
    if (isNp) return '$totalDays दिन';
    return '$totalDays ${totalDays == 1 ? 'day' : 'days'} old';
  }

  int years = today.year - dateOfBirth.year;

  if (today.month < dateOfBirth.month ||
      (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
    years--;
  }

  final int totalMonths = (today.year - dateOfBirth.year) * 12 +
      today.month -
      dateOfBirth.month -
      (today.day < dateOfBirth.day ? 1 : 0);

  if (totalMonths < 24) {
    if (isNp) return '$totalMonths महिना';
    return '$totalMonths ${totalMonths == 1 ? 'month' : 'months'} old';
  }

  if (isNp) return '$years वर्ष';
  return '$years ${years == 1 ? 'year' : 'years'} old';
}

String getChildAvatar({
  required ChildSex sex,
  required DateTime dateOfBirth,
}) {
  final DateTime today = DateTime.now();
  int ageInMonths =
      (today.year - dateOfBirth.year) * 12 + today.month - dateOfBirth.month;
  if (today.day < dateOfBirth.day) {
    ageInMonths--;
  }
  if (ageInMonths < 24) {
    return '👶';
  }

  switch (sex) {
    case ChildSex.male:
      return '👦';
    case ChildSex.female:
      return '👧';
  }
}
