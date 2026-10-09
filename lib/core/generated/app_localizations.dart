import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'TikaSathi'**
  String get appTitle;

  /// Title shown at the top of the child profile screen
  ///
  /// In en, this message translates to:
  /// **'Child Page'**
  String get childPageTitle;

  /// Title shown at the top of the child profile screen with child name
  ///
  /// In en, this message translates to:
  /// **'{childName}\'s page'**
  String childPageTitleWithName(String childName);

  /// Loading message while the child details are being fetched
  ///
  /// In en, this message translates to:
  /// **'Loading child details...'**
  String get childLoading;

  /// Shown when the selected child cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Child profile not found.'**
  String get childNotFound;

  /// Status label for a child who has a vaccine due today
  ///
  /// In en, this message translates to:
  /// **'Vaccination due today'**
  String get childVaccinationDueToday;

  /// Status label for a child with a vaccine due within a short period
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get childVaccinationDueSoon;

  /// Status label for a child with no current due vaccines
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get childVaccinationUpToDate;

  /// Label for the next scheduled vaccine
  ///
  /// In en, this message translates to:
  /// **'Next vaccine'**
  String get childNextVaccine;

  /// Shown in next vaccine card when there is no upcoming vaccine
  ///
  /// In en, this message translates to:
  /// **'No upcoming vaccines'**
  String get childNoUpcomingVaccines;

  /// Born date label in child summary card
  ///
  /// In en, this message translates to:
  /// **'Born {dateText}'**
  String childBornOn(String dateText);

  /// Label for the date on which the next vaccine is due
  ///
  /// In en, this message translates to:
  /// **'Due on'**
  String get childDueOn;

  /// Label for the child's sex
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get childSexLabel;

  /// Label for the child's date of birth
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get childDobLabel;

  /// Male sex option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get childSexMale;

  /// Female sex option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get childSexFemale;

  /// Fallback label when a child's sex is unavailable
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get childSexUnknown;

  /// Shown when a child has no due vaccines
  ///
  /// In en, this message translates to:
  /// **'No due vaccines'**
  String get childNoDueVaccines;

  /// Snack bar message for the unavailable read-aloud action
  ///
  /// In en, this message translates to:
  /// **'Read aloud is not available yet.'**
  String get childReadAloudUnavailable;

  /// Tooltip text for the read-aloud action
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get childReadAloudTooltip;

  /// Tooltip text when read aloud is currently active to allow stopping it
  ///
  /// In en, this message translates to:
  /// **'Stop reading aloud'**
  String get childReadAloudStopTooltip;

  /// Message shown when there is no text available to read aloud
  ///
  /// In en, this message translates to:
  /// **'No text found to read aloud.'**
  String get childReadAloudNoContent;

  /// Error message when text-to-speech fails on device
  ///
  /// In en, this message translates to:
  /// **'Could not read text aloud. Please check your device speech settings.'**
  String get childReadAloudError;

  /// Tooltip for the back button on child page
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get childBackTooltip;

  /// Title for vaccine schedule quick action card
  ///
  /// In en, this message translates to:
  /// **'Vaccine schedule'**
  String get childVaccineSchedule;

  /// Title for vaccine record quick action card
  ///
  /// In en, this message translates to:
  /// **'Vaccine record'**
  String get childVaccineRecord;

  /// Title for vaccine history quick action card
  ///
  /// In en, this message translates to:
  /// **'Vaccine history'**
  String get childVaccineHistory;

  /// Title of the card on the child page that opens the log dose screen
  ///
  /// In en, this message translates to:
  /// **'Log Vaccine'**
  String get childActionRecordDose;

  /// Snack bar message for vaccine schedule action not implemented
  ///
  /// In en, this message translates to:
  /// **'Vaccine schedule is not implemented yet.'**
  String get childScheduleNotImplemented;

  /// Snack bar message for vaccine history action not implemented
  ///
  /// In en, this message translates to:
  /// **'Vaccine history is not implemented yet.'**
  String get childHistoryNotImplemented;

  /// Generic message for not-yet-implemented features
  ///
  /// In en, this message translates to:
  /// **'Not implemented yet.'**
  String get childNotImplementedYet;

  /// Confirmation button text for simple dialogs
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get childDialogOk;

  /// Clear note about unavailable functionality on the child screen
  ///
  /// In en, this message translates to:
  /// **'Record vaccine and clinic lookup are not available yet in this version.'**
  String get childMissingFeatureNote;

  /// Status label for a child with an overdue vaccine
  ///
  /// In en, this message translates to:
  /// **'Vaccination overdue'**
  String get childVaccinationOverdue;

  /// Label for the subsequent scheduled vaccine after the next one
  ///
  /// In en, this message translates to:
  /// **'Following vaccine (later)'**
  String get childFollowingVaccine;

  /// Shown when all vaccines in the schedule have been completed
  ///
  /// In en, this message translates to:
  /// **'All childhood immunisations completed!'**
  String get childAllVaccinesCompleted;

  /// Shown when only one dose remains in the schedule
  ///
  /// In en, this message translates to:
  /// **'Final scheduled vaccine'**
  String get childFinalScheduledVaccine;

  /// Title for the unified vaccine history quick action card
  ///
  /// In en, this message translates to:
  /// **'Vaccine history'**
  String get childVaccineRecordsAndHistory;

  /// Subtitle for the unified vaccine records and history card
  ///
  /// In en, this message translates to:
  /// **'Review and update recorded doses'**
  String get childVaccineRecordsAndHistorySubtitle;

  /// Toggle option to show only age-appropriate vaccines
  ///
  /// In en, this message translates to:
  /// **'Age-appropriate only'**
  String get vaccineHistoryFilterAgeAppropriate;

  /// Toggle option to show all vaccines
  ///
  /// In en, this message translates to:
  /// **'Show all vaccines'**
  String get vaccineHistoryFilterAll;

  /// Button to save changes made in vaccine history
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get vaccineHistorySaveChanges;

  /// Snack bar message when vaccine history is saved
  ///
  /// In en, this message translates to:
  /// **'Vaccine history updated successfully'**
  String get vaccineHistorySavedSuccess;

  /// Label showing when a vaccine was administered
  ///
  /// In en, this message translates to:
  /// **'Given on {date}'**
  String vaccineHistoryAdministeredOn(String date);

  /// Label showing when an unadministered vaccine is due
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String vaccineHistoryDueAt(String date);

  /// No description provided for @healthFacilitatorSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save your closest health facility'**
  String get healthFacilitatorSaveAction;

  /// No description provided for @healthFacilitatorSavedHeading.
  ///
  /// In en, this message translates to:
  /// **'Your local health facility'**
  String get healthFacilitatorSavedHeading;

  /// No description provided for @healthFacilitatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Facility'**
  String get healthFacilitatorTitle;

  /// No description provided for @healthFacilitatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save the details of your closest health facility.'**
  String get healthFacilitatorSubtitle;

  /// No description provided for @healthFacilitatorName.
  ///
  /// In en, this message translates to:
  /// **'Facility Name'**
  String get healthFacilitatorName;

  /// No description provided for @healthFacilitatorNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the facility\'s name'**
  String get healthFacilitatorNameHint;

  /// No description provided for @healthFacilitatorAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get healthFacilitatorAddress;

  /// No description provided for @healthFacilitatorAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the address'**
  String get healthFacilitatorAddressHint;

  /// No description provided for @healthFacilitatorPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get healthFacilitatorPhone;

  /// No description provided for @healthFacilitatorPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number'**
  String get healthFacilitatorPhoneHint;

  /// No description provided for @healthFacilitatorSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get healthFacilitatorSave;

  /// No description provided for @healthFacilitatorSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save health facility details.'**
  String get healthFacilitatorSaveError;

  /// No description provided for @healthFacilitatorBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get healthFacilitatorBack;

  /// No description provided for @healthFacilitySaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save your closest health facility'**
  String get healthFacilitySaveAction;

  /// No description provided for @healthFacilitySavedHeading.
  ///
  /// In en, this message translates to:
  /// **'Your local health facility'**
  String get healthFacilitySavedHeading;

  /// No description provided for @healthFacilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Facility'**
  String get healthFacilityTitle;

  /// No description provided for @healthFacilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save the details of your closest health facility.'**
  String get healthFacilitySubtitle;

  /// No description provided for @healthFacilityName.
  ///
  /// In en, this message translates to:
  /// **'Facility Name'**
  String get healthFacilityName;

  /// No description provided for @healthFacilityNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the facility\'s name'**
  String get healthFacilityNameHint;

  /// No description provided for @healthFacilityAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get healthFacilityAddress;

  /// No description provided for @healthFacilityAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the address'**
  String get healthFacilityAddressHint;

  /// No description provided for @healthFacilityPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get healthFacilityPhone;

  /// No description provided for @healthFacilityPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number'**
  String get healthFacilityPhoneHint;

  /// No description provided for @healthFacilityInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get healthFacilityInvalidPhone;

  /// No description provided for @healthFacilitySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get healthFacilitySave;

  /// No description provided for @healthFacilitySaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save health facility details.'**
  String get healthFacilitySaveError;

  /// No description provided for @healthFacilityBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get healthFacilityBack;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsNepali.
  ///
  /// In en, this message translates to:
  /// **'Nepali'**
  String get settingsNepali;

  /// No description provided for @settingsEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsEnglish;

  /// No description provided for @settingsLanguageSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save language.'**
  String get settingsLanguageSaveError;

  /// No description provided for @manageProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage profiles'**
  String get manageProfilesTitle;

  /// No description provided for @editCaregiverAction.
  ///
  /// In en, this message translates to:
  /// **'Edit caregiver details'**
  String get editCaregiverAction;

  /// No description provided for @editChildAction.
  ///
  /// In en, this message translates to:
  /// **'Edit child details'**
  String get editChildAction;

  /// No description provided for @deleteChildAction.
  ///
  /// In en, this message translates to:
  /// **'Delete child'**
  String get deleteChildAction;

  /// No description provided for @editVaccineScheduleAction.
  ///
  /// In en, this message translates to:
  /// **'Edit child\'s vaccination schedule (HEALTHCARE PROFESSIONAL ONLY)'**
  String get editVaccineScheduleAction;

  /// No description provided for @healthcareProfessionalQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you a healthcare professional?'**
  String get healthcareProfessionalQuestion;

  /// No description provided for @healthcareProfessionalConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get healthcareProfessionalConfirm;

  /// No description provided for @healthcareProfessionalDecline.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get healthcareProfessionalDecline;

  /// No description provided for @scheduleEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit vaccine schedule'**
  String get scheduleEditorTitle;

  /// No description provided for @scheduleEditorTitleForChild.
  ///
  /// In en, this message translates to:
  /// **'Edit {childName}\'s vaccine schedule'**
  String scheduleEditorTitleForChild(String childName);

  /// No description provided for @scheduleEditorEmpty.
  ///
  /// In en, this message translates to:
  /// **'No outstanding vaccines are scheduled.'**
  String get scheduleEditorEmpty;

  /// No description provided for @scheduleEditorEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit scheduled vaccine'**
  String get scheduleEditorEdit;

  /// No description provided for @scheduleEditorVaccine.
  ///
  /// In en, this message translates to:
  /// **'Vaccine'**
  String get scheduleEditorVaccine;

  /// No description provided for @scheduleEditorDose.
  ///
  /// In en, this message translates to:
  /// **'Dose number'**
  String get scheduleEditorDose;

  /// No description provided for @scheduleEditorDueDate.
  ///
  /// In en, this message translates to:
  /// **'Scheduled date'**
  String get scheduleEditorDueDate;

  /// No description provided for @scheduleEditorSave.
  ///
  /// In en, this message translates to:
  /// **'Save schedule changes'**
  String get scheduleEditorSave;

  /// No description provided for @scheduleEditorSaveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Save schedule changes?'**
  String get scheduleEditorSaveConfirmTitle;

  /// No description provided for @scheduleEditorSaveConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Save these healthcare professional changes to the child\'s vaccine schedule?'**
  String get scheduleEditorSaveConfirmMessage;

  /// No description provided for @scheduleEditorRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore default vaccine schedule'**
  String get scheduleEditorRestore;

  /// No description provided for @scheduleEditorRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore default vaccine schedule?'**
  String get scheduleEditorRestoreTitle;

  /// No description provided for @scheduleEditorRestoreMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all healthcare professional changes and restore the standard vaccination schedule for this child. Vaccination history will not be changed.'**
  String get scheduleEditorRestoreMessage;

  /// No description provided for @scheduleEditorRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get scheduleEditorRestoreConfirm;

  /// No description provided for @scheduleEditorInvalidDose.
  ///
  /// In en, this message translates to:
  /// **'That vaccine and dose combination is not valid.'**
  String get scheduleEditorInvalidDose;

  /// No description provided for @scheduleEditorDuplicateDose.
  ///
  /// In en, this message translates to:
  /// **'That vaccine and dose is already scheduled for this child.'**
  String get scheduleEditorDuplicateDose;

  /// No description provided for @scheduleEditorAdministeredDose.
  ///
  /// In en, this message translates to:
  /// **'That vaccine and dose has already been administered.'**
  String get scheduleEditorAdministeredDose;

  /// No description provided for @scheduleEditorSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vaccine schedule updated.'**
  String get scheduleEditorSaveSuccess;

  /// No description provided for @scheduleEditorSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not update the vaccine schedule.'**
  String get scheduleEditorSaveError;

  /// No description provided for @scheduleEditorRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from schedule'**
  String get scheduleEditorRemove;

  /// No description provided for @scheduleEditorRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get scheduleEditorRemoveConfirm;

  /// No description provided for @scheduleEditorDueDateChange.
  ///
  /// In en, this message translates to:
  /// **'Change scheduled date?'**
  String get scheduleEditorDueDateChange;

  /// No description provided for @scheduleEditorRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove vaccine from schedule?'**
  String get scheduleEditorRemoveTitle;

  /// No description provided for @scheduleEditorRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {vaccineCode} dose {doseNumber} from this child\'s vaccine schedule? This will not affect vaccination history.'**
  String scheduleEditorRemoveMessage(Object vaccineCode, Object doseNumber);

  /// No description provided for @scheduleEditorRemoveSuccess.
  ///
  /// In en, this message translates to:
  /// **'{vaccineCode} dose {doseNumber} removed from {childName}\'s schedule.'**
  String scheduleEditorRemoveSuccess(
      Object vaccineCode, Object doseNumber, Object childName);

  /// No description provided for @editCaregiverTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit caregiver details'**
  String get editCaregiverTitle;

  /// No description provided for @editChildTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit child details'**
  String get editChildTitle;

  /// No description provided for @editChildTitleWithName.
  ///
  /// In en, this message translates to:
  /// **'Edit {childName}\'s details'**
  String editChildTitleWithName(String childName);

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get profileContinue;

  /// No description provided for @profileBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get profileBack;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile details.'**
  String get profileLoadError;

  /// No description provided for @profileSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile details.'**
  String get profileSaveError;

  /// No description provided for @profileInvalidChild.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name and date of birth.'**
  String get profileInvalidChild;

  /// No description provided for @profileChildNotFound.
  ///
  /// In en, this message translates to:
  /// **'Child details could not be found.'**
  String get profileChildNotFound;

  /// No description provided for @selectChildTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a child'**
  String get selectChildTitle;

  /// No description provided for @noChildrenMessage.
  ///
  /// In en, this message translates to:
  /// **'No children have been added yet.'**
  String get noChildrenMessage;

  /// No description provided for @updateVaccinationScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Update vaccination schedule?'**
  String get updateVaccinationScheduleTitle;

  /// No description provided for @updateVaccinationScheduleProfileName.
  ///
  /// In en, this message translates to:
  /// **'Updating child profile: {childName}'**
  String updateVaccinationScheduleProfileName(String childName);

  /// No description provided for @updateVaccinationScheduleMessageFirst.
  ///
  /// In en, this message translates to:
  /// **'Changing your child\'s date of birth or sex may change their vaccination schedule.'**
  String get updateVaccinationScheduleMessageFirst;

  /// No description provided for @updateVaccinationScheduleMessageSecond.
  ///
  /// In en, this message translates to:
  /// **'These changes will be saved and used until you change the details again.'**
  String get updateVaccinationScheduleMessageSecond;

  /// No description provided for @updateVaccinationScheduleMessageThird.
  ///
  /// In en, this message translates to:
  /// **'You can edit these details again later if needed.'**
  String get updateVaccinationScheduleMessageThird;

  /// No description provided for @deleteChildTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete child?'**
  String get deleteChildTitle;

  /// No description provided for @deleteChildProfileName.
  ///
  /// In en, this message translates to:
  /// **'Deleting child profile: {childName}'**
  String deleteChildProfileName(String childName);

  /// No description provided for @deleteChildMessageFirst.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this child\'s information and vaccination records.'**
  String get deleteChildMessageFirst;

  /// No description provided for @deleteChildMessageUndo.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteChildMessageUndo;

  /// No description provided for @deleteChildConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete child'**
  String get deleteChildConfirm;

  /// No description provided for @deleteChildSuccess.
  ///
  /// In en, this message translates to:
  /// **'Child deleted.'**
  String get deleteChildSuccess;

  /// No description provided for @deleteChildError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete child.'**
  String get deleteChildError;

  /// No description provided for @appLanguageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load language settings: {error}'**
  String appLanguageLoadError(Object error);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get onboardingWelcome;

  /// No description provided for @onboardingLanguagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select your language / कृपया आफ्नो भाषा छान्नुहोस्'**
  String get onboardingLanguagePrompt;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingCaregiverTitle.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Details'**
  String get onboardingCaregiverTitle;

  /// No description provided for @onboardingCaregiverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your information so we can set up the app.'**
  String get onboardingCaregiverSubtitle;

  /// No description provided for @onboardingCaregiverNameLabel.
  ///
  /// In en, this message translates to:
  /// **'👩‍🦰 Full Name'**
  String get onboardingCaregiverNameLabel;

  /// No description provided for @onboardingCaregiverNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get onboardingCaregiverNameHint;

  /// No description provided for @onboardingCaregiverPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'📱 Phone Number'**
  String get onboardingCaregiverPhoneLabel;

  /// No description provided for @onboardingCaregiverPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get onboardingCaregiverPhoneHint;

  /// No description provided for @onboardingCaregiverAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'🏠 Address (Optional)'**
  String get onboardingCaregiverAddressLabel;

  /// No description provided for @onboardingCaregiverAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your street address'**
  String get onboardingCaregiverAddressHint;

  /// No description provided for @onboardingErrorEmptyCaregiverName.
  ///
  /// In en, this message translates to:
  /// **'Please enter caregiver\'s name'**
  String get onboardingErrorEmptyCaregiverName;

  /// No description provided for @onboardingErrorEmptyCaregiverPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter caregiver\'s phone number'**
  String get onboardingErrorEmptyCaregiverPhone;

  /// No description provided for @onboardingErrorInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get onboardingErrorInvalidPhone;

  /// No description provided for @onboardingStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepLabel(Object current, Object total);

  /// No description provided for @onboardingChildNameLabel.
  ///
  /// In en, this message translates to:
  /// **'👶 Child\'s name'**
  String get onboardingChildNameLabel;

  /// No description provided for @onboardingChildNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get onboardingChildNameHint;

  /// No description provided for @onboardingChildDobLabel.
  ///
  /// In en, this message translates to:
  /// **'📅 Date of Birth'**
  String get onboardingChildDobLabel;

  /// No description provided for @onboardingChildDateDayHint.
  ///
  /// In en, this message translates to:
  /// **'DD'**
  String get onboardingChildDateDayHint;

  /// No description provided for @onboardingChildDateMonthHint.
  ///
  /// In en, this message translates to:
  /// **'MM'**
  String get onboardingChildDateMonthHint;

  /// No description provided for @onboardingChildDateYearHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY'**
  String get onboardingChildDateYearHint;

  /// No description provided for @onboardingChildGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'⚥ Gender'**
  String get onboardingChildGenderLabel;

  /// No description provided for @onboardingChildGenderGirl.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get onboardingChildGenderGirl;

  /// No description provided for @onboardingChildGenderBoy.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get onboardingChildGenderBoy;

  /// No description provided for @onboardingFinishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish Setup'**
  String get onboardingFinishSetup;

  /// No description provided for @onboardingErrorEmptyName.
  ///
  /// In en, this message translates to:
  /// **'Please enter child\'s name'**
  String get onboardingErrorEmptyName;

  /// No description provided for @onboardingErrorInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Date of Birth'**
  String get onboardingErrorInvalidDate;

  /// No description provided for @onboardingErrorFutureDob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth cannot be in the future'**
  String get onboardingErrorFutureDob;

  /// No description provided for @onboardingErrorTooOldDob.
  ///
  /// In en, this message translates to:
  /// **'Child must be under 18 years old'**
  String get onboardingErrorTooOldDob;

  /// No description provided for @onboardingErrorSaveSetup.
  ///
  /// In en, this message translates to:
  /// **'Error saving setup: {error}'**
  String onboardingErrorSaveSetup(Object error);

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your children'**
  String get homeTitle;

  /// No description provided for @homeAddChildButton.
  ///
  /// In en, this message translates to:
  /// **'+ Add child'**
  String get homeAddChildButton;

  /// No description provided for @homeActionAddChild.
  ///
  /// In en, this message translates to:
  /// **'Add child'**
  String get homeActionAddChild;

  /// No description provided for @homeActionChildDetails.
  ///
  /// In en, this message translates to:
  /// **'Child details'**
  String get homeActionChildDetails;

  /// No description provided for @homeActionRecordDose.
  ///
  /// In en, this message translates to:
  /// **'Log vaccine'**
  String get homeActionRecordDose;

  /// Fallback snack bar message for an unimplemented home action
  ///
  /// In en, this message translates to:
  /// **'Placeholder action: {action}'**
  String homeActionPlaceholder(String action);

  /// Title of the screen where a caregiver records doses a child has just been given
  ///
  /// In en, this message translates to:
  /// **'Log vaccine'**
  String get recordDoseTitle;

  /// Instruction shown under the log dose title
  ///
  /// In en, this message translates to:
  /// **'Tick each vaccine {childName} was given today.'**
  String recordDoseSubtitle(String childName);

  /// Button that opens the date picker for the administered date
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get recordDoseChangeDate;

  /// Label for a single vaccine dose in the list
  ///
  /// In en, this message translates to:
  /// **'{vaccineCode} (Dose {doseNumber})'**
  String recordDoseDoseLabel(String vaccineCode, int doseNumber);

  /// Secondary label showing when a dose was scheduled
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String recordDoseDueLabel(String date);

  /// Secondary label for a dose whose due date has passed
  ///
  /// In en, this message translates to:
  /// **'Overdue since {date}'**
  String recordDoseOverdueLabel(String date);

  /// Empty state when the child has nothing due today
  ///
  /// In en, this message translates to:
  /// **'{childName} has no doses due right now.'**
  String recordDoseNoneDue(String childName);

  /// Save button label while nothing is ticked
  ///
  /// In en, this message translates to:
  /// **'Tick a vaccine first'**
  String get recordDoseSaveEmpty;

  /// Save button label showing how many doses will be recorded
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Save 1 dose} other{Save {count} doses}}'**
  String recordDoseSaveCount(int count);

  /// Confirmation shown after doses are saved
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dose logged for {childName}} other{{count} doses logged for {childName}}}'**
  String recordDoseSuccess(int count, String childName);

  /// Shown when saving the doses fails
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get recordDoseError;

  /// Heading of the card holding the date the doses were administered
  ///
  /// In en, this message translates to:
  /// **'Date given'**
  String get recordDoseDateTitle;

  /// Chip showing which dose of a vaccine a row refers to
  ///
  /// In en, this message translates to:
  /// **'Dose {doseNumber}'**
  String recordDoseDoseChip(int doseNumber);

  /// Running count of ticked doses shown above the save button
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No doses selected} =1{1 dose selected} other{{count} doses selected}}'**
  String recordDoseSelectedSummary(int count);

  /// Heading above the administered date card
  ///
  /// In en, this message translates to:
  /// **'Step 1 — Check the date'**
  String get recordDoseStepDate;

  /// Heading above the list of doses
  ///
  /// In en, this message translates to:
  /// **'Step 2 — Tick each vaccine given'**
  String get recordDoseStepSelect;

  /// Hint telling the user the date card can be tapped
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get recordDoseTapToChange;

  /// Button revealing doses that are not due yet
  ///
  /// In en, this message translates to:
  /// **'Show more vaccines'**
  String get recordDoseShowMore;

  /// Button hiding doses that are not due yet
  ///
  /// In en, this message translates to:
  /// **'Show fewer vaccines'**
  String get recordDoseShowFewer;

  /// Badge shown when the selected date is today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get recordDoseToday;

  /// Age label in days for a child
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 day old} other {{count} days old}}'**
  String ageInDays(int count);

  /// Age label in months for a child
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 month old} other {{count} months old}}'**
  String ageInMonths(int count);

  /// Age label in years for a child
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 year old} other {{count} years old}}'**
  String ageInYears(int count);

  /// No description provided for @homeSectionDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get homeSectionDueToday;

  /// No description provided for @homeSectionOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get homeSectionOverdue;

  /// No description provided for @homeSectionDueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get homeSectionDueSoon;

  /// No description provided for @homeSectionUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get homeSectionUpToDate;

  /// No description provided for @homeScrollInstruction.
  ///
  /// In en, this message translates to:
  /// **'Scroll down to see all children.'**
  String get homeScrollInstruction;

  /// No description provided for @homeEmptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'No children added yet.'**
  String get homeEmptyStateTitle;

  /// No description provided for @homeEmptyStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first child to see upcoming vaccines here.'**
  String get homeEmptyStateSubtitle;

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnTitle;

  /// Label for a myth on the Learn page. Bold text in a Learn topic that exactly matches this label is shown in red.
  ///
  /// In en, this message translates to:
  /// **'Myth:'**
  String get learnMythLabel;

  /// Label for a fact on the Learn page. Bold text in a Learn topic that exactly matches this label is shown in green.
  ///
  /// In en, this message translates to:
  /// **'Fact:'**
  String get learnFactLabel;

  /// No description provided for @learnTopic1Title.
  ///
  /// In en, this message translates to:
  /// **'Why are vaccines important?'**
  String get learnTopic1Title;

  /// Expanded text for Learn topic 1. Separate paragraphs with a blank line (\n\n). Wrap text in **double asterisks** to make it bold.
  ///
  /// In en, this message translates to:
  /// **'**Vaccines keep your child safe.**\n• Some diseases can make a child very sick.\n• Some diseases can make a child weak for life.\n• Some diseases can kill a child.\n• Vaccines stop these diseases before they start.\n\n**Vaccines protect other children too.**\n• When many children are vaccinated, the disease cannot spread.\n• This keeps your family, your neighbours and your village safe.\n\n**Vaccines are free.**\n• Vaccines are free at the health post and immunisation clinics.\n\n**Your child needs all the doses.**\n• One dose is not enough for many vaccines.\n• Each dose helps your child\'s body become stronger.\n• Follow the dates in the app.'**
  String get learnTopic1Body;

  /// No description provided for @learnTopic2Title.
  ///
  /// In en, this message translates to:
  /// **'When should your child get vaccines?'**
  String get learnTopic2Title;

  /// Expanded text for Learn topic 2. Separate paragraphs with a blank line (\n\n). Wrap text in **double asterisks** to make it bold.
  ///
  /// In en, this message translates to:
  /// **'• Your child needs different vaccines at different ages.\n• Some vaccines are given soon after birth.\n• Other vaccines are given when your child is 6, 10 and 14 weeks old.\n• More vaccines are given at 9, 12 and 15 months.\n• The app will remind you when your child is due for a vaccine.\n• Follow the vaccination schedule to keep your child protected.'**
  String get learnTopic2Body;

  /// No description provided for @learnTopic3Title.
  ///
  /// In en, this message translates to:
  /// **'What if your child misses a vaccine?'**
  String get learnTopic3Title;

  /// Expanded text for Learn topic 3. Separate paragraphs with a blank line (\n\n). Wrap text in **double asterisks** to make it bold.
  ///
  /// In en, this message translates to:
  /// **'• Do not worry if your child misses a vaccine.\n• Take your child to the nearest health facility.\n• Show the health worker your child\'s vaccination card.\n• Tell the health worker which vaccines your child has already received.\n• The health worker can tell you which vaccine your child needs next.\n• Do not stop vaccination because your child missed a dose.'**
  String get learnTopic3Body;

  /// No description provided for @learnTopic4Title.
  ///
  /// In en, this message translates to:
  /// **'Are vaccines safe?'**
  String get learnTopic4Title;

  /// Expanded text for Learn topic 4. Separate paragraphs with a blank line (\n\n). Wrap text in **double asterisks** to make it bold.
  ///
  /// In en, this message translates to:
  /// **'• Vaccines are given to protect your child from serious diseases.\n• Most children have only mild effects after vaccination.\n• Your child may have a mild fever.\n• Your child may have some pain or swelling where the injection was given.\n• Your child may be a little fussy or irritable for a short time.\n• These effects are usually temporary.'**
  String get learnTopic4Body;

  /// No description provided for @learnTopic5Title.
  ///
  /// In en, this message translates to:
  /// **'What can happen after vaccination?'**
  String get learnTopic5Title;

  /// Expanded text for Learn topic 5. Separate paragraphs with a blank line (\n\n). Wrap text in **double asterisks** to make it bold.
  ///
  /// In en, this message translates to:
  /// **'**After the vaccine: what is normal**\nSome children have small problems after a vaccine. This is normal. It means the vaccine is working.\n• A little fever\n• Pain or swelling where the needle went in\n• Crying more than usual\n• Sleeping more than usual\n\n**What you can do**\n• Breastfeed your baby more often.\n• Keep your baby in light clothes. Do not wrap your baby too tightly.\n• Give your baby extra fluids if your baby is older than 6 months.\n• Do not rub or press the swollen place.\n• Ask the health worker before you give any medicine.\n\nThese problems go away in 1 to 2 days.\n\n**When to go to the health facility quickly**\nTake your child to the health facility right away if your child:\n• has a very high fever\n• has fits or shakes\n• cannot breastfeed or drink\n• has trouble breathing\n• will not stop crying for a long time\n• has swelling that is getting bigger\n• looks very weak or is hard to wake'**
  String get learnTopic5Body;

  /// No description provided for @learnTopic6Title.
  ///
  /// In en, this message translates to:
  /// **'Vaccine myths and facts'**
  String get learnTopic6Title;

  /// Expanded text for Learn topic 6. Separate paragraphs with a blank line (\n\n). Wrap text in **double asterisks** to make it bold.
  ///
  /// In en, this message translates to:
  /// **'**Myth:** Vaccines make children sick.\n**Fact:** Vaccines are safe. They teach the body to fight disease. A small fever after the vaccine is normal and passes quickly.\n\n**Myth:** My child is healthy, so my child does not need vaccines.\n**Fact:** Vaccines work best before a child gets sick. Healthy children can catch these diseases too.\n\n**Myth:** If my child misses a vaccine, my child cannot get it anymore.\n**Fact:** Your child can still get it. Go to the health post as soon as you can.\n\n**Myth:** Breastfed babies do not need vaccines.\n**Fact:** Breast milk is very good for your baby. But it cannot stop these diseases. Your baby still needs vaccines.\n\n**Myth:** Diseases like polio and measles are gone, so vaccines are not needed.\n**Fact:** These diseases can still come back if children are not vaccinated.'**
  String get learnTopic6Body;

  /// No description provided for @learnTopic7Title.
  ///
  /// In en, this message translates to:
  /// **'Keep your child\'s vaccination card safe'**
  String get learnTopic7Title;

  /// Expanded text for Learn topic 7. Separate paragraphs with a blank line (\n\n). Wrap text in **double asterisks** to make it bold.
  ///
  /// In en, this message translates to:
  /// **'• Keep your child\'s vaccination card in a safe place.\n• Take the card whenever you visit a health facility.\n• Ask the health worker to update the card after each vaccination.\n• Use the app to keep track of your child\'s vaccines.\n• Do not lose the vaccination card.'**
  String get learnTopic7Body;

  /// No description provided for @learnTopic8Title.
  ///
  /// In en, this message translates to:
  /// **'Where can your child get vaccines?'**
  String get learnTopic8Title;

  /// Expanded text for Learn topic 8. Separate paragraphs with a blank line (\n\n). Wrap text in **double asterisks** to make it bold.
  ///
  /// In en, this message translates to:
  /// **'• Your child can receive vaccines at vaccination services and health facilities.\n• You may visit your nearest health facility.\n• If you are not sure where to go, ask a health worker.'**
  String get learnTopic8Body;

  /// No description provided for @learnTopic9Title.
  ///
  /// In en, this message translates to:
  /// **'Remember'**
  String get learnTopic9Title;

  /// Expanded text for Learn topic 9. Separate paragraphs with a blank line (\n\n). Wrap text in **double asterisks** to make it bold.
  ///
  /// In en, this message translates to:
  /// **'• Vaccines help protect your child from serious diseases.\n• Give your child vaccines on time.\n• Keep your child\'s vaccination card safe.\n• Follow the vaccination schedule.\n• If your child misses a vaccine, visit a health facility.\n• If you have questions, ask a healthcare worker.'**
  String get learnTopic9Body;

  /// No description provided for @learnTopic10Title.
  ///
  /// In en, this message translates to:
  /// **'What each vaccine protects against'**
  String get learnTopic10Title;

  /// Expanded text for Learn topic 10, shown above its table. May be empty. Separate paragraphs with a blank line (\n\n). Wrap text in **double asterisks** to make it bold.
  ///
  /// In en, this message translates to:
  /// **''**
  String get learnTopic10Body;

  /// Table shown under Learn topic 10. One row per line; the first line is the header row. Separate cells with |.
  ///
  /// In en, this message translates to:
  /// **'Vaccine | Protects your child from\nBCG | Tuberculosis\nPentavalent | Five diseases, including diphtheria, whooping cough, tetanus, hepatitis B, Haemophilus influenzae type b (Hib) infection.\nPolio drops and polio injection | Polio\nRotavirus | Diarrhoea\nPCV | Pneumonia and brain fever\nMR | Measles and rubella\nJE | Japanese encephalitis (brain fever)\nTCV | Typhoid fever\nHPV (girls, at school in Grade 6) | Cancer of the womb mouth (cervical cancer) when older'**
  String get learnTopic10Table;

  /// No description provided for @childStatusSetupIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Awaiting setup completion'**
  String get childStatusSetupIncomplete;

  /// No description provided for @homeSectionAwaitingSetup.
  ///
  /// In en, this message translates to:
  /// **'Awaiting setup completion'**
  String get homeSectionAwaitingSetup;

  /// No description provided for @homeActionCompleteSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete setup'**
  String get homeActionCompleteSetup;

  /// No description provided for @childSetupIncompleteBanner.
  ///
  /// In en, this message translates to:
  /// **'Past vaccine history hasn\'t been set up yet. Complete setup to get an accurate schedule.'**
  String get childSetupIncompleteBanner;

  /// Spoken message for a child whose vaccine history setup is incomplete
  ///
  /// In en, this message translates to:
  /// **'{childName}\'s past vaccine history hasn\'t been set up yet. Please complete the setup to get an accurate vaccination schedule.'**
  String childSetupIncompleteSpeech(String childName);

  /// No description provided for @childActionCompleteSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete setup'**
  String get childActionCompleteSetup;

  /// No description provided for @childUrgencySetupRequired.
  ///
  /// In en, this message translates to:
  /// **'Setup required'**
  String get childUrgencySetupRequired;

  /// No description provided for @retroactiveVaccineTitle.
  ///
  /// In en, this message translates to:
  /// **'Vaccine History'**
  String get retroactiveVaccineTitle;

  /// No description provided for @retroactiveVaccineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please fill out the vaccines that {childName} has already had.'**
  String retroactiveVaccineSubtitle(String childName);

  /// No description provided for @retroactiveVaccineShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all vaccines'**
  String get retroactiveVaccineShowAll;

  /// No description provided for @retroactiveVaccineShowAllSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Showing age-appropriate vaccines only.\nToggle to show all.'**
  String get retroactiveVaccineShowAllSubtitle;

  /// No description provided for @retroactiveVaccineDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String retroactiveVaccineDateLabel(String date);

  /// No description provided for @retroactiveVaccineChangeDate.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get retroactiveVaccineChangeDate;

  /// No description provided for @retroactiveVaccineFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get retroactiveVaccineFinish;

  /// No description provided for @retroactiveVaccineSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get retroactiveVaccineSkip;

  /// No description provided for @vaccineRecordsDoseHeader.
  ///
  /// In en, this message translates to:
  /// **'Vaccine dose'**
  String get vaccineRecordsDoseHeader;

  /// No description provided for @vaccineRecordsDateHeader.
  ///
  /// In en, this message translates to:
  /// **'Date administered'**
  String get vaccineRecordsDateHeader;

  /// No description provided for @vaccineRecordsReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get vaccineRecordsReturn;

  /// No description provided for @vaccineRecordsEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no recorded vaccinations.'**
  String get vaccineRecordsEmpty;

  /// No description provided for @dose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// No description provided for @vaccineScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Vaccine schedule'**
  String get vaccineScheduleTitle;

  /// No description provided for @vaccineScheduleBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get vaccineScheduleBack;

  /// No description provided for @vaccineScheduleDoseHeader.
  ///
  /// In en, this message translates to:
  /// **'Vaccine dose'**
  String get vaccineScheduleDoseHeader;

  /// No description provided for @vaccineScheduleDueHeader.
  ///
  /// In en, this message translates to:
  /// **'Date due'**
  String get vaccineScheduleDueHeader;

  /// No description provided for @vaccineScheduleReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get vaccineScheduleReturn;

  /// No description provided for @vaccineScheduleEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no upcoming vaccines.'**
  String get vaccineScheduleEmpty;

  /// No description provided for @vaccineScheduleDueGroupSingular.
  ///
  /// In en, this message translates to:
  /// **'{vaccines} is due on {date}'**
  String vaccineScheduleDueGroupSingular(String date, String vaccines);

  /// No description provided for @vaccineScheduleDueGroupPlural.
  ///
  /// In en, this message translates to:
  /// **'{vaccines} are due on {date}'**
  String vaccineScheduleDueGroupPlural(String date, String vaccines);

  /// No description provided for @vaccineScheduleToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get vaccineScheduleToday;

  /// No description provided for @vaccineScheduleInDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {In # day} other {In # days}}'**
  String vaccineScheduleInDays(num count);

  /// No description provided for @vaccineScheduleInMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {In # month} other {In # months}}'**
  String vaccineScheduleInMonths(num count);

  /// No description provided for @vaccineScheduleInYears.
  ///
  /// In en, this message translates to:
  /// **'In {count} yr'**
  String vaccineScheduleInYears(Object count);

  /// No description provided for @vaccineScheduleInYearsMonths.
  ///
  /// In en, this message translates to:
  /// **'In {years} yr {months} mo'**
  String vaccineScheduleInYearsMonths(Object months, Object years);

  /// No description provided for @vaccineScheduleOverdueBy.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {count} day(s)'**
  String vaccineScheduleOverdueBy(Object count);

  /// No description provided for @overdueVaccinesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Missed Vaccines'**
  String get overdueVaccinesDialogTitle;

  /// No description provided for @overdueVaccinesDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Visit health facility for missed vaccines.'**
  String get overdueVaccinesDialogMessage;

  /// No description provided for @overdueVaccinesNoticeBanner.
  ///
  /// In en, this message translates to:
  /// **'Visit health facility for missed vaccines.'**
  String get overdueVaccinesNoticeBanner;

  /// No description provided for @actionUnderstand.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionUnderstand;

  /// DRAFT, NOT CLIENT-SUPPLIED. Title for a dose that is coming up. The brief fixes the body wording only, so the child's name goes in the title: it keeps the body word for word while letting caregivers with several children tell reminders apart.
  ///
  /// In en, this message translates to:
  /// **'Vaccination reminder – {childName}'**
  String reminderTitleUpcoming(String childName);

  /// DRAFT, NOT CLIENT-SUPPLIED. Title for the follow-ups after a dose was missed.
  ///
  /// In en, this message translates to:
  /// **'Vaccination missed – {childName}'**
  String reminderTitleMissed(String childName);

  /// DRAFT, NOT CLIENT-SUPPLIED. Title once a dose is more than a week overdue.
  ///
  /// In en, this message translates to:
  /// **'Vaccination overdue – {childName}'**
  String reminderTitleOverdue(String childName);

  /// CLIENT'S EXACT WORDING (brief section 5, push notification message). Do not reword. The brief also asks for the nearest immunisation service or outreach session in the week-before reminder; see the TODO in reminder_message.dart.
  ///
  /// In en, this message translates to:
  /// **'Your child is due for {vaccineName} on {date}. Please visit your nearest health post or immunisation clinic.'**
  String reminderUpcoming(String vaccineName, String date);

  /// Opens the day-before reminder, ahead of the client's exact push sentence (reminderUpcoming). The brief (section 5, 3-touch approach) asks this reminder to reinforce that tomorrow is the scheduled vaccination day; this is that phrase. Combining it with the push sentence is our reading of the brief and needs client sign-off.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow is the scheduled vaccination day.'**
  String get reminderLeadTomorrow;

  /// Opens the same-day reminder, ahead of the client's exact push sentence. The brief quotes this phrase directly for the final reminder. Combining it with the push sentence is our reading of the brief and needs client sign-off.
  ///
  /// In en, this message translates to:
  /// **'Today is your child\'s vaccination day.'**
  String get reminderLeadToday;

  /// DRAFT, NOT CLIENT-SUPPLIED. Added after the week-before, day-before and same-day reminders when the caregiver has saved a health facility. The brief asks these reminders for the location, where to attend, and facility details 'if available'; the only facility data the app holds is the one the caregiver saves on the home page. Kept as a separate sentence so the client's fixed wording is untouched.
  ///
  /// In en, this message translates to:
  /// **'Your saved health facility: {facility}.'**
  String reminderFacility(String facility);

  /// DRAFT, NEEDS CLIENT SIGN-OFF. Sent one day after a missed dose. The brief gives no exact wording here, only that it must carry the missed vaccine name, why finishing the schedule matters, and catch-up guidance where it applies.
  ///
  /// In en, this message translates to:
  /// **'{vaccineName} was due on {date} and has not been recorded yet. Completing every dose on time keeps your child protected. Please visit your nearest health post.'**
  String reminderMissedYesterday(String vaccineName, String date);

  /// DRAFT, NEEDS CLIENT SIGN-OFF. Sent one week after a missed dose, same reasoning as reminderMissedYesterday.
  ///
  /// In en, this message translates to:
  /// **'{vaccineName} has now been missed for a week. Contact your nearest health facility about catch-up vaccination so your child stays protected.'**
  String reminderMissedWeek(String vaccineName);

  /// CLIENT'S EXACT WORDING (brief section 5, overdue notification). Do not reword. Sent every fortnight once a dose is more than a week overdue.
  ///
  /// In en, this message translates to:
  /// **'{vaccineName} is overdue. Contact your nearest health facility for catch-up vaccination.'**
  String reminderOverdue(String vaccineName);

  /// No description provided for @backupSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupSectionTitle;

  /// No description provided for @backupExportAction.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get backupExportAction;

  /// No description provided for @backupImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get backupImportAction;

  /// No description provided for @backupPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Keep this file somewhere safe and only share it with people you trust. It contains your child\'s health information.'**
  String get backupPrivacyNote;

  /// No description provided for @backupPhoneChangeNote.
  ///
  /// In en, this message translates to:
  /// **'Your records do not move to a new phone by themselves. Before changing phones, export a backup.'**
  String get backupPhoneChangeNote;

  /// No description provided for @backupReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace data on this phone?'**
  String get backupReplaceTitle;

  /// No description provided for @backupReplaceMessage.
  ///
  /// In en, this message translates to:
  /// **'This will replace all data on this phone. Continue?'**
  String get backupReplaceMessage;

  /// No description provided for @backupReplaceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get backupReplaceConfirm;

  /// No description provided for @backupExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup file ready to save.'**
  String get backupExportSuccess;

  /// No description provided for @backupImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup imported.'**
  String get backupImportSuccess;

  /// No description provided for @backupExportError.
  ///
  /// In en, this message translates to:
  /// **'Could not export the backup.'**
  String get backupExportError;

  /// No description provided for @backupImportError.
  ///
  /// In en, this message translates to:
  /// **'Could not import the backup.'**
  String get backupImportError;

  /// No description provided for @backupInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'This file is not a TikaSathi backup this app can read.'**
  String get backupInvalidFile;

  /// No description provided for @databaseLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your saved data cannot be opened'**
  String get databaseLockedTitle;

  /// No description provided for @databaseLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'This phone no longer has the key that protects the data in TikaSathi, so the data cannot be read. This can happen after the phone\'s security is reset. If you have a backup file, you can import it after starting fresh.'**
  String get databaseLockedMessage;

  /// No description provided for @databaseLockedAction.
  ///
  /// In en, this message translates to:
  /// **'Start fresh'**
  String get databaseLockedAction;

  /// No description provided for @databaseLockedError.
  ///
  /// In en, this message translates to:
  /// **'Could not start fresh. Please try again.'**
  String get databaseLockedError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
