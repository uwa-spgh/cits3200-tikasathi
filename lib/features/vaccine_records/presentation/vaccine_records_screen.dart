import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';

class VaccineRecordsScreen extends ConsumerWidget {
  const VaccineRecordsScreen({required this.childId, super.key});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childState = ref.watch(childProfileProvider(childId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      body: SafeArea(
        child: childState.when(
            data: (details) => _VaccineRecordsTable(records: details.records),
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
            loading: () => const Center(child: CircularProgressIndicator())),
      ),
    );
  }
}

class _VaccineRecordsTable extends StatelessWidget {
  const _VaccineRecordsTable({required this.records});

  final List<VaccinationRecord> records;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final tableColumns = <DataColumn>[
      DataColumn(label: Text('L10N - Vaccine Dose')),
      DataColumn(label: Text('L10N - Date Administered')),
    ];
    final List<DataRow> tableRows = records
        .map((record) => DataRow(cells: <DataCell>[
              DataCell(
                  Text('${record.vaccineCode} - Dose ${record.doseNumber}')),
              DataCell(Text(DateFormat(
                      'd MMMM y', Localizations.localeOf(context).languageCode)
                  .format(record.administeredDate))),
            ]))
        .toList();

    return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: DataTable(columns: tableColumns, rows: tableRows),
              )),
              Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: TextButton(
                      onPressed: () => {Navigator.pop(context)},
                      child: Text(
                        'L10N - Return',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )))
            ],
          ),
        ));
  }
}
