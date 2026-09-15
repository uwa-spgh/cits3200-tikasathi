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
  String get childSexUnknown => 'Not specified';

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
  String get childVaccineRecord => 'Vaccine record';

  @override
  String get childVaccineHistory => 'Vaccine history';

  @override
  String get childActionRecordDose => 'Log Vaccine';

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
  String get childVaccinationOverdue => 'Vaccination overdue';

  @override
  String get childFollowingVaccine => 'Following vaccine (later)';

  @override
  String get childAllVaccinesCompleted =>
      'All childhood immunisations completed!';

  @override
  String get childFinalScheduledVaccine => 'Final scheduled vaccine';

  @override
  String get childVaccineRecordsAndHistory => 'Vaccine records & history';

  @override
  String get childVaccineRecordsAndHistorySubtitle =>
      'Review and update recorded doses';

  @override
  String get vaccineHistoryFilterAgeAppropriate => 'Age-appropriate only';

  @override
  String get vaccineHistoryFilterAll => 'Show all vaccines';

  @override
  String get vaccineHistorySaveChanges => 'Save Changes';

  @override
  String get vaccineHistorySavedSuccess =>
      'Vaccine history updated successfully';

  @override
  String vaccineHistoryAdministeredOn(String date) {
    return 'Given on $date';
  }

  @override
  String vaccineHistoryDueAt(String date) {
    return 'Due: $date';
  }

  @override
  String get healthFacilitatorSaveAction => 'Save your closest health facility';

  @override
  String get healthFacilitatorSavedHeading => 'Your local health facility';

  @override
  String get healthFacilitatorTitle => 'Health Facility';

  @override
  String get healthFacilitatorSubtitle =>
      'Save the details of your closest health facility.';

  @override
  String get healthFacilitatorName => 'Facility Name';

  @override
  String get healthFacilitatorNameHint => 'Enter the facility\'s name';

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
      'Could not save health facility details.';

  @override
  String get healthFacilitatorBack => 'Back';

  @override
  String get healthFacilitySaveAction => 'Save your closest health facility';

  @override
  String get healthFacilitySavedHeading => 'Your local health facility';

  @override
  String get healthFacilityTitle => 'Health Facility';

  @override
  String get healthFacilitySubtitle =>
      'Save the details of your closest health facility.';

  @override
  String get healthFacilityName => 'Facility Name';

  @override
  String get healthFacilityNameHint => 'Enter the facility\'s name';

  @override
  String get healthFacilityAddress => 'Address';

  @override
  String get healthFacilityAddressHint => 'Enter the address';

  @override
  String get healthFacilityPhone => 'Phone Number';

  @override
  String get healthFacilityPhoneHint => 'Enter the phone number';

  @override
  String get healthFacilitySave => 'Save';

  @override
  String get healthFacilitySaveError =>
      'Could not save health facility details.';

  @override
  String get healthFacilityBack => 'Back';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageTitle => 'Choose language';

  @override
  String get settingsNepali => 'Nepali';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsLanguageSaveError => 'Could not save language.';

  @override
  String appLanguageLoadError(Object error) {
    return 'Unable to load language settings: $error';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navLearn => 'Learn';

  @override
  String get navSettings => 'Settings';

  @override
  String get onboardingWelcome => 'Welcome!';

  @override
  String get onboardingLanguagePrompt =>
      'Please select your language / कृपया आफ्नो भाषा छान्नुहोस्';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingCaregiverTitle => 'Caregiver Details';

  @override
  String get onboardingCaregiverSubtitle =>
      'Please enter your information so we can set up the app.';

  @override
  String get onboardingCaregiverNameLabel => '👩‍🦰 Full Name';

  @override
  String get onboardingCaregiverNameHint => 'Enter your full name';

  @override
  String get onboardingCaregiverPhoneLabel => '📱 Phone Number';

  @override
  String get onboardingCaregiverPhoneHint => 'Enter your phone number';

  @override
  String get onboardingCaregiverAddressLabel => '🏠 Address (Optional)';

  @override
  String get onboardingCaregiverAddressHint => 'Enter your street address';

  @override
  String onboardingStepLabel(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingChildNameLabel => '👶 Child\'s name';

  @override
  String get onboardingChildNameHint => 'Enter full name';

  @override
  String get onboardingChildDobLabel => '📅 Date of Birth';

  @override
  String get onboardingChildDateDayHint => 'DD';

  @override
  String get onboardingChildDateMonthHint => 'MM';

  @override
  String get onboardingChildDateYearHint => 'YYYY';

  @override
  String get onboardingChildGenderLabel => '⚥ Gender';

  @override
  String get onboardingChildGenderGirl => 'Girl';

  @override
  String get onboardingChildGenderBoy => 'Boy';

  @override
  String get onboardingFinishSetup => 'Finish Setup';

  @override
  String get onboardingErrorEmptyName => 'Please enter child\'s name';

  @override
  String get onboardingErrorInvalidDate => 'Please enter a valid Date of Birth';

  @override
  String get onboardingErrorInvalidDob => 'Invalid Date of Birth';

  @override
  String onboardingErrorSaveSetup(Object error) {
    return 'Error saving setup: $error';
  }

  @override
  String get homeTitle => 'Your children';

  @override
  String get homeAddChildButton => '+ Add child';

  @override
  String get homeActionAddChild => 'Add child';

  @override
  String get homeActionChildDetails => 'Child details';

  @override
  String get homeActionRecordDose => 'Log vaccine';

  @override
  String homeActionPlaceholder(String action) {
    return 'Placeholder action: $action';
  }

  @override
  String get recordDoseTitle => 'Log vaccine';

  @override
  String recordDoseSubtitle(String childName) {
    return 'Tick each vaccine $childName was given today.';
  }

  @override
  String get recordDoseChangeDate => 'Change';

  @override
  String recordDoseDoseLabel(String vaccineCode, int doseNumber) {
    return '$vaccineCode (Dose $doseNumber)';
  }

  @override
  String recordDoseDueLabel(String date) {
    return 'Due $date';
  }

  @override
  String recordDoseOverdueLabel(String date) {
    return 'Overdue since $date';
  }

  @override
  String recordDoseNoneDue(String childName) {
    return '$childName has no doses due right now.';
  }

  @override
  String get recordDoseSaveEmpty => 'Tick a vaccine first';

  @override
  String recordDoseSaveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save $count doses',
      one: 'Save 1 dose',
    );
    return '$_temp0';
  }

  @override
  String recordDoseSuccess(int count, String childName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses logged for $childName',
      one: '1 dose logged for $childName',
    );
    return '$_temp0';
  }

  @override
  String get recordDoseError => 'Could not save. Please try again.';

  @override
  String get recordDoseDateTitle => 'Date given';

  @override
  String recordDoseDoseChip(int doseNumber) {
    return 'Dose $doseNumber';
  }

  @override
  String recordDoseSelectedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses selected',
      one: '1 dose selected',
      zero: 'No doses selected',
    );
    return '$_temp0';
  }

  @override
  String get recordDoseStepDate => 'Step 1 — Check the date';

  @override
  String get recordDoseStepSelect => 'Step 2 — Tick each vaccine given';

  @override
  String get recordDoseTapToChange => 'Tap to change';

  @override
  String get recordDoseTickedLabel => 'Ticked';

  @override
  String get recordDoseShowMore => 'Show more vaccines';

  @override
  String get recordDoseShowFewer => 'Show fewer vaccines';

  @override
  String get recordDoseToday => 'Today';

  @override
  String ageInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days old',
      one: '1 day old',
    );
    return '$_temp0';
  }

  @override
  String ageInMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months old',
      one: '1 month old',
    );
    return '$_temp0';
  }

  @override
  String ageInYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years old',
      one: '1 year old',
    );
    return '$_temp0';
  }

  @override
  String get homeSectionDueToday => 'Due today';

  @override
  String get homeSectionDueSoon => 'Due soon';

  @override
  String get homeSectionUpToDate => 'Up to date';

  @override
  String get homeEmptyStateTitle => 'No children added yet.';

  @override
  String get homeEmptyStateSubtitle =>
      'Add your first child to see upcoming vaccines here.';

  @override
  String get learnPlaceholderTitle => 'Learn';

  @override
  String get learnPlaceholderTitleNp => 'सिक्नुहोस्';

  @override
  String get childStatusSetupIncomplete => 'Awaiting setup completion';

  @override
  String get homeSectionAwaitingSetup => 'Awaiting setup completion';

  @override
  String get homeActionCompleteSetup => 'Complete setup';

  @override
  String get childSetupIncompleteBanner =>
      'Past vaccine history hasn\'t been set up yet. Complete setup to get an accurate schedule.';

  @override
  String get childActionCompleteSetup => 'Complete setup';

  @override
  String get childUrgencySetupRequired => 'Setup required';

  @override
  String get retroactiveVaccineTitle => 'Vaccine History';

  @override
  String retroactiveVaccineSubtitle(String childName) {
    return 'Please fill out the vaccines that $childName has already had.';
  }

  @override
  String get retroactiveVaccineShowAll => 'Show all vaccines';

  @override
  String get retroactiveVaccineShowAllSubtitle =>
      'Showing age-appropriate vaccines only.\nToggle to show all.';

  @override
  String retroactiveVaccineDateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String get retroactiveVaccineChangeDate => 'Change';

  @override
  String get retroactiveVaccineFinish => 'Finish';

  @override
  String get retroactiveVaccineSkip => 'Skip for now';

  @override
  String get vaccineRecordsDoseHeader => 'Vaccine dose';

  @override
  String get vaccineRecordsDateHeader => 'Date administered';

  @override
  String get vaccineRecordsReturn => 'Return';

  @override
  String get vaccineRecordsEmpty => 'There are no recorded vaccinations.';

  @override
  String get dose => 'Dose';

  @override
  String get vaccineScheduleTitle => 'Vaccine schedule';

  @override
  String get vaccineScheduleBack => 'Back';

  @override
  String get vaccineScheduleDoseHeader => 'Vaccine dose';

  @override
  String get vaccineScheduleDueHeader => 'Date due';

  @override
  String get vaccineScheduleReturn => 'Return';

  @override
  String get vaccineScheduleEmpty => 'There are no upcoming vaccines.';

  @override
  String get vaccineScheduleToday => 'Today';

  @override
  String vaccineScheduleInDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In # days',
      one: 'In # day',
    );
    return '$_temp0';
  }

  @override
  String vaccineScheduleInMonths(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In # months',
      one: 'In # month',
    );
    return '$_temp0';
  }

  @override
  String vaccineScheduleInYears(Object count) {
    return 'In $count yr';
  }

  @override
  String vaccineScheduleInYearsMonths(Object months, Object years) {
    return 'In $years yr $months mo';
  }

  @override
  String vaccineScheduleOverdueBy(Object count) {
    return 'Overdue by $count day(s)';
  }

  @override
  String get onboardingErrorFutureDob =>
      'Date of Birth cannot be in the future';

  @override
  String get overdueVaccinesDialogTitle => 'Missed Vaccines';

  @override
  String get overdueVaccinesDialogMessage =>
      'Visit health facility for missed vaccines.';

  @override
  String get overdueVaccinesNoticeBanner =>
      'Visit health facility for missed vaccines.';

  @override
  String get actionUnderstand => 'OK';
}
