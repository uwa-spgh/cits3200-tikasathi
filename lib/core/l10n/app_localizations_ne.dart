// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appTitle => 'टीकासाथी';

  @override
  String get welcome => 'स्वागत छ!';

  @override
  String get selectLanguagePrompt =>
      'Please select your language / कृपया आफ्नो भाषा छान्नुहोस्';

  @override
  String get continueButton => 'अगाडि बढ्नुहोस्';

  @override
  String get caregiverTitle => 'हेरचाहकर्ताको विवरण';

  @override
  String get caregiverSubtitle => 'कृपया आफ्नो विवरण भर्नुहोस्।';

  @override
  String get fullNameLabel => '👩‍🦰 पूरा नाम';

  @override
  String get fullNameHint => 'तपाईंको पूरा नाम प्रविष्ट गर्नुहोस्';

  @override
  String get phoneNumberLabel => '📱 फोन नम्बर';

  @override
  String get phoneNumberHint => 'तपाईंको फोन नम्बर प्रविष्ट गर्नुहोस्';

  @override
  String get addressLabel => '🏠 ठेगाना (वैकल्पिक)';

  @override
  String get addressHint => 'तपाईंको ठेगाना प्रविष्ट गर्नुहोस्';

  @override
  String get step1Of2 => 'चरण १/२';

  @override
  String get step2Of2 => 'चरण २/२';

  @override
  String get childNameLabel => '👶 बच्चाको नाम';

  @override
  String get childNameHint => 'पूरा नाम प्रविष्ट गर्नुहोस्';

  @override
  String get dobLabel => '📅 जन्म मिति';

  @override
  String get ddHint => 'गते';

  @override
  String get mmHint => 'महिना';

  @override
  String get yyyyHint => 'वर्ष';

  @override
  String get genderLabel => '⚥ लिङ्ग';

  @override
  String get girlText => 'छोरी';

  @override
  String get boyText => 'छोरा';

  @override
  String get finishSetup => 'सेटअप पूरा गर्नुहोस्';

  @override
  String get errorEmptyName => 'कृपया बच्चाको नाम प्रविष्ट गर्नुहोस्';

  @override
  String get errorInvalidDate => 'कृपया मान्य जन्म मिति प्रविष्ट गर्नुहोस्';

  @override
  String get errorDate => 'अवैध जन्म मिति';

  @override
  String errorSavingSetup(String error) {
    return 'सेटअप सुरक्षित गर्दा त्रुटि: $error';
  }
}
