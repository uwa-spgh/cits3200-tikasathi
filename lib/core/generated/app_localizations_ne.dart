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
  String get childReadAloudStopTooltip => 'पढाइ रोक्नुहोस्';

  @override
  String get childReadAloudNoContent => 'पढ्नको लागि कुनै पाठ भेटिएन।';

  @override
  String get childReadAloudError =>
      'पढाइ सुनाउन सकिएन। कृपया आफ्नो यन्त्रको आवाज सेटिङ जाँच गर्नुहोस्।';

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
  String get childVaccinationOverdue => 'खोपको मिति नाघेको';

  @override
  String get childFollowingVaccine => 'त्यसपछिको खोप (पछि)';

  @override
  String get childAllVaccinesCompleted => 'सबै खोपहरू पूरा भए!';

  @override
  String get childFinalScheduledVaccine => 'अन्तिम निर्धारित खोप';

  @override
  String get childVaccineRecordsAndHistory => 'खोप इतिहास';

  @override
  String get childVaccineRecordsAndHistorySubtitle =>
      'लिएका खोपहरू हेर्नुहोस् र सम्पादन गर्नुहोस्';

  @override
  String get vaccineHistoryFilterAgeAppropriate => 'उमेर अनुसार मात्र';

  @override
  String get vaccineHistoryFilterAll => 'सबै खोपहरू देखाउनुहोस्';

  @override
  String get vaccineHistorySaveChanges => 'परिवर्तनहरू बचत गर्नुहोस्';

  @override
  String get vaccineHistorySavedSuccess =>
      'खोप इतिहास सफलतापूर्वक अद्यावधिक गरियो';

  @override
  String vaccineHistoryAdministeredOn(String date) {
    return '$date मा दिइएको';
  }

  @override
  String vaccineHistoryDueAt(String date) {
    return 'दिनुपर्ने मिति: $date';
  }

  @override
  String get healthFacilitatorSaveAction =>
      'आफ्नो नजिकको स्वास्थ्य संस्था बचत गर्नुहोस्';

  @override
  String get healthFacilitatorSavedHeading =>
      'तपाईंको स्थानीय स्वास्थ्य संस्था';

  @override
  String get healthFacilitatorTitle => 'स्वास्थ्य संस्था';

  @override
  String get healthFacilitatorSubtitle =>
      'आफ्नो नजिकको स्वास्थ्य संस्थाको विवरण बचत गर्नुहोस्।';

  @override
  String get healthFacilitatorName => 'स्वास्थ्य संस्थाको नाम';

  @override
  String get healthFacilitatorNameHint => 'स्वास्थ्य संस्थाको नाम लेख्नुहोस्';

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
      'स्वास्थ्य संस्थाको विवरण बचत गर्न सकिएन।';

  @override
  String get healthFacilitatorBack => 'फर्कनुहोस्';

  @override
  String get healthFacilitySaveAction =>
      'आफ्नो नजिकको स्वास्थ्य संस्था बचत गर्नुहोस्';

  @override
  String get healthFacilitySavedHeading => 'तपाईंको स्थानीय स्वास्थ्य संस्था';

  @override
  String get healthFacilityTitle => 'स्वास्थ्य संस्था';

  @override
  String get healthFacilitySubtitle =>
      'आफ्नो नजिकको स्वास्थ्य संस्थाको विवरण बचत गर्नुहोस्।';

  @override
  String get healthFacilityName => 'स्वास्थ्य संस्थाको नाम';

  @override
  String get healthFacilityNameHint => 'स्वास्थ्य संस्थाको नाम लेख्नुहोस्';

  @override
  String get healthFacilityAddress => 'ठेगाना';

  @override
  String get healthFacilityAddressHint => 'ठेगाना लेख्नुहोस्';

  @override
  String get healthFacilityPhone => 'फोन नम्बर';

  @override
  String get healthFacilityPhoneHint => 'फोन नम्बर लेख्नुहोस्';

  @override
  String get healthFacilityInvalidPhone =>
      'कृपया मान्य फोन नम्बर प्रविष्ट गर्नुहोस्';

  @override
  String get healthFacilitySave => 'बचत गर्नुहोस्';

  @override
  String get healthFacilitySaveError =>
      'स्वास्थ्य संस्थाको विवरण बचत गर्न सकिएन।';

  @override
  String get healthFacilityBack => 'फर्कनुहोस्';

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
  String get manageProfilesTitle => 'प्रोफाइलहरू व्यवस्थापन गर्नुहोस्';

  @override
  String get editCaregiverAction => 'हेरचाहकर्ताको विवरण सम्पादन गर्नुहोस्';

  @override
  String get editChildAction => 'बच्चाको विवरण सम्पादन गर्नुहोस्';

  @override
  String get deleteChildAction => 'बच्चा मेटाउनुहोस्';

  @override
  String get editCaregiverTitle => 'हेरचाहकर्ताको विवरण सम्पादन गर्नुहोस्';

  @override
  String get editChildTitle => 'बच्चाको विवरण सम्पादन गर्नुहोस्';

  @override
  String editChildTitleWithName(String childName) {
    return '$childName को विवरण सम्पादन गर्नुहोस्';
  }

  @override
  String get profileSave => 'बचत गर्नुहोस्';

  @override
  String get profileCancel => 'रद्द गर्नुहोस्';

  @override
  String get profileContinue => 'जारी राख्नुहोस्';

  @override
  String get profileBack => 'फर्कनुहोस्';

  @override
  String get profileLoadError => 'प्रोफाइल विवरण लोड गर्न सकिएन।';

  @override
  String get profileSaveError => 'प्रोफाइल विवरण बचत गर्न सकिएन।';

  @override
  String get profileInvalidChild => 'कृपया नाम र जन्म मिति प्रविष्ट गर्नुहोस्।';

  @override
  String get profileChildNotFound => 'बच्चाको विवरण फेला परेन।';

  @override
  String get selectChildTitle => 'बच्चा छान्नुहोस्';

  @override
  String get noChildrenMessage => 'अहिलेसम्म कुनै बच्चा थपिएको छैन।';

  @override
  String get updateVaccinationScheduleTitle => 'खोप तालिका अद्यावधिक गर्ने?';

  @override
  String updateVaccinationScheduleProfileName(String childName) {
    return 'अद्यावधिक गरिने बच्चाको प्रोफाइल: $childName';
  }

  @override
  String get updateVaccinationScheduleMessageFirst =>
      'तपाईंको बच्चाको जन्म मिति वा लिङ्ग परिवर्तन गर्दा खोप तालिका परिवर्तन हुन सक्छ।';

  @override
  String get updateVaccinationScheduleMessageSecond =>
      'यी परिवर्तनहरू बचत गरिनेछन् र तपाईंले विवरण फेरि परिवर्तन नगरेसम्म प्रयोग हुनेछन्।';

  @override
  String get updateVaccinationScheduleMessageThird =>
      'आवश्यक परेमा तपाईंले यी विवरणहरू पछि फेरि सम्पादन गर्न सक्नुहुन्छ।';

  @override
  String get deleteChildTitle => 'बच्चा मेटाउने?';

  @override
  String deleteChildProfileName(String childName) {
    return 'बच्चाको प्रोफाइल मेटाउँदै: $childName';
  }

  @override
  String get deleteChildMessageFirst =>
      'यसले यो बच्चाको जानकारी र खोपका अभिलेखहरू स्थायी रूपमा मेटाउनेछ।';

  @override
  String get deleteChildMessageUndo => 'यो कार्य पूर्ववत गर्न सकिँदैन।';

  @override
  String get deleteChildConfirm => 'बच्चा मेटाउनुहोस्';

  @override
  String get deleteChildSuccess => 'बच्चा मेटाइयो।';

  @override
  String get deleteChildError => 'बच्चा मेटाउन सकिएन।';

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
  String get onboardingErrorEmptyCaregiverName =>
      'कृपया हेरचाहकर्ताको नाम प्रविष्ट गर्नुहोस्';

  @override
  String get onboardingErrorEmptyCaregiverPhone =>
      'कृपया हेरचाहकर्ताको फोन नम्बर प्रविष्ट गर्नुहोस्';

  @override
  String get onboardingErrorInvalidPhone =>
      'कृपया मान्य फोन नम्बर प्रविष्ट गर्नुहोस्';

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
  String get onboardingErrorFutureDob => 'जन्म मिति भविष्यको हुन सक्दैन';

  @override
  String get onboardingErrorTooOldDob =>
      'बच्चा १८ वर्षभन्दा कम उमेरको हुनुपर्छ';

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
  String get learnTitle => 'सिक्नुहोस्';

  @override
  String get learnTopic1Title => 'विषय १';

  @override
  String get learnTopic1Summary => 'विषय १ को छोटो सारांश।';

  @override
  String get learnTopic1Body =>
      'यो विषय १ को लागि अस्थायी सामग्री हो। यसलाई यस विषयको वास्तविक जानकारीले बदल्नुहोस्।\n\nयो अनुच्छेदले विषय १ ले अभिभावक र उनीहरूका बच्चाहरूका लागि के अर्थ राख्छ भनेर बताउनेछ।\n\nयो अनुच्छेदले विषय १ बारे व्यावहारिक सल्लाह दिनेछ र सामान्य प्रश्नहरूको जवाफ दिनेछ।\n\nयो अनुच्छेदले विषय १ बारे थप सहयोग कहाँ पाइन्छ भनेर बताउनेछ, जस्तै नजिकको स्वास्थ्य संस्था वा स्वास्थ्यकर्मी।';

  @override
  String get learnTopic2Title => 'विषय २';

  @override
  String get learnTopic2Summary => 'विषय २ को छोटो सारांश।';

  @override
  String get learnTopic2Body =>
      'यो विषय २ को लागि अस्थायी सामग्री हो। यसलाई यस विषयको वास्तविक जानकारीले बदल्नुहोस्।\n\nयो अनुच्छेदले विषय २ ले अभिभावक र उनीहरूका बच्चाहरूका लागि के अर्थ राख्छ भनेर बताउनेछ।\n\nयो अनुच्छेदले विषय २ बारे व्यावहारिक सल्लाह दिनेछ र सामान्य प्रश्नहरूको जवाफ दिनेछ।\n\nयो अनुच्छेदले विषय २ बारे थप सहयोग कहाँ पाइन्छ भनेर बताउनेछ, जस्तै नजिकको स्वास्थ्य संस्था वा स्वास्थ्यकर्मी।';

  @override
  String get learnTopic3Title => 'विषय ३';

  @override
  String get learnTopic3Summary => 'विषय ३ को छोटो सारांश।';

  @override
  String get learnTopic3Body =>
      'यो विषय ३ को लागि अस्थायी सामग्री हो। यसलाई यस विषयको वास्तविक जानकारीले बदल्नुहोस्।\n\nयो अनुच्छेदले विषय ३ ले अभिभावक र उनीहरूका बच्चाहरूका लागि के अर्थ राख्छ भनेर बताउनेछ।\n\nयो अनुच्छेदले विषय ३ बारे व्यावहारिक सल्लाह दिनेछ र सामान्य प्रश्नहरूको जवाफ दिनेछ।\n\nयो अनुच्छेदले विषय ३ बारे थप सहयोग कहाँ पाइन्छ भनेर बताउनेछ, जस्तै नजिकको स्वास्थ्य संस्था वा स्वास्थ्यकर्मी।';

  @override
  String get learnTopic4Title => 'विषय ४';

  @override
  String get learnTopic4Summary => 'विषय ४ को छोटो सारांश।';

  @override
  String get learnTopic4Body =>
      'यो विषय ४ को लागि अस्थायी सामग्री हो। यसलाई यस विषयको वास्तविक जानकारीले बदल्नुहोस्।\n\nयो अनुच्छेदले विषय ४ ले अभिभावक र उनीहरूका बच्चाहरूका लागि के अर्थ राख्छ भनेर बताउनेछ।\n\nयो अनुच्छेदले विषय ४ बारे व्यावहारिक सल्लाह दिनेछ र सामान्य प्रश्नहरूको जवाफ दिनेछ।\n\nयो अनुच्छेदले विषय ४ बारे थप सहयोग कहाँ पाइन्छ भनेर बताउनेछ, जस्तै नजिकको स्वास्थ्य संस्था वा स्वास्थ्यकर्मी।';

  @override
  String get learnTopic5Title => 'विषय ५';

  @override
  String get learnTopic5Summary => 'विषय ५ को छोटो सारांश।';

  @override
  String get learnTopic5Body =>
      'यो विषय ५ को लागि अस्थायी सामग्री हो। यसलाई यस विषयको वास्तविक जानकारीले बदल्नुहोस्।\n\nयो अनुच्छेदले विषय ५ ले अभिभावक र उनीहरूका बच्चाहरूका लागि के अर्थ राख्छ भनेर बताउनेछ।\n\nयो अनुच्छेदले विषय ५ बारे व्यावहारिक सल्लाह दिनेछ र सामान्य प्रश्नहरूको जवाफ दिनेछ।\n\nयो अनुच्छेदले विषय ५ बारे थप सहयोग कहाँ पाइन्छ भनेर बताउनेछ, जस्तै नजिकको स्वास्थ्य संस्था वा स्वास्थ्यकर्मी।';

  @override
  String get learnTopic6Title => 'विषय ६';

  @override
  String get learnTopic6Summary => 'विषय ६ को छोटो सारांश।';

  @override
  String get learnTopic6Body =>
      'यो विषय ६ को लागि अस्थायी सामग्री हो। यसलाई यस विषयको वास्तविक जानकारीले बदल्नुहोस्।\n\nयो अनुच्छेदले विषय ६ ले अभिभावक र उनीहरूका बच्चाहरूका लागि के अर्थ राख्छ भनेर बताउनेछ।\n\nयो अनुच्छेदले विषय ६ बारे व्यावहारिक सल्लाह दिनेछ र सामान्य प्रश्नहरूको जवाफ दिनेछ।\n\nयो अनुच्छेदले विषय ६ बारे थप सहयोग कहाँ पाइन्छ भनेर बताउनेछ, जस्तै नजिकको स्वास्थ्य संस्था वा स्वास्थ्यकर्मी।';

  @override
  String get learnTopic7Title => 'विषय ७';

  @override
  String get learnTopic7Summary => 'विषय ७ को छोटो सारांश।';

  @override
  String get learnTopic7Body =>
      'यो विषय ७ को लागि अस्थायी सामग्री हो। यसलाई यस विषयको वास्तविक जानकारीले बदल्नुहोस्।\n\nयो अनुच्छेदले विषय ७ ले अभिभावक र उनीहरूका बच्चाहरूका लागि के अर्थ राख्छ भनेर बताउनेछ।\n\nयो अनुच्छेदले विषय ७ बारे व्यावहारिक सल्लाह दिनेछ र सामान्य प्रश्नहरूको जवाफ दिनेछ।\n\nयो अनुच्छेदले विषय ७ बारे थप सहयोग कहाँ पाइन्छ भनेर बताउनेछ, जस्तै नजिकको स्वास्थ्य संस्था वा स्वास्थ्यकर्मी।';

  @override
  String get learnTopic8Title => 'विषय ८';

  @override
  String get learnTopic8Summary => 'विषय ८ को छोटो सारांश।';

  @override
  String get learnTopic8Body =>
      'यो विषय ८ को लागि अस्थायी सामग्री हो। यसलाई यस विषयको वास्तविक जानकारीले बदल्नुहोस्।\n\nयो अनुच्छेदले विषय ८ ले अभिभावक र उनीहरूका बच्चाहरूका लागि के अर्थ राख्छ भनेर बताउनेछ।\n\nयो अनुच्छेदले विषय ८ बारे व्यावहारिक सल्लाह दिनेछ र सामान्य प्रश्नहरूको जवाफ दिनेछ।\n\nयो अनुच्छेदले विषय ८ बारे थप सहयोग कहाँ पाइन्छ भनेर बताउनेछ, जस्तै नजिकको स्वास्थ्य संस्था वा स्वास्थ्यकर्मी।';

  @override
  String get childStatusSetupIncomplete => 'सेटअप पूरा हुन बाँकी';

  @override
  String get homeSectionAwaitingSetup => 'सेटअप पूरा हुन बाँकी';

  @override
  String get homeActionCompleteSetup => 'सेटअप पूरा गर्नुहोस्';

  @override
  String get childSetupIncompleteBanner =>
      'पहिले लगाइएका खोपहरूको विवरण भरिएको छैन। सही तालिका हेर्न सेटअप पूरा गर्नुहोस्।';

  @override
  String get childActionCompleteSetup => 'सेटअप पूरा गर्नुहोस्';

  @override
  String get childUrgencySetupRequired => 'सेटअप आवश्यक';

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

  @override
  String get vaccineScheduleTitle => 'खोप तालिका';

  @override
  String get vaccineScheduleBack => 'फिर्ता';

  @override
  String get vaccineScheduleDoseHeader => 'खोपको खुराक';

  @override
  String get vaccineScheduleDueHeader => 'मिति';

  @override
  String get vaccineScheduleReturn => 'फिर्ता';

  @override
  String get vaccineScheduleEmpty => 'आगामी खोपहरू छैनन्।';

  @override
  String get vaccineScheduleToday => 'आज';

  @override
  String vaccineScheduleInDays(num count) {
    return '$count दिनमा';
  }

  @override
  String vaccineScheduleInMonths(num count) {
    return '$count महिनामा';
  }

  @override
  String vaccineScheduleInYears(Object count) {
    return '$count वर्षमा';
  }

  @override
  String vaccineScheduleInYearsMonths(Object months, Object years) {
    return '$years वर्ष $months महिनामा';
  }

  @override
  String vaccineScheduleOverdueBy(Object count) {
    return '$count दिन ढिला';
  }

  @override
  String get overdueVaccinesDialogTitle => 'छुटेका खोप';

  @override
  String get overdueVaccinesDialogMessage =>
      'छुटेका खोपका लागि स्वास्थ्य संस्था जानुहोस्।';

  @override
  String get overdueVaccinesNoticeBanner =>
      'छुटेका खोपका लागि स्वास्थ्य संस्था जानुहोस्।';

  @override
  String get actionUnderstand => 'ठीक छ';

  @override
  String reminderTitleUpcoming(String childName) {
    return 'खोपको सम्झना – $childName';
  }

  @override
  String reminderTitleMissed(String childName) {
    return 'खोप छुट्यो – $childName';
  }

  @override
  String reminderTitleOverdue(String childName) {
    return 'खोपको म्याद नाघ्यो – $childName';
  }

  @override
  String reminderUpcoming(String vaccineName, String date) {
    return 'तपाईंको बच्चालाई $date मा $vaccineName लगाउनुपर्छ। कृपया नजिकैको स्वास्थ्य चौकी वा खोप क्लिनिकमा जानुहोस्।';
  }

  @override
  String reminderMissedYesterday(String vaccineName, String date) {
    return '$vaccineName $date मा लगाउनुपर्ने थियो, तर अहिलेसम्म रेकर्ड भएको छैन। हरेक मात्रा समयमै पूरा गर्दा बच्चा सुरक्षित रहन्छ। कृपया नजिकैको स्वास्थ्य चौकीमा जानुहोस्।';
  }

  @override
  String reminderMissedWeek(String vaccineName) {
    return '$vaccineName एक हप्तादेखि छुटेको छ। बच्चा सुरक्षित रहोस् भन्नाका लागि क्याच-अप खोपबारे नजिकैको स्वास्थ्य संस्थामा सम्पर्क गर्नुहोस्।';
  }

  @override
  String reminderOverdue(String vaccineName) {
    return '$vaccineName को म्याद नाघिसक्यो। क्याच-अप खोपका लागि नजिकैको स्वास्थ्य संस्थामा सम्पर्क गर्नुहोस्।';
  }

  @override
  String get backupSectionTitle => 'ब्याकअप';

  @override
  String get backupExportAction => 'ब्याकअप निकाल्नुहोस्';

  @override
  String get backupImportAction => 'ब्याकअप ल्याउनुहोस्';

  @override
  String get backupPrivacyNote =>
      'यो फाइल सुरक्षित ठाउँमा राख्नुहोस्। यसमा तपाईंको बच्चाको स्वास्थ्य जानकारी छ।';

  @override
  String get backupReplaceTitle => 'यस फोनको डाटा बदल्ने?';

  @override
  String get backupReplaceMessage =>
      'यसले यस फोनको सबै डाटा बदल्नेछ। जारी राख्ने?';

  @override
  String get backupReplaceConfirm => 'जारी राख्नुहोस्';

  @override
  String get backupExportSuccess => 'ब्याकअप फाइल बचत गर्न तयार छ।';

  @override
  String get backupImportSuccess => 'ब्याकअप ल्याइयो।';

  @override
  String get backupExportError => 'ब्याकअप निकाल्न सकिएन।';

  @override
  String get backupImportError => 'ब्याकअप ल्याउन सकिएन।';

  @override
  String get backupInvalidFile =>
      'यो फाइल यो एपले पढ्न सक्ने टिकासथी ब्याकअप होइन।';

  @override
  String get databaseLockedTitle => 'तपाईंको सुरक्षित डाटा खोल्न सकिएन';

  @override
  String get databaseLockedMessage =>
      'यस फोनमा टिकासथीको डाटा सुरक्षित राख्ने साँचो अब छैन, त्यसैले डाटा पढ्न सकिँदैन। फोनको सुरक्षा रिसेट गरेपछि यस्तो हुन सक्छ। तपाईंसँग ब्याकअप फाइल छ भने नयाँ सुरु गरेपछि ल्याउन सक्नुहुन्छ।';

  @override
  String get databaseLockedAction => 'नयाँ सुरु गर्नुहोस्';

  @override
  String get databaseLockedError =>
      'नयाँ सुरु गर्न सकिएन। फेरि प्रयास गर्नुहोस्।';
}
