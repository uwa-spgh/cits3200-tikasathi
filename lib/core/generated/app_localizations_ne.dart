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
  String get childPageTitle => 'बच्चा पृष्ठ';

  @override
  String childPageTitleWithName(String childName) {
    return '$childName को पृष्ठ';
  }

  @override
  String get childLoading => 'बच्चाको विवरण लोड हुँदैछ...';

  @override
  String get childNotFound => 'बच्चाको प्रोफाइल फेला परेन।';

  @override
  String get childVaccinationDueToday => 'आज खोप लाग्नुपर्ने';

  @override
  String get childVaccinationDueSoon => 'चाँडै';

  @override
  String get childVaccinationUpToDate => 'पूरा भएको';

  @override
  String get childNextVaccine => 'अर्को खोप';

  @override
  String get childNoUpcomingVaccines => 'अर्को खोप छैन';

  @override
  String childBornOn(String dateText) {
    return 'जन्म $dateText';
  }

  @override
  String get childDueOn => 'मिति';

  @override
  String get childSexLabel => 'लिङ्ग';

  @override
  String get childDobLabel => 'जन्म मिति';

  @override
  String get childSexMale => 'पुरुष';

  @override
  String get childSexFemale => 'महिला';

  @override
  String get childSexUnknown => 'उल्लेख गरिएको छैन';

  @override
  String get childNoDueVaccines => 'कुनै पाइने खोप छैन';

  @override
  String get childReadAloudUnavailable => 'पढाइ सुन्न उपलब्ध छैन।';

  @override
  String get childReadAloudTooltip => 'पढाइ सुन्नुहोस्';

  @override
  String get childBackTooltip => 'फर्कनुहोस्';

  @override
  String get childVaccineSchedule => 'खोप तालिका';

  @override
  String get childVaccineRecord => 'खोप रेकर्ड';

  @override
  String get childVaccineHistory => 'खोप इतिहास';

  @override
  String get childActionRecordDose => 'खोप दर्ता गर्नुहोस्';

  @override
  String get childScheduleNotImplemented =>
      'खोप तालिका अझै कार्यान्वयन गरिएको छैन।';

  @override
  String get childHistoryNotImplemented =>
      'खोप इतिहास अझै कार्यान्वयन गरिएको छैन।';

  @override
  String get childNotImplementedYet => 'अहिलेसम्म कार्यान्वयन गरिएको छैन।';

  @override
  String get childDialogOk => 'ठीक छ';

  @override
  String get childMissingFeatureNote =>
      'यस संस्करणमा खोप रेकर्ड र क्लिनिक खोजी उपलब्ध छैन।';

  @override
  String get healthFacilitatorSaveAction =>
      'आफ्नो नजिकको स्वास्थ्य सहजकर्ता बचत गर्नुहोस्';

  @override
  String get healthFacilitatorSavedHeading =>
      'तपाईंको स्थानीय स्वास्थ्य सहजकर्ता';

  @override
  String get healthFacilitatorTitle => 'स्वास्थ्य सहजकर्ता';

  @override
  String get healthFacilitatorSubtitle =>
      'आफ्नो नजिकको स्वास्थ्य सहजकर्ताको विवरण बचत गर्नुहोस्।';

  @override
  String get healthFacilitatorName => 'सहजकर्ताको नाम';

  @override
  String get healthFacilitatorNameHint => 'सहजकर्ताको नाम लेख्नुहोस्';

  @override
  String get healthFacilitatorAddress => 'ठेगाना';

  @override
  String get healthFacilitatorAddressHint => 'ठेगाना लेख्नुहोस्';

  @override
  String get healthFacilitatorPhone => 'फोन नम्बर';

  @override
  String get healthFacilitatorPhoneHint => 'फोन नम्बर लेख्नुहोस्';

  @override
  String get healthFacilitatorSave => 'बचत गर्नुहोस्';

  @override
  String get healthFacilitatorSaveError =>
      'स्वास्थ्य सहजकर्ताको विवरण बचत गर्न सकिएन।';

  @override
  String get healthFacilitatorBack => 'फर्कनुहोस्';

  @override
  String get settingsTitle => 'सेटिङहरू';

  @override
  String get settingsLanguageTitle => 'भाषा छान्नुहोस्';

  @override
  String get settingsNepali => 'नेपाली';

  @override
  String get settingsEnglish => 'अङ्ग्रेजी';

  @override
  String get settingsLanguageSaveError => 'भाषा सेव गर्न सकिएन।';

  @override
  String appLanguageLoadError(Object error) {
    return 'भाषा सेटिङहरू लोड गर्न सकिएन: $error';
  }

  @override
  String get navHome => 'गृहपृष्ठ';

  @override
  String get navLearn => 'सिक्नुहोस्';

  @override
  String get navSettings => 'सेटिङहरू';

  @override
  String get onboardingWelcome => 'स्वागत छ!';

  @override
  String get onboardingLanguagePrompt =>
      'कृपया आफ्नो भाषा छान्नुहोस् / Please select your language';

  @override
  String get onboardingContinue => 'अगाडि बढ्नुहोस्';

  @override
  String get onboardingCaregiverTitle => 'हेरचाहकर्ताको विवरण';

  @override
  String get onboardingCaregiverSubtitle => 'कृपया आफ्नो विवरण भर्नुहोस्।';

  @override
  String get onboardingCaregiverNameLabel => '👩‍🦰 पूरा नाम';

  @override
  String get onboardingCaregiverNameHint =>
      'तपाईंको पूरा नाम प्रविष्ट गर्नुहोस्';

  @override
  String get onboardingCaregiverPhoneLabel => '📱 फोन नम्बर';

  @override
  String get onboardingCaregiverPhoneHint =>
      'तपाईंको फोन नम्बर प्रविष्ट गर्नुहोस्';

  @override
  String get onboardingCaregiverAddressLabel => '🏠 ठेगाना (वैकल्पिक)';

  @override
  String get onboardingCaregiverAddressHint =>
      'तपाईंको ठेगाना प्रविष्ट गर्नुहोस्';

  @override
  String onboardingStepLabel(Object current, Object total) {
    return 'चरण $current/ $total';
  }

  @override
  String get onboardingChildNameLabel => '👶 बच्चाको नाम';

  @override
  String get onboardingChildNameHint => 'पूरा नाम प्रविष्ट गर्नुहोस्';

  @override
  String get onboardingChildDobLabel => '📅 जन्म मिति';

  @override
  String get onboardingChildDateDayHint => 'गते';

  @override
  String get onboardingChildDateMonthHint => 'महिना';

  @override
  String get onboardingChildDateYearHint => 'वर्ष';

  @override
  String get onboardingChildGenderLabel => '⚥ लिङ्ग';

  @override
  String get onboardingChildGenderGirl => 'छोरी';

  @override
  String get onboardingChildGenderBoy => 'छोरा';

  @override
  String get onboardingFinishSetup => 'सेटअप पूरा गर्नुहोस्';

  @override
  String get onboardingErrorEmptyName => 'कृपया बच्चाको नाम प्रविष्ट गर्नुहोस्';

  @override
  String get onboardingErrorInvalidDate =>
      'कृपया मान्य जन्म मिति प्रविष्ट गर्नुहोस्';

  @override
  String get onboardingErrorInvalidDob => 'अवैध जन्म मिति';

  @override
  String onboardingErrorSaveSetup(Object error) {
    return 'सेटअप बचत गर्दा त्रुटि: $error';
  }

  @override
  String get homeTitle => 'तपाईंको बच्चाहरू';

  @override
  String get homeAddChildButton => '+ बच्चा थप्नुहोस्';

  @override
  String get homeActionAddChild => 'बच्चा थप्नुहोस्';

  @override
  String get homeActionChildDetails => 'बच्चाको विवरण';

  @override
  String get homeActionRecordDose => 'खोप दर्ता गर्नुहोस्';

  @override
  String homeActionPlaceholder(String action) {
    return 'स्थगित कार्य: $action';
  }

  @override
  String get recordDoseTitle => 'खोप दर्ता गर्नुहोस्';

  @override
  String recordDoseSubtitle(String childName) {
    return '$childName लाई आज दिइएको प्रत्येक खोपमा चिन्ह लगाउनुहोस्।';
  }

  @override
  String get recordDoseChangeDate => 'परिवर्तन';

  @override
  String recordDoseDoseLabel(String vaccineCode, int doseNumber) {
    return '$vaccineCode (मात्रा $doseNumber)';
  }

  @override
  String recordDoseDueLabel(String date) {
    return 'लाग्नुपर्ने मिति $date';
  }

  @override
  String recordDoseOverdueLabel(String date) {
    return '$date देखि ढिलो';
  }

  @override
  String recordDoseNoneDue(String childName) {
    return '$childName लाई अहिले कुनै खोप लाग्नुपर्ने छैन।';
  }

  @override
  String get recordDoseSaveEmpty => 'पहिले खोपमा चिन्ह लगाउनुहोस्';

  @override
  String recordDoseSaveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मात्रा सुरक्षित गर्नुहोस्',
      one: '१ मात्रा सुरक्षित गर्नुहोस्',
    );
    return '$_temp0';
  }

  @override
  String recordDoseSuccess(int count, String childName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$childName का $count मात्रा दर्ता गरियो',
      one: '$childName को १ मात्रा दर्ता गरियो',
    );
    return '$_temp0';
  }

  @override
  String get recordDoseError =>
      'सुरक्षित गर्न सकिएन। कृपया फेरि प्रयास गर्नुहोस्।';

  @override
  String get recordDoseDateTitle => 'दिइएको मिति';

  @override
  String recordDoseDoseChip(int doseNumber) {
    return 'मात्रा $doseNumber';
  }

  @override
  String recordDoseSelectedSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मात्रा छानियो',
      one: '१ मात्रा छानियो',
      zero: 'कुनै मात्रा छानिएको छैन',
    );
    return '$_temp0';
  }

  @override
  String get recordDoseStepDate => 'चरण १ — मिति जाँच्नुहोस्';

  @override
  String get recordDoseStepSelect =>
      'चरण २ — दिइएको प्रत्येक खोपमा चिन्ह लगाउनुहोस्';

  @override
  String get recordDoseTapToChange => 'परिवर्तन गर्न थिच्नुहोस्';

  @override
  String get recordDoseTickedLabel => 'चिन्ह लगाइयो';

  @override
  String get recordDoseShowMore => 'थप खोपहरू देखाउनुहोस्';

  @override
  String get recordDoseShowFewer => 'कम खोपहरू देखाउनुहोस्';

  @override
  String get recordDoseToday => 'आज';

  @override
  String ageInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन पुरानो',
      one: '१ दिन पुरानो',
    );
    return '$_temp0';
  }

  @override
  String ageInMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count महिना पुरानो',
      one: '१ महिना पुरानो',
    );
    return '$_temp0';
  }

  @override
  String ageInYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वर्ष पुरानो',
      one: '१ वर्ष पुरानो',
    );
    return '$_temp0';
  }

  @override
  String get homeSectionDueToday => 'आज दिइने';

  @override
  String get homeSectionDueSoon => 'चाँडै दिइने';

  @override
  String get homeSectionUpToDate => 'पूरा भएको';

  @override
  String get homeEmptyStateTitle => 'अहिलेसम्म कुनै बच्चा थपिएको छैन।';

  @override
  String get homeEmptyStateSubtitle =>
      'यहाँ आगामी खोपहरू हेर्न आफ्नो पहिलो बच्चा थप्नुहोस्।';

  @override
  String get learnPlaceholderTitle => 'सिक्नुहोस्';

  @override
  String get learnPlaceholderTitleNp => 'सिक्नुहोस्';

  @override
  String get childStatusSetupIncomplete => 'सेटअप अधुरो';

  @override
  String get retroactiveVaccineTitle => 'खोप इतिहास';

  @override
  String retroactiveVaccineSubtitle(String childName) {
    return 'कृपया $childName ले पहिले नै लगाइसकेका खोपहरू भर्नुहोस्।';
  }

  @override
  String get retroactiveVaccineShowAll => 'सबै खोपहरू देखाउनुहोस्';

  @override
  String get retroactiveVaccineShowAllSubtitle =>
      'उमेर-उपयुक्त खोपहरू मात्र देखाइएको छ।\nसबै देखाउन टगल गर्नुहोस्।';

  @override
  String retroactiveVaccineDateLabel(String date) {
    return 'मिति: $date';
  }

  @override
  String get retroactiveVaccineChangeDate => 'परिवर्तन गर्नुहोस्';

  @override
  String get retroactiveVaccineFinish => 'समाप्त';

  @override
  String get retroactiveVaccineSkip => 'अहिलेको लागि छोड्नुहोस्';

  @override
  String get vaccineRecordsDoseHeader => 'खोपको खुराक';

  @override
  String get vaccineRecordsDateHeader => 'प्रशासित मिति';

  @override
  String get vaccineRecordsReturn => 'फिर्ता';

  @override
  String get vaccineRecordsEmpty => 'खोप लगाइएको कुनै रेकर्ड छैन।';

  @override
  String get dose => 'खुराक';
}
