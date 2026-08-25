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
  String get welcome => 'Welcome!';

  @override
  String get selectLanguagePrompt =>
      'Please select your language / कृपया आफ्नो भाषा छान्नुहोस्';

  @override
  String get continueButton => 'Continue';

  @override
  String get caregiverTitle => 'Caregiver Details';

  @override
  String get caregiverSubtitle =>
      'Please enter your information so we can set up the app.';

  @override
  String get fullNameLabel => '👩‍🦰 Full Name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get phoneNumberLabel => '📱 Phone Number';

  @override
  String get phoneNumberHint => 'Enter your phone number';

  @override
  String get addressLabel => '🏠 Address (Optional)';

  @override
  String get addressHint => 'Enter your street address';

  @override
  String get step1Of2 => 'Step 1 of 2';

  @override
  String get step2Of2 => 'Step 2 of 2';

  @override
  String get childNameLabel => '👶 Child\'s name';

  @override
  String get childNameHint => 'Enter full name';

  @override
  String get dobLabel => '📅 Date of Birth';

  @override
  String get ddHint => 'DD';

  @override
  String get mmHint => 'MM';

  @override
  String get yyyyHint => 'YYYY';

  @override
  String get genderLabel => '⚥ Gender';

  @override
  String get girlText => 'Girl';

  @override
  String get boyText => 'Boy';

  @override
  String get finishSetup => 'Finish Setup';

  @override
  String get errorEmptyName => 'Please enter child\'s name';

  @override
  String get errorInvalidDate => 'Please enter a valid Date of Birth';

  @override
  String get errorDate => 'Invalid Date of Birth';

  @override
  String errorSavingSetup(String error) {
    return 'Error saving setup: $error';
  }
}
