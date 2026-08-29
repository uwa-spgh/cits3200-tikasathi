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

  /// Title for vaccine history quick action card
  ///
  /// In en, this message translates to:
  /// **'Vaccine history'**
  String get childVaccineHistory;

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

  /// No description provided for @healthFacilitatorSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save your closest health facilitator'**
  String get healthFacilitatorSaveAction;

  /// No description provided for @healthFacilitatorSavedHeading.
  ///
  /// In en, this message translates to:
  /// **'Your local health facilitator'**
  String get healthFacilitatorSavedHeading;

  /// No description provided for @healthFacilitatorSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Local health facilitator'**
  String get healthFacilitatorSectionTitle;

  /// No description provided for @healthFacilitatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Facilitator'**
  String get healthFacilitatorTitle;

  /// No description provided for @healthFacilitatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save the details of your closest health facilitator.'**
  String get healthFacilitatorSubtitle;

  /// No description provided for @healthFacilitatorName.
  ///
  /// In en, this message translates to:
  /// **'Facilitator Name'**
  String get healthFacilitatorName;

  /// No description provided for @healthFacilitatorNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the facilitator\'s name'**
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
  /// **'Could not save health facilitator details.'**
  String get healthFacilitatorSaveError;

  /// No description provided for @healthFacilitatorBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get healthFacilitatorBack;

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

  /// No description provided for @onboardingErrorInvalidDob.
  ///
  /// In en, this message translates to:
  /// **'Invalid Date of Birth'**
  String get onboardingErrorInvalidDob;

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

  /// No description provided for @homeActionRecordVaccine.
  ///
  /// In en, this message translates to:
  /// **'Record vaccine'**
  String get homeActionRecordVaccine;

  /// No description provided for @homeActionFindClinic.
  ///
  /// In en, this message translates to:
  /// **'Find clinic'**
  String get homeActionFindClinic;

  /// Fallback snack bar message for an unimplemented home action
  ///
  /// In en, this message translates to:
  /// **'Placeholder action: {action}'**
  String homeActionPlaceholder(String action);

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

  /// No description provided for @learnPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnPlaceholderTitle;

  /// No description provided for @learnPlaceholderTitleNp.
  ///
  /// In en, this message translates to:
  /// **'सिक्नुहोस्'**
  String get learnPlaceholderTitleNp;
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
