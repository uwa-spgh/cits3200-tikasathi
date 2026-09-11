import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/nip/vaccine_catalogue.dart';
import 'package:tikasathi/features/app_shell/presentation/app_shell_screen.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/home/domain/home_status_groups_provider.dart';

class VaccineRecordsScreen extends ConsumerWidget {
  const VaccineRecordsScreen({
    required this.childId,
    super.key
  });

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
          loading: () => const Center(child: CircularProgressIndicator())
          ),
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
      DataColumn(label: Text('L10N - Vaccination')),
      DataColumn(label: Text('L10N - Dose Number')),
      DataColumn(label: Text('L10N - Date Administered')),
    ];
    final List<DataRow> tableRows = records.map((record) =>
      DataRow(cells: <DataCell>[
        DataCell(Text(record.vaccineCode)),
        DataCell(Text(record.doseNumber.toString())),
        DataCell(Text(record.administeredDate.toString())),
        ])
    ).toList();

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: DataTable(columns: tableColumns, rows: tableRows),
      )
    );
  }

  
}