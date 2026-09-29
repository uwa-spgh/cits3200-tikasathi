import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/home/domain/home_models.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

/// Helper to generate natural, conversational spoken summaries for each screen
/// tailored for low-literacy caregivers in both English and Nepali.
class ScreenSpeechHelper {
  /// Extracts all visible text from [Text] and [RichText] widgets within
  /// the nearest [Scaffold] or the subtree of [context].
  static String extractVisibleText(BuildContext context) {
    final List<String> parts = <String>[];

    Element? rootElement;
    context.visitAncestorElements((Element element) {
      if (element.widget is Scaffold) {
        rootElement = element;
        return false;
      }
      return true;
    });

    rootElement ??= context as Element;

    void visitor(Element element) {
      final Widget widget = element.widget;
      String? text;
      if (widget is Text) {
        text = widget.data ?? widget.textSpan?.toPlainText();
      } else if (widget is RichText) {
        text = widget.text.toPlainText();
      }

      if (text != null) {
        final String clean = text.trim();
        if (clean.isNotEmpty &&
            !clean.startsWith('MaterialApp') &&
            !clean.startsWith('Scaffold') &&
            (parts.isEmpty || parts.last != clean)) {
          parts.add(clean);
        }
      }
      element.visitChildren(visitor);
    }

    rootElement!.visitChildren(visitor);

    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';
    final String separator = isNepali ? '। ' : '. ';
    return parts.join(separator);
  }

  /// Builds a spoken summary of the Home dashboard.
  static String homeScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
    required List<HomeStatusGroup> groups,
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';
    final StringBuffer buffer = StringBuffer();

    if (isNepali) {
      buffer.write('टिकासार्थी बाल खोप ट्र्याकिङ। ');
      if (groups.isEmpty) {
        buffer.write(
          'टिकासार्थीमा स्वागत छ। खोप विवरण ट्र्याक गर्न कृपया आफ्नो बालबालिकाको विवरण दर्ता गर्नुहोस्।',
        );
        return buffer.toString();
      }

      for (final HomeStatusGroup group in groups) {
        if (group.children.isEmpty) continue;
        final String names =
            group.children.map((HomeChildSummary c) => c.name).join(', ');
        switch (group.group) {
          case HomeVaccinationGroup.awaitingSetup:
            buffer.write(
              'दर्ता पूरा गर्न बाँकी बालबालिका: $names। खोप रेकर्ड सुरु गर्न दर्ता पूरा गर्नुहोस्। ',
            );
            break;
          case HomeVaccinationGroup.dueToday:
            buffer.write('आज खोप लगाउने मिति भएका बालबालिका: $names। ');
            break;
          case HomeVaccinationGroup.dueSoon:
            buffer.write('चाँडै खोप लगाउने मिति भएका बालबालिका: $names। ');
            break;
          case HomeVaccinationGroup.upToDate:
            buffer.write('खोप पूर्ण अवस्थामा रहेका बालबालिका: $names। ');
            break;
        }
      }
    } else {
      buffer.write('TikaSathi Childhood Immunisation Tracking. ');
      if (groups.isEmpty) {
        buffer.write(
          'Welcome to TikaSathi. Please register your child to begin tracking immunisations.',
        );
        return buffer.toString();
      }

      for (final HomeStatusGroup group in groups) {
        if (group.children.isEmpty) continue;
        final String names =
            group.children.map((HomeChildSummary c) => c.name).join(', ');
        switch (group.group) {
          case HomeVaccinationGroup.awaitingSetup:
            buffer.write(
              'Setup pending for: $names. Please complete setup to track vaccines. ',
            );
            break;
          case HomeVaccinationGroup.dueToday:
            buffer.write('Vaccines due today for: $names. ');
            break;
          case HomeVaccinationGroup.dueSoon:
            buffer.write('Vaccines due soon for: $names. ');
            break;
          case HomeVaccinationGroup.upToDate:
            buffer.write('Vaccinations are up to date for: $names. ');
            break;
        }
      }
    }

    return buffer.toString().trim();
  }

  /// Builds a spoken summary of a child profile.
  static String childProfileScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
    required ChildProfileDetails details,
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';
    final String locale = Localizations.localeOf(context).languageCode;
    final String bornDate =
        DateFormat('d MMMM y', locale).format(details.child.dateOfBirth);
    final String age = details.ageLabel(localizations);
    final String sex =
        details.child.sex.toLowerCase() == 'male' || details.child.sex == 'केटा'
            ? (isNepali ? 'बालक' : 'Male')
            : (isNepali ? 'बालिका' : 'Female');

    final StringBuffer buffer = StringBuffer();
    if (isNepali) {
      buffer.write('${details.child.name}को खोप विवरण। ');
      buffer.write('उमेर: $age। ');
      buffer.write('जन्म मिति: $bornDate। ');
      buffer.write('लिङ्ग: $sex। ');

      if (details.dueVaccines.isNotEmpty) {
        final VaccinationDue next = details.dueVaccines.first;
        final String dueDate =
            DateFormat('d MMMM y', locale).format(next.dueDate);
        buffer.write('अर्को खोप: ${next.vaccineCode}, मिति: $dueDate। ');
      }
      buffer.write('लागेका खोपहरू: ${details.records.length} मात्रा।');
    } else {
      buffer.write('Child profile for ${details.child.name}. ');
      buffer.write('Age: $age. ');
      buffer.write('Born on: $bornDate. ');
      buffer.write('Sex: $sex. ');

      if (details.dueVaccines.isNotEmpty) {
        final VaccinationDue next = details.dueVaccines.first;
        final String dueDate =
            DateFormat('d MMMM y', locale).format(next.dueDate);
        buffer.write('Next vaccine: ${next.vaccineCode}, due on: $dueDate. ');
      }
      buffer.write('Completed vaccines: ${details.records.length} doses.');
    }

    return buffer.toString().trim();
  }

  /// Builds a spoken summary of the Vaccine Records & History screen.
  static String vaccineRecordsScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
    required String childName,
    required List<VaccinationRecord> records,
    required List<VaccinationDue> dues,
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';
    final StringBuffer buffer = StringBuffer();

    if (isNepali) {
      buffer.write('$childNameको खोप अभिलेख र इतिहास। ');
      if (records.isNotEmpty) {
        final String recList = records
            .map((VaccinationRecord r) => r.vaccineCode)
            .toSet()
            .join(', ');
        buffer.write('लागेका खोपहरू: $recList। ');
      } else {
        buffer.write('हालसम्म कुनै खोप रेकर्ड गरिएको छैन। ');
      }

      if (dues.isNotEmpty) {
        final String dueList =
            dues.map((VaccinationDue d) => d.vaccineCode).toSet().join(', ');
        buffer.write('आगामी खोपहरू: $dueList। ');
      }
    } else {
      buffer.write('Vaccine records and history for $childName. ');
      if (records.isNotEmpty) {
        final String recList = records
            .map((VaccinationRecord r) => r.vaccineCode)
            .toSet()
            .join(', ');
        buffer.write('Completed vaccines: $recList. ');
      } else {
        buffer.write('No vaccines recorded yet. ');
      }

      if (dues.isNotEmpty) {
        final String dueList =
            dues.map((VaccinationDue d) => d.vaccineCode).toSet().join(', ');
        buffer.write('Upcoming vaccines: $dueList. ');
      }
    }

    return buffer.toString().trim();
  }

  /// Builds a spoken summary of the Vaccine Schedule screen.
  static String vaccineScheduleScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';

    if (isNepali) {
      return 'नेपालको राष्ट्रिय बाल खोप तालिका। '
          'जन्मँदा: बीसीजी, ओपिभी ०। '
          '६ हप्तामा: पेन्टाभालेन्ट १, रोटाभाइरस १, पिसिभी १, ओपिभी १। '
          '१० हप्तामा: पेन्टाभालेन्ट २, रोटाभाइरस २। '
          '१४ हप्तामा: पेन्टाभालेन्ट ३, पिसिभी २, एफआइपिभी १। '
          '९ महिनामा: दादुरा-रुबेला १, पिसिभी ३, एफआइपिभी २। '
          '१५ महिनामा: दादुरा-रुबेला २, टाइफाइड खोप।';
    } else {
      return 'National Immunisation Schedule of Nepal. '
          'At birth: BCG, OPV 0. '
          'At 6 weeks: Pentavalent 1, Rotavirus 1, PCV 1, OPV 1. '
          'At 10 weeks: Pentavalent 2, Rotavirus 2. '
          'At 14 weeks: Pentavalent 3, PCV 2, fIPV 1. '
          'At 9 months: Measles-Rubella 1, PCV 3, fIPV 2. '
          'At 15 months: Measles-Rubella 2, Typhoid vaccine.';
    }
  }

  /// Builds a spoken summary of the Settings screen.
  static String settingsScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
    required AppLanguage currentLanguage,
  }) {
    final bool isNepali = currentLanguage == AppLanguage.nepali;

    if (isNepali) {
      return 'सेटिङहरू। भाषा छनोट: हाल नेपाली भाषा चयन गरिएको छ। '
          'अभिभावकको विवरण हेर्न र सम्पादन गर्न सकिन्छ। '
          'बालबालिकाको विवरण सम्पादन गर्न सकिन्छ। '
          'नजिकैको स्वास्थ्य संस्थाको सम्पर्क विवरण उपलब्ध छ।';
    } else {
      return 'Settings. Language options: English or Nepali. '
          'Caregiver profile management. '
          'Child profiles editing. '
          'Local health facility contact information.';
    }
  }

  /// Builds a spoken summary of the Record Dose screen.
  static String recordDoseScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';

    if (isNepali) {
      return 'खोप मात्रा दर्ता गर्नुहोस्। '
          'चरण १: खोप लगाउने बच्चा छान्नुहोस्। '
          'चरण २: लगाइएको खोप छान्नुहोस्। '
          'चरण ३: खोप लगाएको मिति छान्नुहोस्। '
          'चरण ४: खोप दिने स्वास्थ्य संस्था वा स्वास्थ्यकर्मी उल्लेख गर्नुहोस्। '
          'अन्त्यमा सुरक्षित गर्न सेभ बटन थिच्नुहोस्।';
    } else {
      return 'Log vaccine dose. '
          'Step 1: Select child. '
          'Step 2: Select vaccine administered. '
          'Step 3: Select date given. '
          'Step 4: Enter administered by. '
          'Finally, tap save to record dose.';
    }
  }
}
