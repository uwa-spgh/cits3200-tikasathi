import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:tikasathi/core/providers/language_provider.dart';

class SettingsPlaceholderScreen extends ConsumerWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNp = ref.watch(languageProvider) == 'np';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isNp ? 'सेटिङहरू' : 'Settings',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 32),

            // Language Selection
            Text(
              isNp ? 'भाषा चयन गर्नुहोस्' : 'Select Language',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 16),
            _LanguageButton(
              title: 'नेपाली',
              flag: '🇳🇵',
              isSelected: isNp,
              onTap: () =>
                  ref.read(languageProvider.notifier).setLanguage('np'),
            ),
            const SizedBox(height: 16),
            _LanguageButton(
              title: 'English',
              flag: '🇬🇧',
              isSelected: !isNp,
              onTap: () =>
                  ref.read(languageProvider.notifier).setLanguage('en'),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () async {
                // Debug: Clear secure storage
                await ref.read(secureStorageServiceProvider).clearAll();

                // Debug: Clear database tables
                final db = ref.read(appDatabaseProvider);
                await db.delete(db.childProfiles).go();
                await db.delete(db.vaccinationRecords).go();
                await db.delete(db.vaccinationDues).go();

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
