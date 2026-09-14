import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
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
                  Text(
                    localizations.vaccineScheduleTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF11284F),
                        ),
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
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Text(localizations.vaccineScheduleDoseHeader),
                      ),
                      DataColumn(
                        label: Text(localizations.vaccineScheduleDueHeader),
                      ),
                    ],
                    rows: dues
                        .map(
                          (due) => DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '${due.vaccineCode} (${localizations.dose} ${due.doseNumber})',
                                ),
                              ),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'd MMMM y',
                                        locale,
                                      ).format(due.dueDate),
                                    ),
                                    Text(
                                      formatVaccineDueRelativeDate(
                                        due.dueDate,
                                        now,
                                        localizations,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: const Color(0xFF4B5E7B),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(
                  localizations.vaccineScheduleReturn,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
