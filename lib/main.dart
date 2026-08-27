import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:tikasathi/core/theme/app_theme.dart';
import 'package:tikasathi/features/app_shell/presentation/app_shell_screen.dart';
import 'package:tikasathi/features/onboarding/presentation/language_screen.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';

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

    if (mounted) {
      setState(() {
        _hasCompletedOnboarding = completed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppLanguage> languageState =
        ref.watch(languageControllerProvider);
    final Locale locale =
        languageState.asData?.value.locale ?? AppLanguage.nepali.locale;

    return MaterialApp(
      title: 'TikaSathi',
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: languageState.when(
        data: (AppLanguage language) {
          if (_hasCompletedOnboarding == null) {
            return const _StartupProgress();
          }
          return _hasCompletedOnboarding!
              ? const AppShellScreen()
              : const LanguageScreen();
        },
        loading: () => const _StartupProgress(),
        error: (Object error, StackTrace stackTrace) => Scaffold(
          body: Center(
            child: Text('Unable to load language settings: $error'),
          ),
        ),
      ),
    );
  }
}

class _StartupProgress extends StatelessWidget {
  const _StartupProgress();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F9FC),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
