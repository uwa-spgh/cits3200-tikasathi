import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/core/services/screen_speech_helper.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';

class VaccineScheduleScreen extends ConsumerWidget {
  const VaccineScheduleScreen({required this.childId, super.key});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(childProfileProvider(childId));
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      body: SafeArea(
        child: state.when(
          data: (details) {
            final start = details.orderedVaccineRecords.length - 5;
            return _VaccineScheduleTable(
              dues: details.orderedDueVaccines,
              records:
                  details.orderedVaccineRecords.sublist(start < 0 ? 0 : start),
              now: details.now,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text(localizations.childNotFound)),
        ),
      ),
    );
  }
}

class _VaccineScheduleTable extends StatelessWidget {
  const _VaccineScheduleTable(
      {required this.dues, required this.records, required this.now});

  final List<VaccinationDue> dues;
  final List<VaccinationRecord> records;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    final merged = _merge(dues, records);
    int todayDividerIndex = merged.length;
    for (int i = 0; i < merged.length; i++) {
      final vaccine = merged[i];
      if (vaccine.date.isAfter(now)) {
        todayDividerIndex = i;
        break;
      }
    }

    final todayDivider = Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Row(children: [
          Text(
              '${localizations.vaccineScheduleToday} · ${DateFormat('d MMM y', locale).format(now)}',
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0F52BA),
                  fontWeight: FontWeight.w500)),
          Flexible(
              child: Container(
                  height: 2,
                  color: const Color(0xFF0F52BA),
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 0)))
        ]));

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: localizations.vaccineScheduleBack,
                  ),
                  Expanded(
                      child: Text(
                    localizations.vaccineScheduleTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF11284F),
                        ),
                  )),
                  ReadAloudButton(
                    tooltip: localizations.childReadAloudTooltip,
                    unavailableMessage: localizations.childReadAloudUnavailable,
                    textGetter: () =>
                        ScreenSpeechHelper.vaccineScheduleScreenText(
                      context: context,
                      localizations: localizations,
                    ),
                  ),
                ],
              ),
            ),
            if (dues.isEmpty && records.isEmpty)
              Expanded(
                child: Center(child: Text(localizations.vaccineScheduleEmpty)),
              )
            else
              Expanded(
                  child: ListView.builder(
                      itemBuilder: (context, index) {
                        final data = merged[index];
                        final isFirst = index == 0;
                        final isLast =
                            index == dues.length + records.length - 1;
                        final isPast = index < todayDividerIndex;

                        final statusColor = data.isDue
                            ? isPast
                                ? const Color(0xFFF5B544)
                                : const Color(0xFF94A3B8)
                            : const Color(0xFF166534);
                        final statusDarker = data.isDue
                            ? isPast
                                ? const Color(0xFFF5B544)
                                : const Color(0xFF475569)
                            : const Color(0xFF166534);

                        final vaccineRow = makeVaccineRow(
                            '${data.vaccineCode} (${localizations.dose} ${data.doseNumber})',
                            DateFormat('d MMM y', locale).format(data.date),
                            isFirst,
                            isLast,
                            statusColor,
                            statusDarker,
                            data.isDue);

                        if (index == todayDividerIndex) {
                          return Column(children: [todayDivider, vaccineRow]);
                        } else if (isLast && index < todayDividerIndex) {
                          return Column(children: [vaccineRow, todayDivider]);
                        } else {
                          return vaccineRow;
                        }
                      },
                      itemCount: merged.length)),
          ],
        ),
      ),
    );
  }
}

Row makeVaccineRow(String vaccine, String date, bool isFirst, bool isLast,
    Color statusColor, Color statusDarker, bool isDue) {
  return Row(children: [
    Flexible(
        child: Align(
            alignment: Alignment.topRight,
            child: Text(date,
                style: TextStyle(
                    fontSize: 13,
                    color: statusColor,
                    fontWeight: FontWeight.w500)))),
    Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Column(children: [
          Container(
              width: 2,
              height: 12,
              color: isFirst ? Colors.transparent : const Color(0xFF94A3B8)),
          Icon(isDue ? Icons.check_box_outline_blank : Icons.check_box,
              color: statusColor),
          Container(
              width: 2,
              height: 12,
              color: isLast ? Colors.transparent : const Color(0xFF94A3B8))
        ])),
    Flexible(
        flex: 2,
        child: Text(vaccine,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: statusDarker,
            )))
  ]);
}

typedef _VaccineData = ({
  bool isDue,
  String vaccineCode,
  int doseNumber,
  DateTime date
});

List<_VaccineData> _merge(
    List<VaccinationDue> dues, List<VaccinationRecord> records) {
  int duesIndex = 0;
  int recordsIndex = 0;
  final result = <_VaccineData>[];
  for (int i = 0; i < dues.length + records.length; i++) {
    if (duesIndex == dues.length) {
      final record = records[recordsIndex];
      result.add((
        isDue: false,
        vaccineCode: record.vaccineCode,
        doseNumber: record.doseNumber,
        date: record.administeredDate
      ));
      recordsIndex++;
    } else if (recordsIndex == records.length) {
      final due = dues[duesIndex];
      result.add((
        isDue: true,
        vaccineCode: due.vaccineCode,
        doseNumber: due.doseNumber,
        date: due.dueDate
      ));
      duesIndex++;
    } else {
      final due = dues[duesIndex];
      final record = records[recordsIndex];
      if (due.dueDate.isBefore(record.administeredDate)) {
        result.add((
          isDue: true,
          vaccineCode: due.vaccineCode,
          doseNumber: due.doseNumber,
          date: due.dueDate
        ));
        duesIndex++;
      } else {
        result.add((
          isDue: false,
          vaccineCode: record.vaccineCode,
          doseNumber: record.doseNumber,
          date: record.administeredDate
        ));
        recordsIndex++;
      }
    }
  }
  return result;
}

String formatVaccineDueRelativeDate(
  DateTime dueDate,
  DateTime now,
  AppLocalizations localizations,
) {
  final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final today = DateTime(now.year, now.month, now.day);
  final days = dueDay.difference(today).inDays;

  if (days == 0) return localizations.vaccineScheduleToday;
  if (days < 0) {
    return localizations.vaccineScheduleOverdueBy((-days).toString());
  }
  if (days < 30) {
    return localizations.vaccineScheduleInDays(days);
  }

  final months = days ~/ 30;
  if (months < 12) {
    return localizations.vaccineScheduleInMonths(months);
  }

  final years = months ~/ 12;
  final remainingMonths = months % 12;
  return remainingMonths == 0
      ? localizations.vaccineScheduleInYears(years)
      : localizations.vaccineScheduleInYearsMonths(
          remainingMonths,
          years,
        );
}
