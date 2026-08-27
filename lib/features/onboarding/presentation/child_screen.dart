import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/features/app_shell/presentation/app_shell_screen.dart';
import 'package:tikasathi/features/onboarding/domain/onboarding_state.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

class ChildScreen extends ConsumerStatefulWidget {
  const ChildScreen({super.key});

  @override
  ConsumerState<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends ConsumerState<ChildScreen> {
  final _nameController = TextEditingController();
  final _ddController = TextEditingController();
  final _mmController = TextEditingController();
  final _yyController = TextEditingController();

  String _selectedGender = 'Girl';

  @override
  void dispose() {
    _nameController.dispose();
    _ddController.dispose();
    _mmController.dispose();
    _yyController.dispose();
    super.dispose();
  }

  Future<void> _onFinish(bool isNp) async {
    final errorEmptyName = isNp
        ? 'कृपया बच्चाको नाम प्रविष्ट गर्नुहोस्'
        : 'Please enter child\'s name';
    final errorInvalidDate = isNp
        ? 'कृपया मान्य जन्म मिति प्रविष्ट गर्नुहोस्'
        : 'Please enter a valid Date of Birth';
    final errorDate = isNp ? 'अवैध जन्म मिति' : 'Invalid Date of Birth';

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorEmptyName)),
      );
      return;
    }

    final dd = int.tryParse(_ddController.text);
    final mm = int.tryParse(_mmController.text);
    final yy = int.tryParse(_yyController.text);

    if (dd == null || mm == null || yy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorInvalidDate)),
      );
      return;
    }

    final year = yy;

    DateTime? dob;
    try {
      dob = DateTime(year, mm, dd);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorDate)),
      );
      return;
    }

    final controller = ref.read(onboardingControllerProvider.notifier);

    controller.updateChildInfo(
      name: _nameController.text.trim(),
      dob: dob,
      sex: _selectedGender,
    );

    final success = await controller.finishSetup();

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (context) => const AppShellScreen()),
        (route) => false,
      );
    } else if (mounted) {
      final error = ref.read(onboardingControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving setup: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final bool isNp = state.selectedLanguage == AppLanguage.nepali;

    final stepText = isNp ? 'चरण २/२' : 'Step 2 of 2';
    final childNameLabel = isNp ? '👶 बच्चाको नाम' : '👶 Child\'s name';
    final childNameHint =
        isNp ? 'पूरा नाम प्रविष्ट गर्नुहोस्' : 'Enter full name';
    final dobLabel = isNp ? '📅 जन्म मिति' : '📅 Date of Birth';
    final ddHint = isNp ? 'गते' : 'DD';
    final mmHint = isNp ? 'महिना' : 'MM';
    final yyyyHint = isNp ? 'वर्ष' : 'YYYY';
    final genderLabel = isNp ? '⚥ लिङ्ग' : '⚥ Gender';
    final girlText = isNp ? 'छोरी' : 'Girl';
    final boyText = isNp ? 'छोरा' : 'Boy';
    final finishText = isNp ? 'सेटअप पूरा गर्नुहोस्' : 'Finish Setup';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step indicator
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
                  const SizedBox(width: 16),
                  Text(
                    stepText,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      childNameLabel,
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
                      decoration: InputDecoration(
                        hintText: childNameHint,
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF0F52BA)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF0F52BA)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      dobLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildDateBox(ddHint, _ddController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDateBox(mmHint, _mmController)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildDateBox(yyyyHint, _yyController,
                                maxLength: 4)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      genderLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGenderButton('Girl', '👱‍♀️',
                              label: girlText),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGenderButton('Boy', '👱‍♂️',
                              label: boyText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: state.isSaving ? null : () => _onFinish(isNp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F52BA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: state.isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            finishText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateBox(String hint, TextEditingController controller,
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
          fontSize: 20, // slightly smaller to fit Nepali
          fontWeight: FontWeight.normal,
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

  Widget _buildGenderButton(String genderId, String emoji,
      {required String label}) {
    final isSelected = _selectedGender == genderId;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = genderId;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE2F0FE) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF0F52BA),
            width: isSelected ? 2 : 1,
          ),
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF0F52BA)
                    : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
