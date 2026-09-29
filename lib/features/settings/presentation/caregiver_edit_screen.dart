import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:tikasathi/core/services/screen_speech_helper.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/settings/domain/phone_number_validation.dart';

class CaregiverEditScreen extends ConsumerStatefulWidget {
  const CaregiverEditScreen({super.key});

  @override
  ConsumerState<CaregiverEditScreen> createState() =>
      _CaregiverEditScreenState();
}

class _CaregiverEditScreenState extends ConsumerState<CaregiverEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile =
          await ref.read(secureStorageServiceProvider).getCaregiverProfile();
      if (!mounted) return;
      _nameController.text = profile['name'] ?? '';
      _phoneController.text = profile['phone'] ?? '';
      _addressController.text = profile['address'] ?? '';
      setState(() => _loading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = AppLocalizations.of(context)!.profileLoadError;
        });
      }
    }
  }

  Future<void> _save() async {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.onboardingErrorEmptyCaregiverName),
        ),
      );
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.onboardingErrorEmptyCaregiverPhone),
        ),
      );
      return;
    }
    if (!isValidPhoneNumber(phone, allowEmpty: false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.onboardingErrorInvalidPhone)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(secureStorageServiceProvider).saveCaregiverProfile(
            name: name,
            phone: phone,
            address: _addressController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.profileSaveError)),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ReadAloudButton(
              tooltip: l10n.childReadAloudTooltip,
              unavailableMessage: l10n.childReadAloudUnavailable,
              textGetter: () => ScreenSpeechHelper.caregiverScreenText(
                context: context,
                localizations: l10n,
                isEditing: true,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.editCaregiverTitle,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 32),
                        _field(l10n.onboardingCaregiverNameLabel,
                            l10n.onboardingCaregiverNameHint, _nameController),
                        const SizedBox(height: 24),
                        _field(l10n.onboardingCaregiverPhoneLabel,
                            l10n.onboardingCaregiverPhoneHint, _phoneController,
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 24),
                        _field(
                            l10n.onboardingCaregiverAddressLabel,
                            l10n.onboardingCaregiverAddressHint,
                            _addressController),
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

  Widget _field(String label, String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
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
                borderSide:
                    const BorderSide(color: Color(0xFF0F52BA), width: 2)),
          ),
        ),
      ],
    );
  }
}
