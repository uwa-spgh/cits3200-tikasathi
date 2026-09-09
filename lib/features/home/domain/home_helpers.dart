import 'package:tikasathi/core/generated/app_localizations.dart';

enum ChildSex {
  male,
  female,
  unknown,
}

ChildSex childSexFromString(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'male':
    case 'boy':
      return ChildSex.male;
    case 'female':
    case 'girl':
      return ChildSex.female;
    default:
      return ChildSex.unknown;
  }
}

String childSexLabel(String? value, AppLocalizations localizations) {
  switch (childSexFromString(value)) {
    case ChildSex.male:
      return localizations.childSexMale;
    case ChildSex.female:
      return localizations.childSexFemale;
    case ChildSex.unknown:
      return localizations.childSexUnknown;
  }
}

String formatAge(DateTime dateOfBirth, AppLocalizations localizations) {
  final DateTime today = DateTime.now();
  final int totalDays = today.difference(dateOfBirth).inDays;

  if (totalDays < 30) {
    return localizations.ageInDays(totalDays);
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
    return localizations.ageInMonths(totalMonths);
  }

  return localizations.ageInYears(years);
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
    case ChildSex.unknown:
      return '🧒';
  }
}
