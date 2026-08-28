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

  @override
  String get healthFacilitatorSaveAction =>
      'Save your closest health facilitator';

  @override
  String get healthFacilitatorSavedHeading => 'Your local health facilitator';

  @override
  String get healthFacilitatorSectionTitle => 'Local health facilitator';

  @override
  String get healthFacilitatorTitle => 'Health Facilitator';

  @override
  String get healthFacilitatorSubtitle =>
      'Save the details of your closest health facilitator.';

  @override
  String get healthFacilitatorName => 'Facilitator Name';

  @override
  String get healthFacilitatorNameHint => 'Enter the facilitator\'s name';

  @override
  String get healthFacilitatorAddress => 'Address';

  @override
  String get healthFacilitatorAddressHint => 'Enter the address';

  @override
  String get healthFacilitatorPhone => 'Phone Number';

  @override
  String get healthFacilitatorPhoneHint => 'Enter the phone number';

  @override
  String get healthFacilitatorSave => 'Save';

  @override
  String get healthFacilitatorSaveError =>
      'Could not save health facilitator details.';

  @override
  String get healthFacilitatorBack => 'Back';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageTitle => 'Choose language';

  @override
  String get settingsNepali => 'Nepali';

  @override
  String get settingsEnglish => 'English';
}
