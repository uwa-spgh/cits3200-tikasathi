// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TikaSathi';

  @override
  String get childPageTitle => 'Child Page';

  @override
  String childPageTitleWithName(String childName) {
    return '$childName\'s page';
  }

  @override
  String get childLoading => 'Loading child details...';

  @override
  String get childNotFound => 'Child profile not found.';

  @override
  String get childVaccinationDueToday => 'Vaccination due today';

  @override
  String get childVaccinationDueSoon => 'Due soon';

  @override
  String get childVaccinationUpToDate => 'Up to date';

  @override
  String get childNextVaccine => 'Next vaccine';

  @override
  String get childNoUpcomingVaccines => 'No upcoming vaccines';

  @override
  String childBornOn(String dateText) {
    return 'Born $dateText';
  }

  @override
  String get childDueOn => 'Due on';

  @override
  String get childSexLabel => 'Sex';

  @override
  String get childDobLabel => 'Date of birth';

  @override
  String get childSexMale => 'Male';

  @override
  String get childSexFemale => 'Female';

  @override
  String get childNoDueVaccines => 'No due vaccines';

  @override
  String get childReadAloudUnavailable => 'Read aloud is not available yet.';

  @override
  String get childReadAloudTooltip => 'Read aloud';

  @override
  String get childBackTooltip => 'Back';

  @override
  String get childVaccineSchedule => 'Vaccine schedule';

  @override
  String get childVaccineHistory => 'Vaccine history';

  @override
  String get childScheduleNotImplemented =>
      'Vaccine schedule is not implemented yet.';

  @override
  String get childHistoryNotImplemented =>
      'Vaccine history is not implemented yet.';

  @override
  String get childNotImplementedYet => 'Not implemented yet.';

  @override
  String get childDialogOk => 'OK';

  @override
  String get childMissingFeatureNote =>
      'Record vaccine and clinic lookup are not available yet in this version.';
}
