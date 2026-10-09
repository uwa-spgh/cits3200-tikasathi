import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/nip/vaccine_display.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/home/domain/home_models.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

/// Helper to generate natural, conversational spoken summaries for each screen
/// tailored for low-literacy caregivers in both English and Nepali.
class ScreenSpeechHelper {
  /// Builds the short purpose-and-navigation summary for the Learn screen.
  static String learnScreenText({
    required AppLocalizations localizations,
  }) {
    return localizations.learnSpeechSummary;
  }

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
          case HomeVaccinationGroup.overdue:
            buffer.write('ढिलो भएका खोप भएका बालबालिका: $names। ');
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
          case HomeVaccinationGroup.overdue:
            buffer.write('Overdue vaccines for: $names. ');
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

    final ScrollPosition? position = Scrollable.maybeOf(context)?.position;
    if (position != null &&
        position.hasContentDimensions &&
        position.pixels < position.maxScrollExtent) {
      buffer.write(' ${localizations.homeScrollInstruction}');
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
      return localizations.childSetupIncompleteSpeech(childName);
    }

    final VaccinationDue? nextDue = details.nextDue;
    final DateTime today =
        DateTime(details.now.year, details.now.month, details.now.day);
    final String? nextDueDate = nextDue != null
        ? DateFormat('d MMMM y', locale).format(nextDue.dueDate)
        : null;
    final bool nextDueIsOverdue = nextDue != null &&
        DateTime(
          nextDue.dueDate.year,
          nextDue.dueDate.month,
          nextDue.dueDate.day,
        ).isBefore(today);

    if (isNepali) {
      if (details.hasOverdueDoses) {
        if (nextDue != null) {
          buffer.write(
            '$childNameको खोप लगाउने मिति नाघिसकेको छ। अर्को खोप: '
            '${nextDue.vaccineCode}, '
            '${nextDueIsOverdue ? localizations.recordDoseOverdueLabel(nextDueDate!) : localizations.childSpeechVaccineDueOn(nextDueDate!)}। ',
          );
        } else {
          buffer.write('$childNameको खोप लगाउने मिति नाघिसकेको छ। ');
        }
        buffer.write('${localizations.childSpeechOverdueAdvice} ');
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
    } else {
      if (details.hasOverdueDoses) {
        if (nextDue != null) {
          buffer.write(
            '$childName has overdue vaccines. Next vaccine: '
            '${nextDue.vaccineCode}, '
            '${nextDueIsOverdue ? localizations.recordDoseOverdueLabel(nextDueDate!) : localizations.childSpeechVaccineDueOn(nextDueDate!)}. ',
          );
        } else {
          buffer.write('$childName has overdue vaccines. ');
        }
        buffer.write('${localizations.childSpeechOverdueAdvice} ');
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
          buffer.write('फोन नम्बर: ${_spellPhoneNumber(facilityPhone)}। ');
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
          buffer.write('Phone number: ${_spellPhoneNumber(facilityPhone)}. ');
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

  static String _spellPhoneNumber(String phone) {
    return phone.trim().split('').join(' ');
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

  /// Builds a spoken summary for editing child details.
  static String childEditScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';
    if (isNepali) {
      return 'बच्चाको प्रोफाइल सम्पादन गर्नुहोस्। '
          'कृपया बच्चाको नाम, जन्म मिति, वा लिङ्ग सम्पादन गर्नुहोस्, र सेभ थिच्नुहोस्।';
    }
    return 'Edit child profile. '
        'Please update the child\'s name, date of birth, or sex, then tap save.';
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
    List<String> recordedVaccineNames = const <String>[],
    List<String> unrecordedVaccineNames = const <String>[],
    bool isUpToDate = false,
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

    if (showAllVaccines) {
      if (recordedVaccineNames.isEmpty) {
        buffer.write(
          '${localizations.vaccineHistoryFullShownNoRecorded(childName)} ',
        );
      } else {
        buffer.write('${localizations.vaccineHistoryFullShown(childName)} ');
        buffer.write(
          '${localizations.vaccineHistoryRecordedIncludeFull(
            _joinSpeechItems(recordedVaccineNames, isNepali: isNepali),
          )} ',
        );
      }
      if (unrecordedVaccineNames.isNotEmpty) {
        buffer.write('${localizations.vaccineHistoryOtherUnrecorded} ');
        buffer.write(
          '${localizations.vaccineHistoryLaterSchedule(childName)} ',
        );
      }
      buffer.write(localizations.vaccineHistoryEditAdvice);
    } else {
      if (isUpToDate) {
        buffer.write('${localizations.vaccineHistoryUpToDate(childName)} ');
        if (recordedVaccineNames.isNotEmpty) {
          buffer.write(
            '${localizations.vaccineHistoryRecordedInclude(
              _joinSpeechItems(recordedVaccineNames, isNepali: isNepali),
            )} ',
          );
        }
        buffer.write(localizations.vaccineHistoryUpToDateEditAdvice);
      } else {
        if (recordedVaccineNames.isNotEmpty) {
          buffer.write(
            '${localizations.vaccineHistoryRecordedAgeAppropriate(
              childName,
              _joinSpeechItems(recordedVaccineNames, isNepali: isNepali),
            )} ',
          );
        } else {
          buffer.write(
            '${localizations.vaccineHistoryNoRecordedAgeAppropriate(childName)} ',
          );
        }
        if (unrecordedVaccineNames.isNotEmpty) {
          buffer.write(
            '${localizations.vaccineHistoryUnrecordedAgeAppropriate(
              _joinSpeechItems(unrecordedVaccineNames, isNepali: isNepali),
            )} ',
          );
        }
        buffer.write('${localizations.vaccineHistoryMissedAdvice} ');
        buffer.write(localizations.vaccineHistoryEditAdvice);
      }
    }

    return buffer.toString().trim();
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static Map<DateTime, List<String>> _groupSpeechItems<T>(
    List<T> items, {
    required DateTime Function(T item) dateOf,
    required String Function(T item) itemOf,
  }) {
    final Map<DateTime, List<String>> groups = <DateTime, List<String>>{};
    for (final T item in items) {
      final DateTime date = _dateOnly(dateOf(item));
      groups.putIfAbsent(date, () => <String>[]).add(itemOf(item));
    }
    return groups;
  }

  static void _appendSpeechGroups(
    StringBuffer buffer,
    Map<DateTime, List<String>> groups, {
    required bool isNepali,
    required String locale,
    required String category,
    required String Function(String date, String vaccines) singular,
    required String Function(String date, String vaccines) plural,
  }) {
    if (groups.isEmpty) return;
    buffer.write('$category ');
    final List<DateTime> dates = groups.keys.toList()..sort();
    for (final DateTime date in dates) {
      final String vaccines = _joinSpeechItems(
        groups[date]!,
        isNepali: isNepali,
      );
      final String dateText = DateFormat('d MMMM y', locale).format(date);
      buffer.write(groups[date]!.length == 1
          ? singular(dateText, vaccines)
          : plural(dateText, vaccines));
      buffer.write(' ');
    }
  }

  static void _appendUpcomingSpeechGroups(
    StringBuffer buffer,
    Map<DateTime, List<String>> groups, {
    required bool isNepali,
    required String locale,
    required AppLocalizations localizations,
  }) {
    if (groups.isEmpty) return;
    buffer.write('${localizations.vaccineScheduleUpcomingCategory} ');
    final List<DateTime> dates = groups.keys.toList()..sort();
    final DateTime today = _dateOnly(DateTime.now());
    for (final DateTime date in dates) {
      final String vaccines = _joinSpeechItems(
        groups[date]!,
        isNepali: isNepali,
      );
      if (date == today) {
        buffer.write(groups[date]!.length == 1
            ? localizations.vaccineScheduleUpcomingTodaySingular(vaccines)
            : localizations.vaccineScheduleUpcomingTodayPlural(vaccines));
      } else {
        final String dateText = DateFormat('d MMMM y', locale).format(date);
        buffer.write(groups[date]!.length == 1
            ? localizations.vaccineScheduleUpcomingGroupSingular(
                dateText,
                vaccines,
              )
            : localizations.vaccineScheduleUpcomingGroupPlural(
                dateText,
                vaccines,
              ));
      }
      buffer.write(' ');
    }
  }

  /// Builds a spoken summary of the Vaccine Schedule screen.
  static String vaccineScheduleScreenText({
    required BuildContext context,
    required AppLocalizations localizations,
    List<VaccinationDue> dues = const <VaccinationDue>[],
    List<VaccinationRecord> records = const <VaccinationRecord>[],
  }) {
    final bool isNepali = Localizations.localeOf(context).languageCode == 'ne';
    if (dues.isEmpty && records.isEmpty) {
      return isNepali
          ? 'नेपालको राष्ट्रिय बाल खोप तालिका। बीसीजी, पेन्टाभालेन्ट, रोटाभाइरस, पिसिभी, एफआइपीभी, दादुरा-रुबेला र टाइफाइड खोपहरू।'
          : 'National Immunisation Schedule of Nepal. BCG, Pentavalent, Rotavirus, PCV, fIPV, Measles-Rubella and Typhoid vaccines.';
    }
    final String locale = Localizations.localeOf(context).languageCode;
    final StringBuffer buffer = StringBuffer(
      isNepali ? 'खोप तालिका। ' : 'Vaccination schedule. ',
    );
    _appendSpeechGroups(
      buffer,
      _groupSpeechItems<VaccinationRecord>(
        records,
        dateOf: (VaccinationRecord record) => record.administeredDate,
        itemOf: (VaccinationRecord record) => vaccineHasSingleDose(
          record.vaccineCode,
        )
            ? record.vaccineCode
            : '${record.vaccineCode} ${record.doseNumber}',
      ),
      isNepali: isNepali,
      locale: locale,
      category: localizations.vaccineScheduleAdministeredCategory,
      singular: localizations.vaccineScheduleAdministeredGroupSingular,
      plural: localizations.vaccineScheduleAdministeredGroupPlural,
    );

    final DateTime today = _dateOnly(DateTime.now());
    final List<VaccinationDue> missed = dues
        .where((VaccinationDue due) => _dateOnly(due.dueDate).isBefore(today))
        .toList();
    final List<VaccinationDue> upcoming = dues
        .where((VaccinationDue due) => !_dateOnly(due.dueDate).isBefore(today))
        .toList();
    _appendSpeechGroups(
      buffer,
      _groupSpeechItems<VaccinationDue>(
        missed,
        dateOf: (VaccinationDue due) => due.dueDate,
        itemOf: (VaccinationDue due) => vaccineHasSingleDose(due.vaccineCode)
            ? due.vaccineCode
            : '${due.vaccineCode} ${due.doseNumber}',
      ),
      isNepali: isNepali,
      locale: locale,
      category: localizations.vaccineScheduleMissedCategory,
      singular: localizations.vaccineScheduleMissedGroupSingular,
      plural: localizations.vaccineScheduleMissedGroupPlural,
    );
    if (missed.isNotEmpty) {
      buffer.write('${localizations.vaccineScheduleMissedAdvice} ');
    }
    _appendUpcomingSpeechGroups(
      buffer,
      _groupSpeechItems<VaccinationDue>(
        upcoming,
        dateOf: (VaccinationDue due) => due.dueDate,
        itemOf: (VaccinationDue due) => vaccineHasSingleDose(due.vaccineCode)
            ? due.vaccineCode
            : '${due.vaccineCode} ${due.doseNumber}',
      ),
      isNepali: isNepali,
      locale: locale,
      localizations: localizations,
    );
    return buffer.toString().trim();
  }

  static String _joinSpeechItems(
    List<String> items, {
    required bool isNepali,
  }) {
    if (items.length < 2) return items.join();
    final conjunction = isNepali ? ' र ' : ' and ';
    if (items.length == 2) return items.join(conjunction);
    return '${items.sublist(0, items.length - 1).join(', ')}$conjunction${items.last}';
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
          'प्रोफाइलहरू व्यवस्थापन गर्नुहोस्: हेरचाहकर्ताको प्रोफाइल सम्पादन। '
          'बालबालिकाको प्रोफाइल सम्पादन। बालबालिकाको प्रोफाइल मेटाउनुहोस्। '
          'बच्चाको खोप तालिका सम्पादन गर्नुहोस्। यो स्वास्थ्यकर्मीका लागि मात्र हो। '
          '$backup';
    } else {
      return 'Settings. Language options: English or Nepali. '
          'Manage profiles: Caregiver profile editing. '
          'Child profiles editing. Delete child profile. '
          "Edit child's vaccination schedule. "
          'This is for healthcare professionals only. '
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
