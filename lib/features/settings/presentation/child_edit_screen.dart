import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/home/domain/home_status_groups_provider.dart';
import 'package:tikasathi/features/vaccine_records/presentation/missed_vaccines_dialog.dart';
import 'package:tikasathi/features/child/domain/date_of_birth_validation.dart';

class ChildEditScreen extends ConsumerStatefulWidget {
  const ChildEditScreen({required this.childId, super.key});
  final String childId;

  @override
  ConsumerState<ChildEditScreen> createState() => _ChildEditScreenState();
}

class _ChildEditScreenState extends ConsumerState<ChildEditScreen> {
  final _nameController = TextEditingController();
  final _ddController = TextEditingController();
  final _mmController = TextEditingController();
  final _yyController = TextEditingController();
  ChildProfile? _child;
  DateTime? _dob;
  String _sex = 'female';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final child = await ref
          .read(appDatabaseProvider)
          .childProfilesDao
          .getChildProfileById(widget.childId);
      if (!mounted) return;
      if (child == null) {
        setState(() => _loading = false);
        return;
      }
      _child = child;
      _nameController.text = child.name;
      _dob = child.dateOfBirth;
      _ddController.text = child.dateOfBirth.day.toString().padLeft(2, '0');
      _mmController.text = child.dateOfBirth.month.toString().padLeft(2, '0');
      _yyController.text = child.dateOfBirth.year.toString();
      _sex = child.sex;
      setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final day = int.tryParse(_ddController.text);
    final month = int.tryParse(_mmController.text);
    final year = int.tryParse(_yyController.text);
    if (_child == null ||
        _nameController.text.trim().isEmpty ||
        day == null ||
        month == null ||
        year == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.profileInvalidChild)));
      return;
    }
    final ChildDateOfBirthValidation dobValidation = validateChildDateOfBirth(
      day: day,
      month: month,
      year: year,
    );
    if (!dobValidation.isValid) {
      final String message = switch (dobValidation.error) {
        ChildDateOfBirthError.future => l10n.onboardingErrorFutureDob,
        ChildDateOfBirthError.tooOld => l10n.onboardingErrorTooOldDob,
        ChildDateOfBirthError.invalid ||
        null =>
          l10n.onboardingErrorInvalidDate,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }
    final DateTime dob = dobValidation.dateOfBirth!;
    _dob = dob;
    final changedDemographics =
        _dob != _child!.dateOfBirth || _sex != _child!.sex;
    if (changedDemographics) {
      final confirmed = await _confirmScheduleChange();
      if (!confirmed || !mounted) return;
    }

    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      await db.childProfilesDao.updateChildProfile(
        id: widget.childId,
        name: _nameController.text.trim(),
        dateOfBirth: _dob!,
        sex: _sex,
      );
      if (changedDemographics) {
        await db.vaccinationDuesDao.recalculateDuesForChild(widget.childId);
      }
      ref.invalidate(childProfileProvider(widget.childId));
      ref.invalidate(homeStatusGroupsProvider);
      if (changedDemographics) {
        final dues = await db.vaccinationDuesDao
            .getVaccinationDuesForChild(widget.childId);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        if (mounted && dues.any((due) => due.dueDate.isBefore(today))) {
          await showMissedVaccinesDialog(context);
        }
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.profileSaveError)));
      }
    }
  }

  Future<bool> _confirmScheduleChange() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        contentPadding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
        actionsPadding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
        title: Text(l10n.updateVaccinationScheduleTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: l10n.updateVaccinationScheduleProfileName(_child!.name),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: '\n\n'),
              TextSpan(
                text: l10n.updateVaccinationScheduleMessageFirst,
                style: const TextStyle(fontSize: 18),
              ),
              const TextSpan(text: '\n\n'),
              TextSpan(
                text: l10n.updateVaccinationScheduleMessageSecond,
                style: const TextStyle(fontSize: 18),
              ),
              const TextSpan(text: '\n\n'),
              TextSpan(
                text: l10n.updateVaccinationScheduleMessageThird,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  autofocus: true,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F52BA),
                    side: const BorderSide(color: Color(0xFF0F52BA), width: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.profileCancel),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F52BA),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.profileContinue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ddController.dispose();
    _mmController.dispose();
    _yyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final child = _child;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          tooltip: l10n.profileBack,
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : child == null
              ? Center(child: Text(l10n.profileChildNotFound))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.editChildTitleWithName(child.name),
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 32),
                        Text(
                          l10n.onboardingChildNameLabel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: _decoration(
                            l10n.onboardingChildNameHint,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(l10n.onboardingChildDobLabel,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _dateBox(
                                l10n.onboardingChildDateDayHint,
                                _ddController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _dateBox(
                                l10n.onboardingChildDateMonthHint,
                                _mmController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _dateBox(
                                l10n.onboardingChildDateYearHint,
                                _yyController,
                                maxLength: 4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(l10n.onboardingChildGenderLabel,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                              child: _sexButton(
                                  'female', l10n.onboardingChildGenderGirl,
                                  emoji: '👱‍♀️')),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _sexButton(
                                  'male', l10n.onboardingChildGenderBoy,
                                  emoji: '👱‍♂️')),
                        ]),
                        const SizedBox(height: 48),
                        ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F52BA),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _saving
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(l10n.profileSave,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _dateBox(String hint, TextEditingController controller,
      {int maxLength = 2}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F52BA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F52BA)),
        ),
      ),
    );
  }

  Widget _sexButton(String value, String label, {required String emoji}) {
    final selected = _sex == value;
    return OutlinedButton(
      onPressed: _saving ? null : () => setState(() => _sex = value),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? const Color(0xFFE2F0FE) : Colors.white,
        foregroundColor: const Color(0xFF0F52BA),
        minimumSize: const Size(0, 56),
        side: BorderSide(
            color: selected ? const Color(0xFF0F52BA) : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color:
                  selected ? const Color(0xFF0F52BA) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0F52BA), width: 2)),
      );
}
