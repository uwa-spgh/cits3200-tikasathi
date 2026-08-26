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
  String get childVaccineHistory => 'खोप इतिहास';

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
}
