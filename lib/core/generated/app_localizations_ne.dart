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
  String get editVaccineScheduleAction =>
      'बच्चाको खोप तालिका सम्पादन गर्नुहोस् (स्वास्थ्यकर्मीका लागि मात्र)';

  @override
  String get healthcareProfessionalQuestion =>
      'के तपाईं स्वास्थ्यकर्मी हुनुहुन्छ?';

  @override
  String get healthcareProfessionalConfirm => 'हो';

  @override
  String get healthcareProfessionalDecline => 'होइन';

  @override
  String get scheduleEditorTitle => 'खोप तालिका सम्पादन गर्नुहोस्';

  @override
  String scheduleEditorTitleForChild(String childName) {
    return '$childName को खोप तालिका सम्पादन गर्नुहोस्';
  }

  @override
  String get scheduleEditorEmpty => 'कुनै बाँकी खोप तालिका छैन।';

  @override
  String get scheduleEditorEdit => 'निर्धारित खोप सम्पादन गर्नुहोस्';

  @override
  String get scheduleEditorVaccine => 'खोप';

  @override
  String get scheduleEditorDose => 'खोप मात्रा';

  @override
  String get scheduleEditorDueDate => 'निर्धारित मिति';

  @override
  String get scheduleEditorSave => 'तालिका परिवर्तनहरू बचत गर्नुहोस्';

  @override
  String get scheduleEditorSaveConfirmTitle => 'तालिका परिवर्तनहरू बचत गर्ने?';

  @override
  String get scheduleEditorSaveConfirmMessage =>
      'बच्चाको खोप तालिकामा स्वास्थ्यकर्मीका परिवर्तनहरू बचत गर्ने?';

  @override
  String get scheduleEditorRestore =>
      'पूर्वनिर्धारित खोप तालिका पुनर्स्थापना गर्नुहोस्';

  @override
  String get scheduleEditorRestoreTitle =>
      'पूर्वनिर्धारित खोप तालिका पुनर्स्थापना गर्ने?';

  @override
  String get scheduleEditorRestoreMessage =>
      'यसले स्वास्थ्यकर्मीका सबै परिवर्तन हटाएर बच्चाको मानक खोप तालिका पुनर्स्थापना गर्नेछ। खोप इतिहास परिवर्तन हुनेछैन।';

  @override
  String get scheduleEditorRestoreConfirm => 'पुनर्स्थापना गर्नुहोस्';

  @override
  String get scheduleEditorInvalidDose => 'यो खोप र मात्रा संयोजन मान्य छैन।';

  @override
  String get scheduleEditorDuplicateDose =>
      'यो खोप र मात्रा बच्चाका लागि पहिले नै निर्धारित छ।';

  @override
  String get scheduleEditorAdministeredDose =>
      'यो खोप र मात्रा पहिले नै लगाइसकिएको छ।';

  @override
  String get scheduleEditorSaveSuccess => 'खोप तालिका अद्यावधिक भयो।';

  @override
  String get scheduleEditorSaveError => 'खोप तालिका अद्यावधिक गर्न सकिएन।';

  @override
  String get scheduleEditorRemove => 'तालिकाबाट हटाउनुहोस्';

  @override
  String get scheduleEditorRemoveConfirm => 'हटाउनुहोस्';

  @override
  String get scheduleEditorDueDateChange => 'खोपको तालिका मिति परिवर्तन गर्ने?';

  @override
  String get scheduleEditorRemoveTitle => 'खोपलाई तालिकाबाट हटाउने?';

  @override
  String scheduleEditorRemoveMessage(Object vaccineCode, Object doseNumber) {
    return '$vaccineCode मात्रा $doseNumber लाई बच्चाको खोप तालिकाबाट हटाउने? यसले खोप इतिहासमा असर गर्दैन।';
  }

  @override
  String scheduleEditorRemoveSuccess(
      Object vaccineCode, Object doseNumber, Object childName) {
    return '$childName को तालिकाबाट $vaccineCode मात्रा $doseNumber हटाइयो।';
  }

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
  String get homeSectionOverdue => 'ढिलो भएको';

  @override
  String get homeSectionDueSoon => 'चाँडै दिइने';

  @override
  String get homeSectionUpToDate => 'पूरा भएको';

  @override
  String get homeScrollInstruction =>
      'सबै बालबालिका हेर्न तल स्क्रोल गर्नुहोस्।';

  @override
  String get homeEmptyStateTitle => 'अहिलेसम्म कुनै बच्चा थपिएको छैन।';

  @override
  String get homeEmptyStateSubtitle =>
      'यहाँ आगामी खोपहरू हेर्न आफ्नो पहिलो बच्चा थप्नुहोस्।';

  @override
  String get learnTitle => 'सिक्नुहोस्';

  @override
  String get learnMythLabel => 'भ्रम:';

  @override
  String get learnFactLabel => 'तथ्य:';

  @override
  String get learnTopic1Title => 'खोप किन महत्त्वपूर्ण छ?';

  @override
  String get learnTopic1Body =>
      '**खोपले तपाईंको बच्चालाई सुरक्षित राख्छ।**\n• केही रोगले बच्चालाई धेरै बिरामी बनाउन सक्छन्।\n• केही रोगले बच्चालाई जीवनभर कमजोर बनाउन सक्छन्।\n• केही रोगले बच्चाको ज्यान लिन सक्छन्।\n• खोपले यी रोगहरूलाई सुरु हुनुअघि नै रोक्छ।\n\n**खोपले अरू बच्चाहरूलाई पनि जोगाउँछ।**\n• धेरै बच्चाहरूले खोप लगाएपछि रोग फैलिन सक्दैन।\n• यसले तपाईंको परिवार, छिमेकी र गाउँलाई सुरक्षित राख्छ।\n\n**खोप निःशुल्क छ।**\n• स्वास्थ्य चौकी र खोप केन्द्रहरूमा खोप निःशुल्क पाइन्छ।\n\n**तपाईंको बच्चालाई सबै मात्रा चाहिन्छ।**\n• धेरै खोपका लागि एक मात्रा मात्र पुग्दैन।\n• हरेक मात्राले तपाईंको बच्चाको शरीरलाई अझ बलियो बनाउँछ।\n• एपमा दिइएका मितिहरू पालना गर्नुहोस्।';

  @override
  String get learnTopic2Title => 'तपाईंको बच्चालाई कहिले खोप लगाउनुपर्छ?';

  @override
  String get learnTopic2Body =>
      '• तपाईंको बच्चालाई फरक-फरक उमेरमा फरक-फरक खोप चाहिन्छ।\n• केही खोप जन्मेलगत्तै दिइन्छ।\n• अरू खोप बच्चा ६, १० र १४ हप्ताको हुँदा दिइन्छ।\n• थप खोप ९, १२ र १५ महिनामा दिइन्छ।\n• तपाईंको बच्चाको खोप लगाउने समय आएपछि एपले तपाईंलाई सम्झाउनेछ।\n• तपाईंको बच्चालाई सुरक्षित राख्न खोप तालिका पालना गर्नुहोस्।';

  @override
  String get learnTopic3Title => 'तपाईंको बच्चाको खोप छुट्यो भने के गर्ने?';

  @override
  String get learnTopic3Body =>
      '• बच्चाको खोप छुट्यो भने चिन्ता नगर्नुहोस्।\n• आफ्नो बच्चालाई नजिकको स्वास्थ्य संस्थामा लैजानुहोस्।\n• स्वास्थ्यकर्मीलाई बच्चाको खोप कार्ड देखाउनुहोस्।\n• बच्चाले कुन-कुन खोप लगाइसकेको छ, स्वास्थ्यकर्मीलाई भन्नुहोस्।\n• अब कुन खोप चाहिन्छ भनेर स्वास्थ्यकर्मीले बताउन सक्नुहुन्छ।\n• एउटा मात्रा छुटेकै कारणले खोप लगाउन नछोड्नुहोस्।';

  @override
  String get learnTopic4Title => 'के खोपहरू सुरक्षित छन्?';

  @override
  String get learnTopic4Body =>
      '• तपाईंको बच्चालाई गम्भीर रोगहरूबाट जोगाउन खोप दिइन्छ।\n• धेरैजसो बच्चाहरूमा खोपपछि हल्का असर मात्र देखिन्छ।\n• तपाईंको बच्चालाई हल्का ज्वरो आउन सक्छ।\n• सुई लगाएको ठाउँमा अलिकति दुख्न वा सुन्निन सक्छ।\n• तपाईंको बच्चा केही समयका लागि अलि रोइरहने वा झर्किने हुन सक्छ।\n• यी असरहरू प्रायः केही समयमै हराउँछन्।';

  @override
  String get learnTopic5Title => 'खोपपछि के हुन सक्छ?';

  @override
  String get learnTopic5Body =>
      '**खोपपछि: के सामान्य हो**\nकेही बच्चाहरूलाई खोपपछि साना समस्या हुन्छन्। यो सामान्य हो। यसको अर्थ खोपले काम गरिरहेको छ।\n• अलिकति ज्वरो\n• सुई लगाएको ठाउँमा दुखाइ वा सुन्निने\n• सामान्यभन्दा बढी रुने\n• सामान्यभन्दा बढी सुत्ने\n\n**तपाईं के गर्न सक्नुहुन्छ**\n• बच्चालाई धेरैपटक आमाको दूध खुवाउनुहोस्।\n• बच्चालाई हलुका लुगा लगाइदिनुहोस्। बच्चालाई धेरै कसेर नबेर्नुहोस्।\n• बच्चा ६ महिनाभन्दा माथिको छ भने थप तरल पदार्थ (झोलिलो कुरा) दिनुहोस्।\n• सुन्निएको ठाउँ नमल्नुहोस् र नथिच्नुहोस्।\n• कुनै पनि औषधि दिनुअघि स्वास्थ्यकर्मीलाई सोध्नुहोस्।\n\nयी समस्याहरू १ देखि २ दिनमा ठीक हुन्छन्।\n\n**तुरुन्तै स्वास्थ्य संस्था कहिले जाने**\nतपाईंको बच्चामा तलका मध्ये कुनै पनि लक्षण देखिएमा तुरुन्तै स्वास्थ्य संस्थामा लैजानुहोस्:\n• धेरै उच्च ज्वरो आउने\n• झट्का आउने वा शरीर काँप्ने\n• आमाको दूध चुस्न वा केही पिउन नसक्ने\n• सास फेर्न गाह्रो हुने\n• लामो समयसम्म रोइरहने, चुप नलाग्ने\n• सुन्निएको ठाउँ झन्-झन् ठूलो हुँदै जाने\n• धेरै कमजोर देखिने वा ब्युँझाउन गाह्रो हुने';

  @override
  String get learnTopic6Title => 'खोपबारे भ्रम र तथ्य';

  @override
  String get learnTopic6Body =>
      '**भ्रम:** खोपले बच्चालाई बिरामी बनाउँछ।\n**तथ्य:** खोपहरू सुरक्षित छन्। खोपले शरीरलाई रोगसँग लड्न सिकाउँछ। खोपपछि अलिकति ज्वरो आउनु सामान्य हो र यो छिट्टै ठीक हुन्छ।\n\n**भ्रम:** मेरो बच्चा स्वस्थ छ, त्यसैले मेरो बच्चालाई खोप चाहिँदैन।\n**तथ्य:** बच्चा बिरामी हुनुअघि नै खोपले सबैभन्दा राम्रो काम गर्छ। स्वस्थ बच्चालाई पनि यी रोग लाग्न सक्छन्।\n\n**भ्रम:** मेरो बच्चाको खोप छुट्यो भने अब त्यो खोप पाउन सक्दैन।\n**तथ्य:** तपाईंको बच्चाले अझै पनि खोप पाउन सक्छ। सकेसम्म छिटो स्वास्थ्य चौकी जानुहोस्।\n\n**भ्रम:** आमाको दूध खाने बच्चालाई खोप चाहिँदैन।\n**तथ्य:** आमाको दूध तपाईंको बच्चाका लागि धेरै राम्रो हो। तर यसले यी रोगहरू रोक्न सक्दैन। तपाईंको बच्चालाई खोप पनि चाहिन्छ।\n\n**भ्रम:** पोलियो र दादुरा जस्ता रोगहरू हराइसके, त्यसैले खोप चाहिँदैन।\n**तथ्य:** बच्चाहरूलाई खोप नलगाए यी रोगहरू फेरि फर्किन सक्छन्।';

  @override
  String get learnTopic7Title => 'आफ्नो बच्चाको खोप कार्ड सुरक्षित राख्नुहोस्';

  @override
  String get learnTopic7Body =>
      '• बच्चाको खोप कार्ड सुरक्षित ठाउँमा राख्नुहोस्।\n• स्वास्थ्य संस्था जाँदा सधैँ कार्ड लिएर जानुहोस्।\n• हरेक खोपपछि कार्डमा विवरण भरिदिन स्वास्थ्यकर्मीलाई भन्नुहोस्।\n• बच्चाले लगाएका खोपहरूको हिसाब राख्न एप प्रयोग गर्नुहोस्।\n• खोप कार्ड नहराउनुहोस्।';

  @override
  String get learnTopic8Title => 'तपाईंको बच्चाले खोप कहाँ पाउन सक्छ?';

  @override
  String get learnTopic8Body =>
      '• तपाईंको बच्चाले खोप सेवा केन्द्र र स्वास्थ्य संस्थाहरूमा खोप पाउन सक्छ।\n• तपाईं आफ्नो नजिकको स्वास्थ्य संस्थामा जान सक्नुहुन्छ।\n• कहाँ जाने थाहा छैन भने स्वास्थ्यकर्मीलाई सोध्नुहोस्।';

  @override
  String get learnTopic9Title => 'याद राख्नुहोस्';

  @override
  String get learnTopic9Body =>
      '• खोपले तपाईंको बच्चालाई गम्भीर रोगहरूबाट जोगाउन मद्दत गर्छ।\n• बच्चालाई समयमै खोप लगाउनुहोस्।\n• बच्चाको खोप कार्ड सुरक्षित राख्नुहोस्।\n• खोप तालिका पालना गर्नुहोस्।\n• बच्चाको खोप छुटेमा स्वास्थ्य संस्थामा जानुहोस्।\n• केही प्रश्न भएमा स्वास्थ्यकर्मीलाई सोध्नुहोस्।';

  @override
  String get learnTopic10Title => 'कुन खोपले कुन रोगबाट जोगाउँछ';

  @override
  String get learnTopic10Body => '';

  @override
  String get learnTopic10Table =>
      'खोप | तपाईंको बच्चालाई यी रोगबाट जोगाउँछ\nबीसीजी (BCG) | क्षयरोग (टीबी)\nपेन्टाभ्यालेन्ट | पाँच रोग: भ्यागुते रोग (डिप्थेरिया), लहरे खोकी, धनुष्टङ्कार, हेपाटाइटिस बी र हिब (हेमोफिलस इन्फ्लुएन्जा टाइप बी) संक्रमण\nपोलियो थोपा र पोलियो सुई | पोलियो\nरोटाभाइरस | झाडापखाला\nपीसीभी (PCV) | निमोनिया र मस्तिष्कज्वर\nएमआर (MR) | दादुरा र रुबेला\nजेई (JE) | जापानिज इन्सेफलाइटिस (मस्तिष्कज्वर)\nटीसीभी (TCV) | टाइफाइड (मियादी ज्वरो)\nएचपीभी (HPV) – छात्राहरूलाई, कक्षा ६ मा विद्यालयमै | ठूलो भएपछि हुन सक्ने पाठेघरको मुखको क्यान्सर';

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
  String childSetupIncompleteSpeech(String childName) {
    return '$childNameको पहिले लगाइएका खोपहरूको इतिहास सेटअप गरिएको छैन। सही खोप तालिका प्राप्त गर्न कृपया सेटअप पूरा गर्नुहोस्।';
  }

  @override
  String get childSpeechOverdueAdvice =>
      'छुटेका खोपबारे सल्लाह लिन कृपया आफ्नो नजिकको स्वास्थ्य संस्थामा जानुहोस्।';

  @override
  String childSpeechVaccineDueOn(String date) {
    return 'मिति: $date';
  }

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
  String vaccineScheduleDueGroupSingular(String date, String vaccines) {
    return '$date मा $vaccines लगाउनुपर्नेछ';
  }

  @override
  String vaccineScheduleDueGroupPlural(String date, String vaccines) {
    return '$date मा $vaccines लगाउनुपर्नेछ';
  }

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
  String get reminderLeadTomorrow => 'भोलि खोप लगाउने तोकिएको दिन हो।';

  @override
  String get reminderLeadToday => 'आज तपाईंको बच्चाको खोप लगाउने दिन हो।';

  @override
  String reminderFacility(String facility) {
    return 'तपाईंले सेभ गर्नुभएको स्वास्थ्य संस्था: $facility।';
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
      'यो फाइल सुरक्षित ठाउँमा राख्नुहोस् र विश्वास गर्ने मानिससँग मात्र साझा गर्नुहोस्। यसमा तपाईंको बच्चाको स्वास्थ्य जानकारी छ।';

  @override
  String get backupPhoneChangeNote =>
      'फोन परिवर्तन गर्दा तपाईंको रेकर्ड आफैँ सर्दैन। फोन बदल्नुअघि ब्याकअप निकाल्नुहोस्।';

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
