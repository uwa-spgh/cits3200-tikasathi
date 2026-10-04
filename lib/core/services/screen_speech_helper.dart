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
  /// Omits redundant app titles to focus strictly on child status information.
  static String homeScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
    required List<HomeStatusGroup> groups,
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';
    final StringBuffer buffer = StringBuffer();

    if (isNepali) {
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

  /// Builds a concise, vaccine-focused spoken summary of a child profile.
  static String childProfileScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
    required ChildProfileDetails details,
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';
    final String locale = Localizations.localeOf(context).languageCode;
    final String childName = details.child.name;
    final StringBuffer buffer = StringBuffer();

    if (!details.isSetupComplete) {
      if (isNepali) {
        return '$childNameको दर्ता पूरा गर्न बाँकी छ। खोप तालिका हेर्न कृपया दर्ता पूरा गर्नुहोस्।';
      } else {
        return 'Setup is pending for $childName. Please complete registration to track vaccines.';
      }
    }

    final VaccinationDue? nextDue = details.nextDue;
    final String? nextDueDate = nextDue != null
        ? DateFormat('d MMMM y', locale).format(nextDue.dueDate)
        : null;

    if (isNepali) {
      if (details.hasOverdueDoses) {
        if (nextDue != null) {
          buffer.write(
            '$childNameको खोप लगाउने मिति नाघिसकेको छ। अर्को खोप: ${nextDue.vaccineCode}, मिति: $nextDueDate। ',
          );
        } else {
          buffer.write('$childNameको खोप लगाउने मिति नाघिसकेको छ। ');
        }
      } else if (details.hasDosesDueToday) {
        if (nextDue != null) {
          buffer.write(
            'आज $childNameको खोप लगाउने मिति हो: ${nextDue.vaccineCode}। ',
          );
        } else {
          buffer.write('आज $childNameको खोप लगाउने मिति हो। ');
        }
      } else if (details.hasDosesDueSoon) {
        if (nextDue != null) {
          buffer.write(
            '$childNameको अर्को खोप: ${nextDue.vaccineCode}, मिति: $nextDueDate। ',
          );
        }
      } else {
        if (nextDue != null) {
          buffer.write(
            '$childNameको खोप पूर्ण अवस्थामा छ। अर्को खोप: ${nextDue.vaccineCode}, मिति: $nextDueDate। ',
          );
        } else {
          buffer.write('$childNameका सबै खोपहरू पूर्ण भएका छन्। ');
        }
      }

      buffer.write('लागेका खोपहरू: ${details.records.length} मात्रा।');
    } else {
      if (details.hasOverdueDoses) {
        if (nextDue != null) {
          buffer.write(
            '$childName has overdue vaccines. Next vaccine: ${nextDue.vaccineCode}, due on $nextDueDate. ',
          );
        } else {
          buffer.write('$childName has overdue vaccines. ');
        }
      } else if (details.hasDosesDueToday) {
        if (nextDue != null) {
          buffer.write(
            'Vaccines are due today for $childName: ${nextDue.vaccineCode}. ',
          );
        } else {
          buffer.write('Vaccines are due today for $childName. ');
        }
      } else if (details.hasDosesDueSoon) {
        if (nextDue != null) {
          buffer.write(
            'Next vaccine for $childName: ${nextDue.vaccineCode}, due on $nextDueDate. ',
          );
        }
      } else {
        if (nextDue != null) {
          buffer.write(
            'Vaccinations are up to date for $childName. Next vaccine: ${nextDue.vaccineCode}, due on $nextDueDate. ',
          );
        } else {
          buffer.write('All vaccinations are completed for $childName. ');
        }
      }

      buffer.write('Completed vaccines: ${details.records.length} doses.');
    }

    return buffer.toString().trim();
  }

  /// Builds a spoken summary of the Health Facility details screen.
  static String healthFacilityScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
    required String? facilityName,
    required String? facilityAddress,
    required String? facilityPhone,
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';
    final bool hasInfo =
        (facilityName != null && facilityName.trim().isNotEmpty) ||
            (facilityAddress != null && facilityAddress.trim().isNotEmpty) ||
            (facilityPhone != null && facilityPhone.trim().isNotEmpty);

    final StringBuffer buffer = StringBuffer();
    if (isNepali) {
      buffer.write('स्थानीय स्वास्थ्य संस्थाको विवरण। ');
      if (hasInfo) {
        if (facilityName != null && facilityName.trim().isNotEmpty) {
          buffer.write('नाम: ${facilityName.trim()}। ');
        }
        if (facilityAddress != null && facilityAddress.trim().isNotEmpty) {
          buffer.write('ठेगाना: ${facilityAddress.trim()}। ');
        }
        if (facilityPhone != null && facilityPhone.trim().isNotEmpty) {
          buffer.write('फोन नम्बर: ${facilityPhone.trim()}। ');
        }
        buffer.write('तपाईं यी विवरणहरू परिवर्तन गर्न र सेभ गर्न सक्नुहुन्छ।');
      } else {
        buffer.write(
          'कृपया आफ्नो स्थानीय स्वास्थ्य संस्थाको नाम, ठेगाना, र फोन नम्बर प्रविष्ट गर्नुहोस्, र सेभ थिच्नुहोस्।',
        );
      }
    } else {
      buffer.write('Local health facility details. ');
      if (hasInfo) {
        if (facilityName != null && facilityName.trim().isNotEmpty) {
          buffer.write('Name: ${facilityName.trim()}. ');
        }
        if (facilityAddress != null && facilityAddress.trim().isNotEmpty) {
          buffer.write('Address: ${facilityAddress.trim()}. ');
        }
        if (facilityPhone != null && facilityPhone.trim().isNotEmpty) {
          buffer.write('Phone number: ${facilityPhone.trim()}. ');
        }
        buffer.write('You can edit these details and tap save.');
      } else {
        buffer.write(
          'Please enter your local health facility name, address, and phone number, then tap save.',
        );
      }
    }
    return buffer.toString().trim();
  }

  /// Builds a spoken summary for adding or registering a child.
  static String addChildScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
    required bool isOnboardingFlow,
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';
    if (isNepali) {
      return 'बच्चाको विवरण दर्ता गर्नुहोस्। '
          'कृपया बच्चाको पूरा नाम र जन्म मिति लेख्नुहोस्, तथा छोरी वा छोरा छान्नुहोस्। '
          'त्यसपछि बच्चा सेभ गर्नुहोस् थिच्नुहोस्।';
    } else {
      return 'Add child details. '
          'Please enter your child\'s full name, date of birth, and select their sex: female or male. '
          'Then press save child to proceed.';
    }
  }

  /// Builds a spoken summary for caregiver details (onboarding and editing).
  static String caregiverScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
    bool isEditing = false,
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';
    if (isNepali) {
      if (isEditing) {
        return 'अभिभावकको विवरण। '
            'कृपया आफ्नो नाम, फोन नम्बर, वा ठेगाना सम्पादन गर्नुहोस्, र सेभ थिच्नुहोस्।';
      }
      return 'अभिभावकको विवरण। '
          'कृपया आफ्नो पूरा नाम, फोन नम्बर, र ठेगाना लेख्नुहोस्। '
          'त्यसपछि बच्चा दर्ता गर्न जारी राख्नुहोस् थिच्नुहोस्।';
    } else {
      if (isEditing) {
        return 'Edit caregiver profile. '
            'Please update your name, phone number, or address, then tap save.';
      }
      return 'Caregiver information. '
          'Please enter your full name, phone number, and address. '
          'Then tap continue to add your child.';
    }
  }

  /// Builds a spoken summary of Vaccine Records & History.
  ///
  /// During onboarding/registration, prompts the user to tick vaccines for [childName],
  /// reads the vaccines according to the age-appropriate or all vaccines toggle,
  /// lists any currently ticked vaccines, and mentions the option to skip.
  ///
  /// From the child page's vaccine history, reads completed vaccines under the
  /// age-appropriate tab without listing upcoming doses, unless all vaccines is toggled.
  static String vaccineRecordsScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
    required String childName,
    required bool isRegistrationFlow,
    required bool showAllVaccines,
    required List<String> visibleVaccineNames,
    required List<String> tickedVaccineNames,
    required List<VaccinationRecord> records,
    required List<VaccinationDue> dues,
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';
    final StringBuffer buffer = StringBuffer();

    if (isRegistrationFlow) {
      if (isNepali) {
        buffer.write(
            'कृपया $childName लाई लगाइसकेका खोपहरूमा चिन्ह लगाउनुहोस्। ');
        if (showAllVaccines) {
          if (visibleVaccineNames.isNotEmpty) {
            buffer.write(
              'सबै खोपहरू देखाइएको छ: ${visibleVaccineNames.join(", ")}। ',
            );
          }
        } else {
          if (visibleVaccineNames.isNotEmpty) {
            buffer.write(
              'उमेर अनुसारका खोपहरू देखाइएको छ: ${visibleVaccineNames.join(", ")}। ',
            );
          } else {
            buffer.write('उमेर अनुसार कुनै खोप भेटिएन। ');
          }
        }

        if (tickedVaccineNames.isNotEmpty) {
          buffer.write(
              'चिन्ह लगाइएका खोपहरू: ${tickedVaccineNames.join(", ")}। ');
        } else {
          buffer.write('हाल कुनै खोप चिन्ह लगाइएको छैन। ');
        }

        buffer.write('तपाईं यसलाई अहिले छोड्न पनि सक्नुहुन्छ।');
      } else {
        buffer.write('Please tick the vaccines already given to $childName. ');
        if (showAllVaccines) {
          if (visibleVaccineNames.isNotEmpty) {
            buffer.write(
              'Showing all schedule vaccines: ${visibleVaccineNames.join(", ")}. ',
            );
          }
        } else {
          if (visibleVaccineNames.isNotEmpty) {
            buffer.write(
              'Showing age-appropriate vaccines: ${visibleVaccineNames.join(", ")}. ',
            );
          } else {
            buffer.write('No age-appropriate vaccines found. ');
          }
        }

        if (tickedVaccineNames.isNotEmpty) {
          buffer.write('Ticked vaccines: ${tickedVaccineNames.join(", ")}. ');
        } else {
          buffer.write('No vaccines ticked yet. ');
        }

        buffer.write('You can also skip this for now.');
      }
      return buffer.toString().trim();
    }

    // Normal Vaccine History flow from Child Page
    if (isNepali) {
      buffer.write('$childNameको खोप इतिहास। ');
      if (records.isNotEmpty) {
        final String recList = records
            .map((VaccinationRecord r) => r.vaccineCode)
            .toSet()
            .join(', ');
        buffer.write('लागेका खोपहरू: $recList। ');
      } else {
        buffer.write('हालसम्म कुनै खोप रेकर्ड गरिएको छैन। ');
      }

      // Only read upcoming vaccines if the user has explicitly selected all vaccines tab
      if (showAllVaccines && dues.isNotEmpty) {
        final String dueList =
            dues.map((VaccinationDue d) => d.vaccineCode).toSet().join(', ');
        buffer.write('आगामी खोपहरू: $dueList। ');
      }
    } else {
      buffer.write('Vaccine history for $childName. ');
      if (records.isNotEmpty) {
        final String recList = records
            .map((VaccinationRecord r) => r.vaccineCode)
            .toSet()
            .join(', ');
        buffer.write('Completed vaccines: $recList. ');
      } else {
        buffer.write('No vaccines recorded yet. ');
      }

      // Only read upcoming vaccines if the user has explicitly selected all vaccines tab
      if (showAllVaccines && dues.isNotEmpty) {
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

    final String backup = '${localizations.backupSectionTitle}. '
        '${localizations.backupExportAction}. '
        '${localizations.backupImportAction}. '
        '${localizations.backupPhoneChangeNote} '
        '${localizations.backupPrivacyNote}';
    if (isNepali) {
      return 'सेटिङहरू। भाषा छनोट: हाल नेपाली भाषा चयन गरिएको छ। '
          'अभिभावकको विवरण हेर्न र सम्पादन गर्न सकिन्छ। '
          'बालबालिकाको विवरण सम्पादन गर्न सकिन्छ। '
          'नजिकैको स्वास्थ्य संस्थाको सम्पर्क विवरण उपलब्ध छ। '
          '$backup';
    } else {
      return 'Settings. Language options: English or Nepali. '
          'Caregiver profile management. '
          'Child profiles editing. '
          'Local health facility contact information. '
          '$backup';
    }
  }

  /// Builds a spoken summary of the Record Dose screen reflecting the 2 actual steps:
  /// Step 1: Check date given
  /// Step 2: Tick the given vaccines (reads which vaccines are currently ticked, or available)
  static String recordDoseScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
    required String childName,
    required DateTime administeredDate,
    required List<String> tickedVaccineNames,
    required List<String> availableVaccineNames,
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';
    final String locale = Localizations.localeOf(context).languageCode;
    final String dateStr =
        DateFormat('d MMMM y', locale).format(administeredDate);

    final StringBuffer buffer = StringBuffer();

    if (isNepali) {
      buffer.write('$childNameको खोप मात्रा दर्ता। ');
      buffer.write(
          'चरण १: खोप लगाएको मिति जाँच गर्नुहोस्। हालको मिति $dateStr छ। ');
      buffer.write('चरण २: लगाइएका खोपहरूमा चिन्ह लगाउनुहोस्। ');

      if (tickedVaccineNames.isNotEmpty) {
        buffer.write(
          'चिन्ह लगाइएका खोपहरू: ${tickedVaccineNames.join(", ")}। सुरक्षित गर्न सेभ थिच्नुहोस्।',
        );
      } else {
        if (availableVaccineNames.isNotEmpty) {
          buffer.write(
            'हाल कुनै खोप चिन्ह लगाइएको छैन। उपलब्ध खोपहरू: ${availableVaccineNames.join(", ")}। कृपया खोप छान्नुहोस् र सेभ थिच्नुहोस्।',
          );
        } else {
          buffer.write('हाल कुनै खोप उपलब्ध छैन।');
        }
      }
    } else {
      buffer.write('Log vaccine dose for $childName. ');
      buffer.write('Step 1: Check the date given. Current date is $dateStr. ');
      buffer.write('Step 2: Tick the given vaccines. ');

      if (tickedVaccineNames.isNotEmpty) {
        buffer.write(
          'Ticked vaccines: ${tickedVaccineNames.join(", ")}. Tap save to record.',
        );
      } else {
        if (availableVaccineNames.isNotEmpty) {
          buffer.write(
            'No vaccines ticked yet. Available vaccines: ${availableVaccineNames.join(", ")}. Please tick the vaccines given, then tap save.',
          );
        } else {
          buffer.write('No due vaccines available.');
        }
      }
    }

    return buffer.toString().trim();
  }
}
