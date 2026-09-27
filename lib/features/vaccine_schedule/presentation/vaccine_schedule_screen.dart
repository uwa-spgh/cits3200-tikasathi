import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
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
  const _VaccineScheduleTable({required this.dues, required this.now});

  final List<VaccinationDue> dues;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    bool isAfterNowDivider = false;

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
                  Expanded(child: 
                    Text(
                      localizations.vaccineScheduleTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF11284F),
                      ),
                    )
                  ),
                  ReadAloudButton(
                    tooltip: localizations.childReadAloudTooltip,
                    unavailableMessage: localizations.childReadAloudUnavailable,
                  ),
                ],
              ),
            ),
            if (dues.isEmpty)
              Expanded(
                child: Center(child: Text(localizations.vaccineScheduleEmpty)),
              )
            else
              Expanded(
                child: ListView.builder(itemBuilder: (context, index) {
                  final due = dues[index];
                  final isOverdue = due.dueDate.isBefore(now);
                  final statusColor = isOverdue ? const Color(0xFFF5B544) : const Color(0xFF94A3B8);
                  final statusDarker = isOverdue ? const Color(0xFFF5B544) : const Color(0xFF475569);
                  final isFirst = index == 0;
                  final isLast = index == dues.length - 1;

                  final vaccineRow = Row(children: [
                    Flexible(child: Align(alignment: Alignment.topRight, child: Text(
                      DateFormat('d MMM y', locale).format(due.dueDate),
                      style: TextStyle(fontSize: 13, color: statusColor, fontWeight: FontWeight.w500)
                      ))
                    ),
                    Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 0), child: 
                      Column(children: [
                        Container(width: 2, height: 12, color: isFirst ? Colors.transparent : const Color(0xFF94A3B8)),
                        Icon(Icons.check_box_outline_blank, color: statusColor),
                        Container(width: 2, height: 12, color: isLast ? Colors.transparent : const Color(0xFF94A3B8))
                      ])
                    ),
                    Flexible(flex: 2, child: Text('${due.vaccineCode} (${localizations.dose} ${due.doseNumber})', style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: statusDarker,
                    )))
                  ]);

                  if (!isAfterNowDivider && !isOverdue) {
                    isAfterNowDivider = true;
                    return Column(children: [
                      Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 0), child: Row(
                        children: [
                          Text(
                            '${localizations.vaccineScheduleToday} · ${DateFormat('d MMM y', locale).format(now)}',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF0F52BA), fontWeight: FontWeight.w500)
                          ),
                          Flexible(child: Container(height: 2, color: const Color(0xFF0F52BA), margin: const EdgeInsets.fromLTRB(12, 0, 12, 0)))
                      ])),
                      vaccineRow
                    ]);
                  } else {
                    return vaccineRow;
                  }
                }, itemCount: dues.length)
              ),
          ],
        ),
      ),
    );
  }
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
