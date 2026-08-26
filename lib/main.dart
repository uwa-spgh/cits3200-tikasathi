import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/app_shell/presentation/app_shell_screen.dart';

import 'core/theme/app_theme.dart';
import 'package:tikasathi/features/onboarding/presentation/language_screen.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:tikasathi/core/providers/language_provider.dart';

void main() {
  runApp(
    // ProviderScope is mandatory for Riverpod
    const ProviderScope(
      child: TikaSathiApp(),
    ),
  );
}

class TikaSathiApp extends ConsumerStatefulWidget {
  const TikaSathiApp({super.key});

  @override
  ConsumerState<TikaSathiApp> createState() => _TikaSathiAppState();
}

class _TikaSathiAppState extends ConsumerState<TikaSathiApp> {
  bool? _hasCompletedOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final storage = ref.read(secureStorageServiceProvider);
    final completed = await storage.hasCompletedOnboarding();

    // Load language globally
    await ref.read(languageProvider.notifier).loadLanguage();

    setState(() {
      _hasCompletedOnboarding = completed;
    });
  }

  Locale _selectedLocale(String? languageCode) {
    if (languageCode == 'np' || languageCode == 'ne') {
      return const Locale('ne');
    }
    return const Locale('en');
  }

  @override
  Widget build(BuildContext context) {
    final String languageCode = ref.watch(languageProvider);

    return MaterialApp(
      title: 'TikaSathi',
      theme: AppTheme.light,
      locale: _selectedLocale(languageCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _hasCompletedOnboarding == null
          ? const Scaffold(
              backgroundColor: Color(0xFFF5F9FC),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _hasCompletedOnboarding!
              ? const AppShellScreen()
              : const LanguageScreen(),
    );
  }
}
