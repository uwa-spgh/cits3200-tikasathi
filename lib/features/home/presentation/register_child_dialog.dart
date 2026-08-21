import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/features/home/domain/home_status_groups_provider.dart';

class RegisterChildDialog extends ConsumerStatefulWidget {
  const RegisterChildDialog({super.key});

  @override
  ConsumerState<RegisterChildDialog> createState() =>
      _RegisterChildDialogState();
}

class _RegisterChildDialogState extends ConsumerState<RegisterChildDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _dateOfBirth;
  String _sex = 'female';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final initial = _dateOfBirth ?? DateTime(now.year - 1, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 6),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final id = const Uuid().v4();
      final name = _nameController.text.trim();
      final sex = _sex;
      final dob = _dateOfBirth!;

      final companion = ChildProfilesCompanion.insert(
        id: id,
        name: name,
        dateOfBirth: dob,
        sex: sex,
      );

      final db = ref.read(appDatabaseProvider);
      await db.childProfilesDao.insertChildProfile(companion);

      ref.invalidate(homeStatusGroupsProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add child'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (String? v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Date of birth'),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _dateOfBirth == null
                            ? 'Select date'
                            : '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                    TextButton(
                      onPressed: () => _pickDateOfBirth(context),
                      child: const Text('Pick'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _sex,
                decoration: const InputDecoration(labelText: 'Sex'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                ],
                onChanged: (String? v) {
                  if (v != null) {
                    setState(() => _sex = v);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}
