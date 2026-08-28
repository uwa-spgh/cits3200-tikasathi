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
