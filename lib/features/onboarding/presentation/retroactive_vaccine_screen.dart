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

class RetroactiveVaccineScreen extends ConsumerStatefulWidget {
  const RetroactiveVaccineScreen({
    super.key,
    required this.childId,
    required this.isOnboardingFlow,
  });

  final String childId;
  final bool isOnboardingFlow;

  @override
  ConsumerState<RetroactiveVaccineScreen> createState() =>
      _RetroactiveVaccineScreenState();
}

class _RetroactiveVaccineScreenState
    extends ConsumerState<RetroactiveVaccineScreen> {
  bool _showAll = false;
  final Map<String, DateTime> _checkedDoses = {};
  bool _isSaving = false;
  bool _initialized = false;

  void _toggleShowAll(bool value) {
    setState(() {
      _showAll = value;
    });
  }

  void _toggleDose(String vaccineCode, int doseNumber, bool isChecked,
      DateTime defaultDate) {
    setState(() {
      final key = '$vaccineCode-$doseNumber';
      if (isChecked) {
        _checkedDoses[key] = defaultDate;
      } else {
        _checkedDoses.remove(key);
      }
    });
  }

  Future<void> _selectDate(BuildContext context, String key,
      DateTime initialDate, DateTime dob) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: dob,
      lastDate: DateTime.now(),
      builder: (context, child) {
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _finish(bool markComplete) async {
    setState(() => _isSaving = true);
    try {
      final db = ref.read(appDatabaseProvider);

      if (markComplete) {
        final recordsDao = db.vaccinationRecordsDao;
        // First delete any existing records for this child to avoid unique constraint issues
        await (db.delete(db.vaccinationRecords)
              ..where((row) => row.childId.equals(widget.childId)))
            .go();

        if (_checkedDoses.isNotEmpty) {
          for (final entry in _checkedDoses.entries) {
            final key = entry.key;
            final administeredDate = entry.value;
            final parts = key.split('-');
            final code = parts[0];
            final dose = int.parse(parts[1]);

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
        await db.childProfilesDao.setSetupComplete(widget.childId, true);
        await db.vaccinationDuesDao.recalculateDuesForChild(widget.childId);
      }

      ref.invalidate(homeStatusGroupsProvider);
      ref.invalidate(childProfileProvider(widget.childId));

      if (mounted) {
        if (widget.isOnboardingFlow) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(
                builder: (context) => const AppShellScreen()),
            (route) => false,
          );
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving vaccines: $e')),
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
    final localizations = AppLocalizations.of(context)!;
    final childState = ref.watch(childProfileProvider(widget.childId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isOnboardingFlow
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        child: childState.when(
          data: (details) {
            final child = details.child;
            final now = DateTime.now();
            final age = now.difference(child.dateOfBirth);

            if (!_initialized) {
              for (var record in details.records) {
                _checkedDoses['${record.vaccineCode}-${record.doseNumber}'] =
                    record.administeredDate;
              }
              _initialized = true;
            }

            final List<Widget> vaccineCheckboxes = [];

            nipCatalogue.forEach((vaccineCode, ages) {
              for (int i = 0; i < ages.length; i++) {
                final doseNumber = i + 1;
                final doseAge = ages[i];
                final isPast = age >= doseAge.duration;

                if (isPast || _showAll) {
                  final key = '$vaccineCode-$doseNumber';
                  final isChecked = _checkedDoses.containsKey(key);
                  final defaultDate = child.dateOfBirth.add(doseAge.duration);
                  final cappedDate =
                      defaultDate.isAfter(now) ? now : defaultDate;

                  vaccineCheckboxes.add(
                    Column(
                      children: [
                        CheckboxListTile(
                          title: Text(
                            '$vaccineCode (Dose $doseNumber)',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          value: isChecked,
                          activeColor: const Color(0xFF0F52BA),
                          onChanged: (bool? value) {
                            if (value != null) {
                              _toggleDose(
                                  vaccineCode, doseNumber, value, cappedDate);
                            }
                          },
                        ),
                        if (isChecked)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 32, right: 16, bottom: 8),
                            child: Row(
                              children: [
                                Text(
                                  localizations.retroactiveVaccineDateLabel(
                                      _formatDate(_checkedDoses[key]!)),
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xFF475569)),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => _selectDate(context, key,
                                      _checkedDoses[key]!, child.dateOfBirth),
                                  child: Text(localizations
                                      .retroactiveVaccineChangeDate),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }
              }
            });

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.isOnboardingFlow) ...[
                          Row(
                            children: [
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
                          ),
                          const SizedBox(height: 32),
                        ],
                        Text(
                          localizations.retroactiveVaccineTitle,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          localizations.retroactiveVaccineSubtitle(child.name),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (vaccineCheckboxes.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'No past vaccines for this age.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          )
                        else
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                children: [
                                  ...vaccineCheckboxes,
                                  const Divider(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            localizations
                                                .retroactiveVaccineShowAllSubtitle,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF64748B)),
                                          ),
                                        ),
                                        Switch(
                                          value: _showAll,
                                          activeThumbColor:
                                              const Color(0xFF0F52BA),
                                          onChanged: _toggleShowAll,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: _isSaving ? null : () => _finish(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F52BA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                localizations.retroactiveVaccineFinish,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isSaving ? null : () => _finish(false),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          localizations.retroactiveVaccineSkip,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
