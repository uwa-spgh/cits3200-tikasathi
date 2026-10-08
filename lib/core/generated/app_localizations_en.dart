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
  String get appBarBack => 'Back';

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
  String get childReadAloudStopTooltip => 'Stop reading aloud';

  @override
  String get childReadAloudNoContent => 'No text found to read aloud.';

  @override
  String get childReadAloudError =>
      'Could not read text aloud. Please check your device speech settings.';

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
  String get childVaccineRecordsAndHistory => 'Vaccine history';

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
  String get healthFacilityInvalidPhone => 'Please enter a valid phone number';

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
  String get manageProfilesTitle => 'Manage profiles';

  @override
  String get editCaregiverAction => 'Edit caregiver details';

  @override
  String get editChildAction => 'Edit child details';

  @override
  String get deleteChildAction => 'Delete child';

  @override
  String get editVaccineScheduleAction =>
      'Edit child\'s vaccination schedule (HEALTHCARE PROFESSIONAL ONLY)';

  @override
  String get healthcareProfessionalQuestion =>
      'Are you a healthcare professional?';

  @override
  String get healthcareProfessionalConfirm => 'Yes';

  @override
  String get healthcareProfessionalDecline => 'No';

  @override
  String get scheduleEditorTitle => 'Edit vaccine schedule';

  @override
  String scheduleEditorTitleForChild(String childName) {
    return 'Edit $childName\'s vaccine schedule';
  }

  @override
  String get scheduleEditorEmpty => 'No outstanding vaccines are scheduled.';

  @override
  String get scheduleEditorEdit => 'Edit scheduled vaccine';

  @override
  String get scheduleEditorVaccine => 'Vaccine';

  @override
  String get scheduleEditorDose => 'Dose number';

  @override
  String get scheduleEditorDueDate => 'Scheduled date';

  @override
  String get scheduleEditorSave => 'Save schedule changes';

  @override
  String get scheduleEditorSaveConfirmTitle => 'Save schedule changes?';

  @override
  String get scheduleEditorSaveConfirmMessage =>
      'Save these healthcare professional changes to the child\'s vaccine schedule?';

  @override
  String get scheduleEditorRestore => 'Restore default vaccine schedule';

  @override
  String get scheduleEditorRestoreTitle => 'Restore default vaccine schedule?';

  @override
  String get scheduleEditorRestoreMessage =>
      'This will remove all healthcare professional changes and restore the standard vaccination schedule for this child. Vaccination history will not be changed.';

  @override
  String get scheduleEditorRestoreConfirm => 'Restore';

  @override
  String get scheduleEditorInvalidDose =>
      'That vaccine and dose combination is not valid.';

  @override
  String get scheduleEditorDuplicateDose =>
      'That vaccine and dose is already scheduled for this child.';

  @override
  String get scheduleEditorAdministeredDose =>
      'That vaccine and dose has already been administered.';

  @override
  String get scheduleEditorSaveSuccess => 'Vaccine schedule updated.';

  @override
  String get scheduleEditorSaveError =>
      'Could not update the vaccine schedule.';

  @override
  String get scheduleEditorRemove => 'Remove from schedule';

  @override
  String get scheduleEditorRemoveConfirm => 'Remove';

  @override
  String get scheduleEditorDueDateChange => 'Change scheduled date?';

  @override
  String get scheduleEditorRemoveTitle => 'Remove vaccine from schedule?';

  @override
  String scheduleEditorRemoveMessage(Object vaccineCode, Object doseNumber) {
    return 'Are you sure you want to remove $vaccineCode dose $doseNumber from this child\'s vaccine schedule? This will not affect vaccination history.';
  }

  @override
  String scheduleEditorRemoveSuccess(
      Object vaccineCode, Object doseNumber, Object childName) {
    return '$vaccineCode dose $doseNumber removed from $childName\'s schedule.';
  }

  @override
  String get editCaregiverTitle => 'Edit caregiver details';

  @override
  String get editChildTitle => 'Edit child details';

  @override
  String editChildTitleWithName(String childName) {
    return 'Edit $childName\'s details';
  }

  @override
  String get profileSave => 'Save';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileContinue => 'Continue';

  @override
  String get profileBack => 'Back';

  @override
  String get profileLoadError => 'Could not load profile details.';

  @override
  String get profileSaveError => 'Could not save profile details.';

  @override
  String get profileInvalidChild => 'Please enter a name and date of birth.';

  @override
  String get profileChildNotFound => 'Child details could not be found.';

  @override
  String get selectChildTitle => 'Select a child';

  @override
  String get noChildrenMessage => 'No children have been added yet.';

  @override
  String get updateVaccinationScheduleTitle => 'Update vaccination schedule?';

  @override
  String updateVaccinationScheduleProfileName(String childName) {
    return 'Updating child profile: $childName';
  }

  @override
  String get updateVaccinationScheduleMessageFirst =>
      'Changing your child\'s date of birth or sex may change their vaccination schedule.';

  @override
  String get updateVaccinationScheduleMessageSecond =>
      'These changes will be saved and used until you change the details again.';

  @override
  String get updateVaccinationScheduleMessageThird =>
      'You can edit these details again later if needed.';

  @override
  String get deleteChildTitle => 'Delete child?';

  @override
  String deleteChildProfileName(String childName) {
    return 'Deleting child profile: $childName';
  }

  @override
  String get deleteChildMessageFirst =>
      'This will permanently delete this child\'s information and vaccination records.';

  @override
  String get deleteChildMessageUndo => 'This action cannot be undone.';

  @override
  String get deleteChildConfirm => 'Delete child';

  @override
  String get deleteChildSuccess => 'Child deleted.';

  @override
  String get deleteChildError => 'Could not delete child.';

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
  String get onboardingErrorEmptyCaregiverName =>
      'Please enter caregiver\'s name';

  @override
  String get onboardingErrorEmptyCaregiverPhone =>
      'Please enter caregiver\'s phone number';

  @override
  String get onboardingErrorInvalidPhone => 'Please enter a valid phone number';

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
  String get onboardingErrorFutureDob =>
      'Date of Birth cannot be in the future';

  @override
  String get onboardingErrorTooOldDob => 'Child must be under 18 years old';

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
  String get homeSectionOverdue => 'Overdue';

  @override
  String get homeSectionDueSoon => 'Due soon';

  @override
  String get homeSectionUpToDate => 'Up to date';

  @override
  String get homeScrollInstruction => 'Scroll down to see all children.';

  @override
  String get homeEmptyStateTitle => 'No children added yet.';

  @override
  String get homeEmptyStateSubtitle =>
      'Add your first child to see upcoming vaccines here.';

  @override
  String get learnTitle => 'Learn';

  @override
  String get learnMythLabel => 'Myth:';

  @override
  String get learnFactLabel => 'Fact:';

  @override
  String get learnTopic1Title => 'Why are vaccines important?';

  @override
  String get learnTopic1Body =>
      '**Vaccines keep your child safe.**\n• Some diseases can make a child very sick.\n• Some diseases can make a child weak for life.\n• Some diseases can kill a child.\n• Vaccines stop these diseases before they start.\n\n**Vaccines protect other children too.**\n• When many children are vaccinated, the disease cannot spread.\n• This keeps your family, your neighbours and your village safe.\n\n**Vaccines are free.**\n• Vaccines are free at the health post and immunisation clinics.\n\n**Your child needs all the doses.**\n• One dose is not enough for many vaccines.\n• Each dose helps your child\'s body become stronger.\n• Follow the dates in the app.';

  @override
  String get learnTopic2Title => 'When should your child get vaccines?';

  @override
  String get learnTopic2Body =>
      '• Your child needs different vaccines at different ages.\n• Some vaccines are given soon after birth.\n• Other vaccines are given when your child is 6, 10 and 14 weeks old.\n• More vaccines are given at 9, 12 and 15 months.\n• The app will remind you when your child is due for a vaccine.\n• Follow the vaccination schedule to keep your child protected.';

  @override
  String get learnTopic3Title => 'What if your child misses a vaccine?';

  @override
  String get learnTopic3Body =>
      '• Do not worry if your child misses a vaccine.\n• Take your child to the nearest health facility.\n• Show the health worker your child\'s vaccination card.\n• Tell the health worker which vaccines your child has already received.\n• The health worker can tell you which vaccine your child needs next.\n• Do not stop vaccination because your child missed a dose.';

  @override
  String get learnTopic4Title => 'Are vaccines safe?';

  @override
  String get learnTopic4Body =>
      '• Vaccines are given to protect your child from serious diseases.\n• Most children have only mild effects after vaccination.\n• Your child may have a mild fever.\n• Your child may have some pain or swelling where the injection was given.\n• Your child may be a little fussy or irritable for a short time.\n• These effects are usually temporary.';

  @override
  String get learnTopic5Title => 'What can happen after vaccination?';

  @override
  String get learnTopic5Body =>
      '**After the vaccine: what is normal**\nSome children have small problems after a vaccine. This is normal. It means the vaccine is working.\n• A little fever\n• Pain or swelling where the needle went in\n• Crying more than usual\n• Sleeping more than usual\n\n**What you can do**\n• Breastfeed your baby more often.\n• Keep your baby in light clothes. Do not wrap your baby too tightly.\n• Give your baby extra fluids if your baby is older than 6 months.\n• Do not rub or press the swollen place.\n• Ask the health worker before you give any medicine.\n\nThese problems go away in 1 to 2 days.\n\n**When to go to the health facility quickly**\nTake your child to the health facility right away if your child:\n• has a very high fever\n• has fits or shakes\n• cannot breastfeed or drink\n• has trouble breathing\n• will not stop crying for a long time\n• has swelling that is getting bigger\n• looks very weak or is hard to wake';

  @override
  String get learnTopic6Title => 'Vaccine myths and facts';

  @override
  String get learnTopic6Body =>
      '**Myth:** Vaccines make children sick.\n**Fact:** Vaccines are safe. They teach the body to fight disease. A small fever after the vaccine is normal and passes quickly.\n\n**Myth:** My child is healthy, so my child does not need vaccines.\n**Fact:** Vaccines work best before a child gets sick. Healthy children can catch these diseases too.\n\n**Myth:** If my child misses a vaccine, my child cannot get it anymore.\n**Fact:** Your child can still get it. Go to the health post as soon as you can.\n\n**Myth:** Breastfed babies do not need vaccines.\n**Fact:** Breast milk is very good for your baby. But it cannot stop these diseases. Your baby still needs vaccines.\n\n**Myth:** Diseases like polio and measles are gone, so vaccines are not needed.\n**Fact:** These diseases can still come back if children are not vaccinated.';

  @override
  String get learnTopic7Title => 'Keep your child\'s vaccination card safe';

  @override
  String get learnTopic7Body =>
      '• Keep your child\'s vaccination card in a safe place.\n• Take the card whenever you visit a health facility.\n• Ask the health worker to update the card after each vaccination.\n• Use the app to keep track of your child\'s vaccines.\n• Do not lose the vaccination card.';

  @override
  String get learnTopic8Title => 'Where can your child get vaccines?';

  @override
  String get learnTopic8Body =>
      '• Your child can receive vaccines at vaccination services and health facilities.\n• You may visit your nearest health facility.\n• If you are not sure where to go, ask a health worker.';

  @override
  String get learnTopic9Title => 'Remember';

  @override
  String get learnTopic9Body =>
      '• Vaccines help protect your child from serious diseases.\n• Give your child vaccines on time.\n• Keep your child\'s vaccination card safe.\n• Follow the vaccination schedule.\n• If your child misses a vaccine, visit a health facility.\n• If you have questions, ask a healthcare worker.';

  @override
  String get learnTopic10Title => 'What each vaccine protects against';

  @override
  String get learnTopic10Body => '';

  @override
  String get learnTopic10Table =>
      'Vaccine | Protects your child from\nBCG | Tuberculosis\nPentavalent | Five diseases, including diphtheria, whooping cough, tetanus, hepatitis B, Haemophilus influenzae type b (Hib) infection.\nPolio drops and polio injection | Polio\nRotavirus | Diarrhoea\nPCV | Pneumonia and brain fever\nMR | Measles and rubella\nJE | Japanese encephalitis (brain fever)\nTCV | Typhoid fever\nHPV (girls, at school in Grade 6) | Cancer of the womb mouth (cervical cancer) when older';

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
  String vaccineScheduleDueGroupSingular(String date, String vaccines) {
    return '$vaccines is due on $date';
  }

  @override
  String vaccineScheduleDueGroupPlural(String date, String vaccines) {
    return '$vaccines are due on $date';
  }

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
  String get overdueVaccinesDialogTitle => 'Missed Vaccines';

  @override
  String get overdueVaccinesDialogMessage =>
      'Visit health facility for missed vaccines.';

  @override
  String get overdueVaccinesNoticeBanner =>
      'Visit health facility for missed vaccines.';

  @override
  String get actionUnderstand => 'OK';

  @override
  String reminderTitleUpcoming(String childName) {
    return 'Vaccination reminder – $childName';
  }

  @override
  String reminderTitleMissed(String childName) {
    return 'Vaccination missed – $childName';
  }

  @override
  String reminderTitleOverdue(String childName) {
    return 'Vaccination overdue – $childName';
  }

  @override
  String reminderUpcoming(String vaccineName, String date) {
    return 'Your child is due for $vaccineName on $date. Please visit your nearest health post or immunisation clinic.';
  }

  @override
  String get reminderLeadTomorrow =>
      'Tomorrow is the scheduled vaccination day.';

  @override
  String get reminderLeadToday => 'Today is your child\'s vaccination day.';

  @override
  String reminderFacility(String facility) {
    return 'Your saved health facility: $facility.';
  }

  @override
  String reminderMissedYesterday(String vaccineName, String date) {
    return '$vaccineName was due on $date and has not been recorded yet. Completing every dose on time keeps your child protected. Please visit your nearest health post.';
  }

  @override
  String reminderMissedWeek(String vaccineName) {
    return '$vaccineName has now been missed for a week. Contact your nearest health facility about catch-up vaccination so your child stays protected.';
  }

  @override
  String reminderOverdue(String vaccineName) {
    return '$vaccineName is overdue. Contact your nearest health facility for catch-up vaccination.';
  }

  @override
  String get backupSectionTitle => 'Backup';

  @override
  String get backupExportAction => 'Export backup';

  @override
  String get backupImportAction => 'Import backup';

  @override
  String get backupPrivacyNote =>
      'Keep this file somewhere safe and only share it with people you trust. It contains your child\'s health information.';

  @override
  String get backupPhoneChangeNote =>
      'Your records do not move to a new phone by themselves. Before changing phones, export a backup.';

  @override
  String get backupReplaceTitle => 'Replace data on this phone?';

  @override
  String get backupReplaceMessage =>
      'This will replace all data on this phone. Continue?';

  @override
  String get backupReplaceConfirm => 'Continue';

  @override
  String get backupExportSuccess => 'Backup file ready to save.';

  @override
  String get backupImportSuccess => 'Backup imported.';

  @override
  String get backupExportError => 'Could not export the backup.';

  @override
  String get backupImportError => 'Could not import the backup.';

  @override
  String get backupInvalidFile =>
      'This file is not a TikaSathi backup this app can read.';

  @override
  String get databaseLockedTitle => 'Your saved data cannot be opened';

  @override
  String get databaseLockedMessage =>
      'This phone no longer has the key that protects the data in TikaSathi, so the data cannot be read. This can happen after the phone\'s security is reset. If you have a backup file, you can import it after starting fresh.';

  @override
  String get databaseLockedAction => 'Start fresh';

  @override
  String get databaseLockedError => 'Could not start fresh. Please try again.';
}
