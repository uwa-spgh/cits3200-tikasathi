import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/nip/vaccine_catalogue.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/home/domain/home_status_groups_provider.dart';

class VaccineScheduleEditorScreen extends ConsumerStatefulWidget {
  const VaccineScheduleEditorScreen({required this.childId, super.key});

  final String childId;

  @override
  ConsumerState<VaccineScheduleEditorScreen> createState() =>
      _VaccineScheduleEditorScreenState();
}

class _VaccineScheduleEditorScreenState
    extends ConsumerState<VaccineScheduleEditorScreen> {
  bool _showAll = false;
  bool _saving = false;

  Future<void> _editDue(
    BuildContext context,
    ChildProfile child,
    VaccinationDue due,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    String vaccine = due.vaccineCode;
    int dose = due.doseNumber;
    DateTime date = due.dueDate;
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.scheduleEditorEdit),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: vaccine,
                decoration:
                    InputDecoration(labelText: l10n.scheduleEditorVaccine),
                items: [
                  for (final code in nipCatalogue.keys)
                    DropdownMenuItem(value: code, child: Text(code)),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() {
                    vaccine = value;
                    dose = 1;
                  });
                },
              ),
              DropdownButtonFormField<int>(
                initialValue: dose,
                decoration: InputDecoration(labelText: l10n.scheduleEditorDose),
                items: [
                  for (int index = 1;
                      index <= nipCatalogue[vaccine]!.length;
                      index++)
                    DropdownMenuItem(value: index, child: Text('$index')),
                ],
                onChanged: (value) {
                  if (value != null) setDialogState(() => dose = value);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.scheduleEditorDueDate),
                subtitle: Text(DateFormat(
                        'd MMM y', Localizations.localeOf(context).languageCode)
                    .format(date)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate:
                        date.isBefore(DateTime.now()) ? DateTime.now() : date,
                    firstDate: child.dateOfBirth,
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() => date = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.profileCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(date),
              child: Text(l10n.profileSave),
            ),
          ],
        ),
      ),
    );
    if (selectedDate == null || !context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.scheduleEditorSaveConfirmTitle),
        content: Text(l10n.scheduleEditorSaveConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.profileCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.scheduleEditorSave),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final existing = await db.manualVaccinationScheduleOverridesDao.forTarget(
        widget.childId,
        due.vaccineCode,
        due.doseNumber,
      );
      final sourceCode = existing?.sourceVaccineCode ?? due.vaccineCode;
      final sourceDose = existing?.sourceDoseNumber ?? due.doseNumber;
      await db.manualVaccinationScheduleOverridesDao.saveOverride(
        childId: widget.childId,
        sourceVaccineCode: sourceCode,
        sourceDoseNumber: sourceDose,
        vaccineCode: vaccine,
        doseNumber: dose,
        dueDate: selectedDate,
      );
      await db.vaccinationDuesDao.recalculateDuesForChild(widget.childId);
      ref.invalidate(childProfileProvider(widget.childId));
      ref.invalidate(homeStatusGroupsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.scheduleEditorSaveSuccess)),
        );
      }
    } catch (error) {
      if (context.mounted) {
        final message = error.toString().contains('already administered')
            ? l10n.scheduleEditorAdministeredDose
            : error.toString().contains('already scheduled')
                ? l10n.scheduleEditorDuplicateDose
                : l10n.scheduleEditorSaveError;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (context.mounted) setState(() => _saving = false);
    }
  }

  Future<void> _restoreDefault() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.scheduleEditorRestoreTitle),
        content: Text(l10n.scheduleEditorRestoreMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.profileCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.scheduleEditorRestoreConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      await db.manualVaccinationScheduleOverridesDao
          .deleteAllForChild(widget.childId);
      await db.vaccinationDuesDao.recalculateDuesForChild(widget.childId);
      ref.invalidate(childProfileProvider(widget.childId));
      ref.invalidate(homeStatusGroupsProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.scheduleEditorSaveError)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(childProfileProvider(widget.childId));
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        title: Text(l10n.scheduleEditorTitle),
        backgroundColor: const Color(0xFFFFF8E6),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text(l10n.scheduleEditorSaveError)),
        data: (details) {
          final age = DateTime.now().difference(details.child.dateOfBirth);
          final dues = details.orderedDueVaccines.where((due) {
            if (_showAll) return true;
            final doseAge = getDoseAge(due.vaccineCode, due.doseNumber);
            return doseAge != null && age >= doseAge.duration;
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                        value: false,
                        label: Text(l10n.vaccineHistoryFilterAgeAppropriate)),
                    ButtonSegment(
                        value: true, label: Text(l10n.vaccineHistoryFilterAll)),
                  ],
                  selected: {_showAll},
                  onSelectionChanged: (value) =>
                      setState(() => _showAll = value.first),
                ),
              ),
              Expanded(
                child: dues.isEmpty
                    ? Center(child: Text(l10n.scheduleEditorEmpty))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                        itemCount: dues.length,
                        itemBuilder: (_, index) {
                          final due = dues[index];
                          return Card(
                            color: const Color(0xFFFFF8E6),
                            child: ListTile(
                              leading: const Icon(Icons.calendar_month,
                                  color: Color(0xFF9A5B00)),
                              title: Text(
                                  '${due.vaccineCode} (${l10n.scheduleEditorDose} ${due.doseNumber})'),
                              subtitle: Text(DateFormat(
                                      'd MMM y',
                                      Localizations.localeOf(context)
                                          .languageCode)
                                  .format(due.dueDate)),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_calendar,
                                    color: Color(0xFF9A5B00)),
                                onPressed: _saving
                                    ? null
                                    : () =>
                                        _editDue(context, details.child, due),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: OutlinedButton.icon(
            onPressed: _saving ? null : _restoreDefault,
            icon: const Icon(Icons.restore),
            label: Text(l10n.scheduleEditorRestore),
          ),
        ),
      ),
    );
  }
}
