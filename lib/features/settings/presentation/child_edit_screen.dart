import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/home/domain/home_status_groups_provider.dart';

class ChildEditScreen extends ConsumerStatefulWidget {
  const ChildEditScreen({required this.childId, super.key});
  final String childId;

  @override
  ConsumerState<ChildEditScreen> createState() => _ChildEditScreenState();
}

class _ChildEditScreenState extends ConsumerState<ChildEditScreen> {
  final _nameController = TextEditingController();
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
      _sex = child.sex;
      setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0F52BA)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_child == null || _nameController.text.trim().isEmpty || _dob == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.profileInvalidChild)));
      return;
    }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.updateVaccinationScheduleTitle),
        content: Text(l10n.updateVaccinationScheduleMessage),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.profileCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0F52BA),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.profileContinue),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                        Text(l10n.editChildTitle,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _nameController,
                          decoration: _decoration(l10n.onboardingChildNameLabel,
                              l10n.onboardingChildNameHint),
                        ),
                        const SizedBox(height: 24),
                        Text(l10n.onboardingChildDobLabel,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155))),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _saving ? null : _pickDob,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(MaterialLocalizations.of(context)
                              .formatMediumDate(_dob!)),
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            foregroundColor: const Color(0xFF0F52BA),
                            minimumSize: const Size(double.infinity, 56),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(l10n.onboardingChildGenderLabel,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155))),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                              child: _sexButton(
                                  'female', l10n.onboardingChildGenderGirl)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _sexButton(
                                  'male', l10n.onboardingChildGenderBoy)),
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

  Widget _sexButton(String value, String label) {
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
      child: Text(label),
    );
  }

  InputDecoration _decoration(String label, String hint) => InputDecoration(
        labelText: label,
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
