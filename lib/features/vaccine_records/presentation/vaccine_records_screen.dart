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

class _VaccineRecordsTable extends StatefulWidget {
  const _VaccineRecordsTable({required this.records});

  final List<VaccinationRecord> records;

  @override
  State<StatefulWidget> createState() => _VaccineRecordsState();
}

class _VaccineRecordsState extends State<_VaccineRecordsTable> {
  bool _sortDate = true;
  bool _sortAscending = false;

  void _sortColumn(int columnIndex, bool ascending) {
    setState(() {
      _sortDate = columnIndex == 1;
      _sortAscending = ascending;

      if (_sortDate) {
        if (_sortAscending) {
          widget.records.sort((a, b) => a.administeredDate.compareTo(b.administeredDate));
        } else {
          widget.records.sort((a, b) => b.administeredDate.compareTo(a.administeredDate));
        }
      } else {
        if (_sortAscending) {
          widget.records.sort((a, b) {
            final sortCode = a.vaccineCode.compareTo(b.vaccineCode);
            final sortDose = a.doseNumber.compareTo(b.doseNumber);
            return sortCode == 0 ? sortDose : sortCode;
          });
        } else {
          widget.records.sort((a, b) {
            final sortCode = b.vaccineCode.compareTo(a.vaccineCode);
            final sortDose = b.doseNumber.compareTo(a.doseNumber);
            return sortCode == 0 ? sortDose : sortCode;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final tableColumns = <DataColumn>[
      DataColumn(label: Text(localizations.vaccineRecordsDoseHeader), onSort: _sortColumn),
      DataColumn(label: Text(localizations.vaccineRecordsDateHeader), onSort: _sortColumn),
    ];
    final List<DataRow> tableRows = widget.records
        .map((record) => DataRow(cells: <DataCell>[
              DataCell(
                  Text('${record.vaccineCode} (${localizations.dose} ${record.doseNumber})')),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: DataTable(columns: tableColumns, rows: tableRows, sortColumnIndex: _sortDate ? 1 : 0, sortAscending: _sortAscending,),
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
                        localizations.vaccineRecordsReturn,
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