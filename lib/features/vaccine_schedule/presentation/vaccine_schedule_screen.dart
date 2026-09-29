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
          data: (details) => _VaccineScheduleTable(
            dues: details.orderedDueVaccines,
            records: details.orderedVaccineRecords
                .where((record) =>
                    details.now.difference(record.administeredDate).inDays <= 7)
                .toList(),
            now: details.now,
          ),
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

    bool isAfterNowDivider = false;
    int duesIndex = 0;
    int recordsIndex = 0;

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
                        bool isDuesRow;
                        if (duesIndex == dues.length) {
                          isDuesRow = false;
                        } else if (recordsIndex == records.length) {
                          isDuesRow = true;
                        } else {
                          final due = dues[duesIndex];
                          final record = records[recordsIndex];

                          isDuesRow =
                              due.dueDate.isBefore(record.administeredDate);
                        }
                        final isFirst = index == 0;
                        final isLast =
                            index == dues.length + records.length - 1;

                        Row vaccineRow;
                        bool isPast;
                        if (isDuesRow) {
                          final due = dues[duesIndex];
                          isPast = due.dueDate.isBefore(now);
                          final statusColor = isPast
                              ? const Color(0xFFF5B544)
                              : const Color(0xFF94A3B8);
                          final statusDarker = isPast
                              ? const Color(0xFFF5B544)
                              : const Color(0xFF475569);

                          vaccineRow = makeVaccineRow(
                              '${due.vaccineCode} (${localizations.dose} ${due.doseNumber})',
                              DateFormat('d MMM y', locale).format(due.dueDate),
                              isFirst,
                              isLast,
                              statusColor,
                              statusDarker,
                              false);
                          duesIndex++;
                        } else {
                          final record = records[recordsIndex];
                          isPast = true;

                          vaccineRow = makeVaccineRow(
                              '${record.vaccineCode} (${localizations.dose} ${record.doseNumber})',
                              DateFormat('d MMM y', locale)
                                  .format(record.administeredDate),
                              isFirst,
                              isLast,
                              const Color(0xFF166534),
                              const Color(0xFF166534),
                              true);
                          recordsIndex++;
                        }

                        if (!isAfterNowDivider && (!isPast || isLast)) {
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
                                        margin: const EdgeInsets.fromLTRB(
                                            12, 0, 12, 0)))
                              ]));

                          if (!isPast) {
                            isAfterNowDivider = true;
                            return Column(children: [todayDivider, vaccineRow]);
                          } else {
                            return Column(children: [vaccineRow, todayDivider]);
                          }
                        } else {
                          return vaccineRow;
                        }
                      },
                      itemCount: dues.length + records.length)),
          ],
        ),
      ),
    );
  }
}

Row makeVaccineRow(String vaccine, String date, bool isFirst, bool isLast,
    Color statusColor, Color statusDarker, bool isCompleted) {
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
          Icon(isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
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
