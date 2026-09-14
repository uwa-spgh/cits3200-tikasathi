import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/theme/app_theme.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/record_dose/domain/record_dose_controller.dart';

const Color _pageBackground = Color(0xFFF5F9FC);
const Color _navy = Color(0xFF11284F);
const Color _actionBlue = Color(0xFF0E64C5);
const Color _slate = Color(0xFF475569);
const Color _amberBorder = Color(0xFFFFB949);
const Color _amberSurface = Color(0xFFFFF4DE);
const Color _amberText = Color(0xFFC97700);
const Color _blueSurface = Color(0xFFEFF5FF);
const Color _blueBorder = Color(0xFFCFE0FA);
const Color _overdueSurface = Color(0xFFF9E0E0);
const Color _overdueText = Color(0xFFB51D1D);
const Color _upToDateSurface = Color(0xFFEAF8EF);
const Color _neutralBorder = Color(0xFFE2E8F0);

/// Lets a caregiver record the doses a child was given during a clinic visit.
///
/// Doses owed today or already overdue are listed first; the rest of the
/// schedule is hidden behind a toggle so the common case stays short.
class RecordDoseScreen extends ConsumerStatefulWidget {
  const RecordDoseScreen({super.key, required this.childId});

  final String childId;

  @override
  ConsumerState<RecordDoseScreen> createState() => _RecordDoseScreenState();
}

class _RecordDoseScreenState extends ConsumerState<RecordDoseScreen> {
  bool _isSaving = false;

  Future<void> _pickDate(RecordDoseState recordDoseState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: recordDoseState.administeredDate,
      firstDate: recordDoseState.child.dateOfBirth,
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: _actionBlue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref
          .read(recordDoseControllerProvider(widget.childId).notifier)
          .setAdministeredDate(picked);
    }
  }

  Future<void> _save(RecordDoseState recordDoseState) async {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final int count = recordDoseState.selectedCount;

    setState(() => _isSaving = true);
    final bool saved = await ref
        .read(recordDoseControllerProvider(widget.childId).notifier)
        .save();
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? localizations.recordDoseSuccess(
                  count, recordDoseState.child.name)
              : localizations.recordDoseError,
        ),
      ),
    );

    if (saved) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final AsyncValue<RecordDoseState> recordDoseAsync =
        ref.watch(recordDoseControllerProvider(widget.childId));

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: recordDoseAsync.when(
              // A failed save keeps its data, so the screen stays on the form
              // with the ticks intact; the snackbar reports the failure. Only a
              // failed initial load, which has no data, falls through to
              // [_ErrorBody].
              skipError: true,
              data: (RecordDoseState recordDoseState) => _RecordDoseBody(
                recordDoseState: recordDoseState,
                localizations: localizations,
                isSaving: _isSaving,
                onToggleDose: (String dueId) => ref
                    .read(recordDoseControllerProvider(widget.childId).notifier)
                    .toggleDose(dueId),
                onToggleShowAll: (bool showAll) => ref
                    .read(recordDoseControllerProvider(widget.childId).notifier)
                    .setShowAllUpcoming(showAll),
                onChangeDate: () => _pickDate(recordDoseState),
                onSave: () => _save(recordDoseState),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _ErrorBody(localizations: localizations),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordDoseBody extends StatelessWidget {
  const _RecordDoseBody({
    required this.recordDoseState,
    required this.localizations,
    required this.isSaving,
    required this.onToggleDose,
    required this.onToggleShowAll,
    required this.onChangeDate,
    required this.onSave,
  });

  final RecordDoseState recordDoseState;
  final AppLocalizations localizations;
  final bool isSaving;
  final ValueChanged<String> onToggleDose;
  final ValueChanged<bool> onToggleShowAll;
  final VoidCallback onChangeDate;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final List<VaccinationDue> visibleDues = recordDoseState.visibleDues;

    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  recordDoseState.upcomingDues.isNotEmpty ? 76 : 24,
                ),
                children: <Widget>[
                  _Header(localizations: localizations),
                  const SizedBox(height: 14),
                  Text(
                    localizations
                        .recordDoseSubtitle(recordDoseState.child.name),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: _slate),
                  ),
                  const SizedBox(height: 24),
                  _StepHeading(
                    stepNumber: 1,
                    label: localizations.recordDoseStepDate,
                  ),
                  const SizedBox(height: 10),
                  _DateCard(
                    date: recordDoseState.administeredDate,
                    isToday: recordDoseState.isToday(
                      recordDoseState.administeredDate,
                    ),
                    localizations: localizations,
                    onChangeDate: onChangeDate,
                  ),
                  const SizedBox(height: 24),
                  _StepHeading(
                    stepNumber: 2,
                    label: localizations.recordDoseStepSelect,
                  ),
                  const SizedBox(height: 10),
                  if (visibleDues.isEmpty)
                    _EmptyState(
                      childName: recordDoseState.child.name,
                      localizations: localizations,
                    )
                  else
                    _DueList(
                      dues: visibleDues,
                      recordDoseState: recordDoseState,
                      localizations: localizations,
                      onToggleDose: onToggleDose,
                    ),
                ],
              ),
              if (recordDoseState.upcomingDues.isNotEmpty)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _ShowAllButton(
                      showAll: recordDoseState.showAllUpcoming,
                      localizations: localizations,
                      onChanged: onToggleShowAll,
                    ),
                  ),
                ),
            ],
          ),
        ),
        _SaveBar(
          recordDoseState: recordDoseState,
          localizations: localizations,
          isSaving: isSaving,
          onSave: onSave,
        ),
      ],
    );
  }
}

/// Shown when the child could not be loaded at all. It keeps the header so the
/// caregiver always has a way back out — an error with no exit reads as a
/// broken app.
class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _Header(localizations: localizations),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                localizations.recordDoseError,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: localizations.childBackTooltip,
        ),
        Expanded(
          child: Text(
            localizations.recordDoseTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
          ),
        ),
        ReadAloudButton(
          tooltip: localizations.childReadAloudTooltip,
          unavailableMessage: localizations.childReadAloudUnavailable,
        ),
      ],
    );
  }
}

/// Numbered heading, so the screen reads as an ordered set of steps rather
/// than a wall of controls.
class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.stepNumber, required this.label});

  final int stepNumber;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: _actionBlue,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$stepNumber',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
          ),
        ),
      ],
    );
  }
}

/// Mirrors the "next vaccine" card on the child page. The whole card opens the
/// date picker, and a "tap to change" hint spells that out — a bare date with
/// a small link is easy to miss if you do not read confidently.
class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.date,
    required this.isToday,
    required this.localizations,
    required this.onChangeDate,
  });

  final DateTime date;
  final bool isToday;
  final AppLocalizations localizations;
  final VoidCallback onChangeDate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: const Key('record-dose-change-date'),
        onTap: onChangeDate,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _amberBorder, width: 2),
          ),
          child: Row(
            children: <Widget>[
              const CircleAvatar(
                radius: 24,
                backgroundColor: _amberSurface,
                child: Icon(
                  Icons.event_available_rounded,
                  color: _amberText,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          localizations.recordDoseDateTitle,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _navy,
                                  ),
                        ),
                        if (isToday)
                          _Pill(
                            label: localizations.recordDoseToday,
                            background: _amberSurface,
                            foreground: _amberText,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatLongDate(context, date),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _navy,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      localizations.recordDoseTapToChange,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _amberText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_calendar_rounded, color: _amberText),
            ],
          ),
        ),
      ),
    );
  }
}

class _DueList extends StatelessWidget {
  const _DueList({
    required this.dues,
    required this.recordDoseState,
    required this.localizations,
    required this.onToggleDose,
  });

  final List<VaccinationDue> dues;
  final RecordDoseState recordDoseState;
  final AppLocalizations localizations;
  final ValueChanged<String> onToggleDose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final VaccinationDue due in dues)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DueTile(
              due: due,
              isSelected: recordDoseState.isSelected(due.id),
              isOverdue: recordDoseState.isOverdue(due),
              localizations: localizations,
              onToggle: () => onToggleDose(due.id),
            ),
          ),
      ],
    );
  }
}

/// One tappable dose row. The whole card is the touch target, not just the
/// checkbox, because the app targets low-literacy users on small screens.
class _DueTile extends StatelessWidget {
  const _DueTile({
    required this.due,
    required this.isSelected,
    required this.isOverdue,
    required this.localizations,
    required this.onToggle,
  });

  final VaccinationDue due;
  final bool isSelected;
  final bool isOverdue;
  final AppLocalizations localizations;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final String dueDateLabel = _formatShortDate(context, due.dueDate);

    return Semantics(
      label: localizations.recordDoseDoseLabel(due.vaccineCode, due.doseNumber),
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? _blueSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: Key('record-dose-item-${due.vaccineCode}-${due.doseNumber}'),
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 84),
            padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _actionBlue : _neutralBorder,
                width: isSelected ? 3 : 2,
              ),
            ),
            child: Row(
              children: <Widget>[
                _TickBox(isSelected: isSelected),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              due.vaccineCode,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: _navy,
                                  ),
                            ),
                          ),
                          if (isSelected)
                            _Pill(
                              label: localizations.recordDoseTickedLabel,
                              background: _upToDateSurface,
                              foreground: AppTheme.statusUpToDateText,
                              icon: Icons.check_rounded,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          _Pill(
                            label: localizations
                                .recordDoseDoseChip(due.doseNumber),
                            background: _blueSurface,
                            foreground: _actionBlue,
                          ),
                          _Pill(
                            label: isOverdue
                                ? localizations
                                    .recordDoseOverdueLabel(dueDateLabel)
                                : localizations
                                    .recordDoseDueLabel(dueDateLabel),
                            background:
                                isOverdue ? _overdueSurface : _amberSurface,
                            foreground: isOverdue ? _overdueText : _amberText,
                            icon: isOverdue
                                ? Icons.warning_amber_rounded
                                : Icons.calendar_month,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
          ),
        ],
      ),
    );
  }
}

/// A labelled button rather than a switch. A switch states a setting; this
/// states the action, which is easier to act on without confident reading.
class _ShowAllButton extends StatelessWidget {
  const _ShowAllButton({
    required this.showAll,
    required this.localizations,
    required this.onChanged,
  });

  final bool showAll;
  final AppLocalizations localizations;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('record-dose-show-all'),
      onPressed: () => onChanged(!showAll),
      style: OutlinedButton.styleFrom(
        foregroundColor: _actionBlue,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: _blueBorder, width: 2),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
      icon: Icon(
        showAll ? Icons.expand_less_rounded : Icons.expand_more_rounded,
      ),
      label: Text(
        showAll
            ? localizations.recordDoseShowFewer
            : localizations.recordDoseShowMore,
      ),
    );
  }
}

/// A large, unambiguous tick target. The stock Checkbox is 18px of ink; this
/// reads as ticked or not from arm's length.
class _TickBox extends StatelessWidget {
  const _TickBox({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected ? _actionBlue : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? _actionBlue : const Color(0xFF94A3B8),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
          : null,
    );
  }
}

/// Reuses the child page's "up to date" colouring so an empty list reads as
/// good news rather than as a missing screen.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.childName, required this.localizations});

  final String childName;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _upToDateSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.statusUpToDate, width: 2),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.statusUpToDate,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            localizations.recordDoseNoneDue(childName),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.statusUpToDateText,
                ),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.recordDoseState,
    required this.localizations,
    required this.isSaving,
    required this.onSave,
  });

  final RecordDoseState recordDoseState;
  final AppLocalizations localizations;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final bool canSave = recordDoseState.canSave && !isSaving;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            localizations
                .recordDoseSelectedSummary(recordDoseState.selectedCount),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: _slate, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('record-dose-save'),
            onPressed: canSave ? onSave : null,
            style: FilledButton.styleFrom(
              backgroundColor: _actionBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.vaccines_rounded),
            label: Text(
              recordDoseState.canSave
                  ? localizations
                      .recordDoseSaveCount(recordDoseState.selectedCount)
                  : localizations.recordDoseSaveEmpty,
            ),
          ),
        ],
      ),
    );
  }
}

/// Long form date, matching the child page header.
String _formatLongDate(BuildContext context, DateTime date) {
  return DateFormat('d MMMM y', Localizations.localeOf(context).languageCode)
      .format(date);
}

/// Short form date with year, matching the requirement to show the year doses are due.
String _formatShortDate(BuildContext context, DateTime date) {
  return DateFormat('d MMM y', Localizations.localeOf(context).languageCode)
      .format(date);
}
