import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/nip/vaccine_catalogue.dart';
import 'package:tikasathi/features/app_shell/presentation/app_shell_screen.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/home/domain/home_status_groups_provider.dart';

/// Unified screen combining Vaccine Records and Vaccine History.
///
/// Features:
/// - Clear heading and top-left back navigation.
/// - Filter toggle between age-appropriate vaccines and all schedule vaccines.
/// - Dose name on the left, checkbox to record administration, and administered
///   date on the right (with date picker edit capability).
/// - Atomic save updating records and recalculating dues in SQLite.
class VaccineRecordsScreen extends ConsumerStatefulWidget {
  const VaccineRecordsScreen({
    required this.childId,
    this.isOnboardingFlow = false,
    this.isRegistrationFlow,
    super.key,
  });

  final String childId;
  final bool isOnboardingFlow;
  final bool? isRegistrationFlow;

  @override
  ConsumerState<VaccineRecordsScreen> createState() =>
      _VaccineRecordsScreenState();
}

class _VaccineRecordsScreenState extends ConsumerState<VaccineRecordsScreen> {
  bool _showAll = false;
  final Map<String, DateTime> _checkedDoses = <String, DateTime>{};
  bool _isSaving = false;
  bool _initialized = false;

  bool get _isRegistration =>
      widget.isRegistrationFlow ?? widget.isOnboardingFlow;

  void _toggleShowAll(bool value) {
    setState(() {
      _showAll = value;
    });
  }

  void _toggleDose(
    String vaccineCode,
    int doseNumber,
    bool isChecked,
    DateTime defaultDate,
  ) {
    setState(() {
      final String key = '$vaccineCode-$doseNumber';
      if (isChecked) {
        _checkedDoses[key] = defaultDate;
      } else {
        _checkedDoses.remove(key);
      }
    });
  }

  Future<void> _selectDate(
    BuildContext context,
    String key,
    DateTime initialDate,
    DateTime dob,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: dob,
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F52BA),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _checkedDoses[key] = picked;
      });
    }
  }

  Future<void> _save(bool markComplete) async {
    setState(() => _isSaving = true);
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    try {
      final AppDatabase db = ref.read(appDatabaseProvider);

      if (markComplete) {
        final VaccinationRecordsDao recordsDao = db.vaccinationRecordsDao;
        await (db.delete(db.vaccinationRecords)
              ..where((row) => row.childId.equals(widget.childId)))
            .go();

        if (_checkedDoses.isNotEmpty) {
          for (final MapEntry<String, DateTime> entry
              in _checkedDoses.entries) {
            final String key = entry.key;
            final DateTime administeredDate = entry.value;
            final List<String> parts = key.split('-');
            final String code = parts[0];
            final int dose = int.parse(parts[1]);

            await recordsDao.insertVaccinationRecord(
              VaccinationRecordsCompanion.insert(
                id: const Uuid().v4(),
                childId: widget.childId,
                vaccineCode: code,
                doseNumber: dose,
                administeredDate: administeredDate,
              ),
            );
          }
        }
      }

      if (markComplete) {
        await db.childProfilesDao.setSetupComplete(widget.childId, true);
      }
      await db.vaccinationDuesDao.recalculateDuesForChild(widget.childId);

      ref.invalidate(homeStatusGroupsProvider);
      ref.invalidate(childProfileProvider(widget.childId));

      final List<VaccinationDue> dues = await db.vaccinationDuesDao
          .getVaccinationDuesForChild(widget.childId);
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final bool hasOverdue = dues.any((VaccinationDue due) {
        final DateTime dueDay =
            DateTime(due.dueDate.year, due.dueDate.month, due.dueDate.day);
        return dueDay.isBefore(today);
      });

      if (mounted) {
        setState(() => _isSaving = false);
        if (markComplete && hasOverdue) {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFCD2E2E),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations.overdueVaccinesDialogTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                content: Text(
                  localizations.overdueVaccinesDialogMessage,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                actions: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F52BA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(localizations.actionUnderstand),
                  ),
                ],
              );
            },
          );
        } else if (markComplete) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.vaccineHistorySavedSuccess),
            ),
          );
        }

        if (mounted) {
          if (widget.isOnboardingFlow) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const AppShellScreen(),
              ),
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.pop(context);
          }
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving vaccines: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final AsyncValue<ChildProfileDetails> childState =
        ref.watch(childProfileProvider(widget.childId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isOnboardingFlow
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                tooltip: localizations.childBackTooltip,
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          localizations.childVaccineRecordsAndHistory,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ReadAloudButton(
              tooltip: localizations.childReadAloudTooltip,
              unavailableMessage: localizations.childReadAloudUnavailable,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: childState.when(
          data: (ChildProfileDetails details) {
            final ChildProfile child = details.child;
            final DateTime now = DateTime.now();
            final Duration age = now.difference(child.dateOfBirth);

            if (!_initialized) {
              for (final VaccinationRecord record in details.records) {
                _checkedDoses['${record.vaccineCode}-${record.doseNumber}'] =
                    record.administeredDate;
              }
              _initialized = true;
            }

            final List<_DoseItemData> items = <_DoseItemData>[];

            nipCatalogue.forEach((String vaccineCode, List<DayDuration> ages) {
              for (int i = 0; i < ages.length; i++) {
                final int doseNumber = i + 1;
                final DayDuration doseAge = ages[i];
                final bool isPast = age >= doseAge.duration;
                final String key = '$vaccineCode-$doseNumber';
                final bool isChecked = _checkedDoses.containsKey(key);

                if (isPast || _showAll || isChecked) {
                  final DateTime defaultDate =
                      child.dateOfBirth.add(doseAge.duration);
                  final DateTime cappedDate =
                      defaultDate.isAfter(now) ? now : defaultDate;

                  items.add(
                    _DoseItemData(
                      vaccineCode: vaccineCode,
                      doseNumber: doseNumber,
                      keyName: key,
                      isChecked: isChecked,
                      administeredDate: _checkedDoses[key],
                      scheduledDate: defaultDate,
                      fallbackDate: cappedDate,
                    ),
                  );
                }
              }
            });

            return Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      ListView(
                        padding: const EdgeInsets.fromLTRB(16, 70, 16, 24),
                        children: <Widget>[
                          if (widget.isOnboardingFlow) ...<Widget>[
                            _OnboardingStepsHeader(
                                localizations: localizations),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            localizations
                                .retroactiveVaccineSubtitle(child.name),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (items.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  localizations.vaccineRecordsEmpty,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            )
                          else
                            ...items.map(
                              (_DoseItemData item) => _VaccineDoseRow(
                                item: item,
                                localizations: localizations,
                                onToggle: (bool isChecked) {
                                  _toggleDose(
                                    item.vaccineCode,
                                    item.doseNumber,
                                    isChecked,
                                    item.fallbackDate,
                                  );
                                },
                                onPickDate: () {
                                  _selectDate(
                                    context,
                                    item.keyName,
                                    item.administeredDate ?? item.fallbackDate,
                                    child.dateOfBirth,
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      Positioned(
                        top: 10,
                        left: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x1F000000),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: _FilterToggleCard(
                            showAll: _showAll,
                            onToggle: _toggleShowAll,
                            localizations: localizations,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _BottomActionBar(
                  isSaving: _isSaving,
                  isRegistration: _isRegistration,
                  localizations: localizations,
                  onSave: () => _save(true),
                  onSkipOrReturn: _isRegistration
                      ? () => _save(false)
                      : () => Navigator.pop(context),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}

class _DoseItemData {
  const _DoseItemData({
    required this.vaccineCode,
    required this.doseNumber,
    required this.keyName,
    required this.isChecked,
    required this.administeredDate,
    required this.scheduledDate,
    required this.fallbackDate,
  });

  final String vaccineCode;
  final int doseNumber;
  final String keyName;
  final bool isChecked;
  final DateTime? administeredDate;
  final DateTime scheduledDate;
  final DateTime fallbackDate;
}

class _FilterToggleCard extends StatelessWidget {
  const _FilterToggleCard({
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
        children: <Widget>[
          Expanded(
            child: _FilterSegment(
              isSelected: !showAll,
              label: localizations.vaccineHistoryFilterAgeAppropriate,
              icon: Icons.child_care_rounded,
              onTap: () => onToggle(false),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _FilterSegment(
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

class _FilterSegment extends StatelessWidget {
  const _FilterSegment({
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
            children: <Widget>[
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

class _VaccineDoseRow extends StatelessWidget {
  const _VaccineDoseRow({
    required this.item,
    required this.localizations,
    required this.onToggle,
    required this.onPickDate,
  });

  final _DoseItemData item;
  final AppLocalizations localizations;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final String label =
        '${item.vaccineCode} (${localizations.dose} ${item.doseNumber})';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: item.isChecked ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isChecked
              ? const Color(0xFF86EFAC)
              : const Color(0xFFE2E8F0),
          width: item.isChecked ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onToggle(!item.isChecked),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              Transform.scale(
                scale: 1.15,
                child: Checkbox(
                  value: item.isChecked,
                  activeColor: const Color(0xFF0F52BA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (bool? value) {
                    if (value != null) {
                      onToggle(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: item.isChecked
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (item.isChecked && item.administeredDate != null)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onPickDate,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          DateFormat('d MMMM y',
                                  Localizations.localeOf(context).languageCode)
                              .format(item.administeredDate!),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF166534),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.edit_calendar_rounded,
                          size: 16,
                          color: Color(0xFF166534),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  DateFormat('d MMM y',
                          Localizations.localeOf(context).languageCode)
                      .format(item.scheduledDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.isSaving,
    required this.isRegistration,
    required this.localizations,
    required this.onSave,
    required this.onSkipOrReturn,
  });

  final bool isSaving;
  final bool isRegistration;
  final AppLocalizations localizations;
  final VoidCallback onSave;
  final VoidCallback onSkipOrReturn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F52BA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    isRegistration
                        ? localizations.retroactiveVaccineFinish
                        : localizations.vaccineHistorySaveChanges,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: isSaving ? null : onSkipOrReturn,
            child: Text(
              isRegistration
                  ? localizations.retroactiveVaccineSkip
                  : localizations.vaccineRecordsReturn,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStepsHeader extends StatelessWidget {
  const _OnboardingStepsHeader({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF0F52BA),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF0F52BA),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF0F52BA),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          localizations.onboardingStepLabel(3, 3),
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
