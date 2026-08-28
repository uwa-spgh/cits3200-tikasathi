import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/health_facilitator_controller.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';
import 'package:tikasathi/features/settings/presentation/health_facilitator_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppLanguage> languageState =
        ref.watch(languageControllerProvider);
    final AsyncValue<HealthFacilitator?> facilitatorState =
        ref.watch(healthFacilitatorProvider);

    return languageState.when(
      data: (AppLanguage language) => facilitatorState.when(
        data: (facilitator) => _buildContent(
          context,
          ref,
          isNp: language == AppLanguage.nepali,
          facilitator: facilitator,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('$error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('$error')),
    );
  }

  Future<void> _saveLanguage(
    BuildContext context,
    WidgetRef ref, {
    required AppLanguage language,
    required bool isNp,
  }) async {
    final bool saved = await ref
        .read(languageControllerProvider.notifier)
        .setLanguage(language);
    if (!saved && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNp ? 'भाषा सेव गर्न सकिएन।' : 'Could not save language.',
          ),
        ),
      );
    }
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref, {
    required bool isNp,
    required HealthFacilitator? facilitator,
  }) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                localizations.settingsTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                localizations.settingsLanguageTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 16),
              _LanguageButton(
                title: localizations.settingsNepali,
                flag: '🇳🇵',
                isSelected: isNp,
                onTap: () => _saveLanguage(
                  context,
                  ref,
                  language: AppLanguage.nepali,
                  isNp: isNp,
                ),
              ),
              const SizedBox(height: 16),
              _LanguageButton(
                title: localizations.settingsEnglish,
                flag: '🇬🇧',
                isSelected: !isNp,
                onTap: () => _saveLanguage(
                  context,
                  ref,
                  language: AppLanguage.english,
                  isNp: isNp,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                localizations.healthFacilitatorSectionTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                key: const Key('health-facilitator-action'),
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        HealthFacilitatorScreen(facilitator: facilitator),
                  ),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFB9DED5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.health_and_safety_outlined,
                            size: 32,
                            color: Color(0xFF0F766E),
                          ),
                          const SizedBox(width: 16),
                          if (facilitator == null) ...[
                            Expanded(
                              child: Text(
                                localizations.healthFacilitatorSaveAction,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF115E59),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF0F766E),
                            ),
                          ],
                          if (facilitator != null)
                            Expanded(
                              child: Text(
                                localizations.healthFacilitatorSavedHeading,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF115E59),
                                ),
                              ),
                            ),
                          if (facilitator != null)
                            const Icon(
                              Icons.chevron_right,
                              size: 32,
                              color: Color(0xFF0F766E),
                            ),
                        ],
                      ),
                      if (facilitator != null) ...[
                        const SizedBox(height: 16),
                        _FacilitatorDetails(
                          facilitator: facilitator,
                          localizations: localizations,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  // Debug: Clear secure storage
                  await ref.read(secureStorageServiceProvider).clearAll();

                  // Debug: Clear database tables
                  final db = ref.read(appDatabaseProvider);
                  await db.delete(db.childProfiles).go();
                  await db.delete(db.vaccinationRecords).go();
                  await db.delete(db.vaccinationDues).go();
                  await db.delete(db.healthFacilitators).go();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isNp
                            ? 'सबै डाटा मेटाइयो (डिबग)। सुरुदेखि हेर्न एप रिस्टार्ट गर्नुहोस्।'
                            : 'All data cleared (Debug). Restart the app to see the onboarding screen again.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isNp
                    ? 'DEBUG: सबै डाटा मेटाउनुहोस्'
                    : 'DEBUG: Clear All Storage'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FacilitatorDetails extends StatelessWidget {
  final HealthFacilitator facilitator;
  final AppLocalizations localizations;

  const _FacilitatorDetails({
    required this.facilitator,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final details = <Widget>[
      if (_hasValue(facilitator.name))
        _FacilitatorDetailRow(
          icon: Icons.person_outline,
          label: localizations.healthFacilitatorName,
          value: facilitator.name!,
        ),
      if (_hasValue(facilitator.address))
        _FacilitatorDetailRow(
          icon: Icons.location_on_outlined,
          label: localizations.healthFacilitatorAddress,
          value: facilitator.address!,
        ),
      if (_hasValue(facilitator.phone))
        _FacilitatorDetailRow(
          icon: Icons.phone_outlined,
          label: localizations.healthFacilitatorPhone,
          value: facilitator.phone!,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < details.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          details[index],
        ],
      ],
    );
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}

class _FacilitatorDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FacilitatorDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0F766E)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String title;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.title,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE2F0FE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF0F52BA) : const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF0F52BA)
                    : const Color(0xFF334155),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0F52BA)),
          ],
        ),
      ),
    );
  }
}
