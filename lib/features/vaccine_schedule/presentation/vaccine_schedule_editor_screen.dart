import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/nip/vaccine_display.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/home/domain/home_helpers.dart';
import 'package:tikasathi/features/home/domain/home_status_groups_provider.dart';

enum _ScheduleEditAction { save }

class _ScheduleEditResult {
  const _ScheduleEditResult(this.action, this.date);

  final _ScheduleEditAction action;
  final DateTime date;
}

class VaccineScheduleEditorScreen extends ConsumerStatefulWidget {
  const VaccineScheduleEditorScreen({required this.childId, super.key});

  final String childId;

  @override
  ConsumerState<VaccineScheduleEditorScreen> createState() =>
      _VaccineScheduleEditorScreenState();
}

class _ScheduleFilterToggleCard extends StatelessWidget {
  const _ScheduleFilterToggleCard({
    required this.showAll,
    required this.onToggle,
    required this.localizations,
  });

  final bool showAll;
  final ValueChanged<bool> onToggle;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ScheduleFilterSegment(
              isSelected: !showAll,
              label: localizations.vaccineHistoryFilterAgeAppropriate,
              icon: Icons.child_care_rounded,
              onTap: () => onToggle(false),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ScheduleFilterSegment(
              isSelected: showAll,
              label: localizations.vaccineHistoryFilterAll,
              icon: Icons.format_list_bulleted_rounded,
              onTap: () => onToggle(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleFilterSegment extends StatelessWidget {
  const _ScheduleFilterSegment({
    required this.isSelected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final bool isSelected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      elevation: isSelected ? 1 : 0,
      shadowColor: const Color(0x1A000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? const Color(0xFF0F52BA)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0F52BA)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleDueRow extends StatelessWidget {
  const _ScheduleDueRow({
    required this.vaccineCode,
    required this.doseNumber,
    required this.dueDate,
    required this.localizations,
    required this.onEdit,
  });

  final String vaccineCode;
  final int doseNumber;
  final DateTime dueDate;
  final AppLocalizations localizations;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final label = formatVaccineDisplayName(
      localizations,
      vaccineCode,
      doseNumber,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'd MMM y',
                        Localizations.localeOf(context).languageCode,
                      ).format(dueDate),
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton(
                iconSize: 28,
                color: const Color(0xFF0F52BA),
                icon: const Icon(Icons.edit_calendar),
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    DateTime date = due.dueDate;
    final result = await showDialog<_ScheduleEditResult>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
          contentPadding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
          actionsPadding: const EdgeInsets.fromLTRB(32, 24, 32, 28),
          title: Text(
            l10n.scheduleEditorEdit,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                due.vaccineCode,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 4),
              if (!vaccineHasSingleDose(due.vaccineCode)) ...[
                Text(
                  '${l10n.scheduleEditorDose} ${due.doseNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 20),
              ] else
                const SizedBox(height: 16),
              Text(
                l10n.scheduleEditorDueDateChange,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate:
                        date.isBefore(DateTime.now()) ? DateTime.now() : date,
                    firstDate: child.dateOfBirth,
                    lastDate: DateTime(2100),
                    builder: (context, picker) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF0F52BA),
                        ),
                      ),
                      child: picker!,
                    ),
                  );
                  if (picked != null) {
                    setDialogState(() => date = picked);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF0F52BA),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat(
                            'd MMM y',
                            Localizations.localeOf(context).languageCode,
                          ).format(date),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.edit_calendar,
                        color: Color(0xFF0F52BA),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () async {
                    final removed = await _confirmRemoveDue(
                      dialogContext,
                      child,
                      due,
                    );
                    if (removed && dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  label: Text(l10n.scheduleEditorRemove),
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F52BA),
                      side: const BorderSide(color: Color(0xFF0F52BA)),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.profileCancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F52BA),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(
                      _ScheduleEditResult(_ScheduleEditAction.save, date),
                    ),
                    child: Text(l10n.profileSave),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (result == null || !context.mounted) return;

    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      await db.manualVaccinationScheduleOverridesDao.saveDateOverride(
        childId: widget.childId,
        vaccineCode: due.vaccineCode,
        doseNumber: due.doseNumber,
        dueDate: result.date,
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

  Future<bool> _confirmRemoveDue(
    BuildContext context,
    ChildProfile child,
    VaccinationDue due,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        contentPadding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
        actionsPadding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
        title: Text(
          l10n.scheduleEditorRemoveTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.scheduleEditorRemoveMessage(
            due.vaccineCode,
            due.doseNumber.toString(),
          ),
        ),
        actions: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  autofocus: true,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F52BA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.profileCancel),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.scheduleEditorRemoveConfirm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return false;
    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      await db.manualVaccinationScheduleOverridesDao.removeDose(
        childId: widget.childId,
        vaccineCode: due.vaccineCode,
        doseNumber: due.doseNumber,
      );
      await db.vaccinationDuesDao.recalculateDuesForChild(widget.childId);
      ref.invalidate(childProfileProvider(widget.childId));
      ref.invalidate(homeStatusGroupsProvider);
      if (!context.mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.scheduleEditorRemoveSuccess(
              due.vaccineCode,
              due.doseNumber.toString(),
              child.name,
            ),
          ),
        ),
      );
      return true;
    } catch (_) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.scheduleEditorSaveError)),
      );
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _restoreDefault() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        contentPadding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
        actionsPadding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
        title: Text(
          l10n.scheduleEditorRestoreTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Text(l10n.scheduleEditorRestoreMessage),
        actions: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  autofocus: true,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F52BA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.profileCancel),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F52BA),
                    side: const BorderSide(color: Color(0xFF0F52BA)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.scheduleEditorRestoreConfirm),
                ),
              ],
            ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          tooltip: l10n.childBackTooltip,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          state.when(
            data: (details) =>
                l10n.scheduleEditorTitleForChild(details.child.name),
            loading: () => l10n.scheduleEditorTitle,
            error: (_, __) => l10n.scheduleEditorTitle,
          ),
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text(l10n.scheduleEditorSaveError)),
        data: (details) {
          // Same window as Log vaccine: overdue, due today, or due soon.
          final today = DateUtils.dateOnly(details.now);
          final dues = details.orderedDueVaccines.where((due) {
            if (_showAll) return true;
            return !DateUtils.dateOnly(due.dueDate).isAfter(today) ||
                isDueSoon(due.dueDate, today);
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: _ScheduleFilterToggleCard(
                  showAll: _showAll,
                  onToggle: (showAll) => setState(() => _showAll = showAll),
                  localizations: l10n,
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
                          return _ScheduleDueRow(
                            vaccineCode: due.vaccineCode,
                            doseNumber: due.doseNumber,
                            dueDate: due.dueDate,
                            localizations: l10n,
                            onEdit: _saving
                                ? null
                                : () => _editDue(context, details.child, due),
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
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0F52BA),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: _saving ? null : _restoreDefault,
            icon: const Icon(Icons.restore),
            label: Text(l10n.scheduleEditorRestore),
          ),
        ),
      ),
    );
  }
}
