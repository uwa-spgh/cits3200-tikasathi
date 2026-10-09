import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/database/database_recovery.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/reminders/open_child_from_reminder.dart';
import 'package:tikasathi/core/reminders/reminder_scheduler.dart';
import 'package:tikasathi/core/services/notification_service.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:tikasathi/core/theme/app_theme.dart';
import 'package:tikasathi/core/services/tts_navigation_observer.dart';
import 'package:tikasathi/core/services/tts_controller.dart';
import 'package:tikasathi/features/app_shell/presentation/app_shell_screen.dart';
import 'package:tikasathi/features/onboarding/presentation/language_screen.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';
import 'package:tikasathi/features/startup/presentation/database_locked_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reused as the app's scope so the initialised service is the one it reads.
  final ProviderContainer container = ProviderContainer();
  await _recoverIfDatabaseLocked(container);
  await container.read(notificationServiceProvider).initialize();
  await container.read(notificationServiceProvider).requestPermission();

  final ReminderScheduler scheduler = container.read(reminderSchedulerProvider);
  await scheduler.catchUpMissed();
  scheduler.start();

  runApp(
    // ProviderScope is mandatory for Riverpod
    UncontrolledProviderScope(
      container: container,
      child: const TikaSathiApp(),
    ),
  );
}

/// Opens the database before anything uses it. If its key is gone, the data
/// is unreadable: show the recovery screen and wait until the person has
/// started fresh.
Future<void> _recoverIfDatabaseLocked(ProviderContainer container) async {
  if (await canOpenDatabase(container.read(appDatabaseProvider))) {
    return;
  }
  final Completer<void> startedFresh = Completer<void>();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: DatabaseLockedApp(
        onStartFresh: () async {
          await eraseLocalData(
            databaseFile: await databaseFile(),
            secureStorage: container.read(secureStorageServiceProvider),
          );
          // The old provider holds the failed database. Build a new one.
          container.invalidate(appDatabaseProvider);
          startedFresh.complete();
        },
      ),
    ),
  );
  await startedFresh.future;
}

class TikaSathiApp extends ConsumerStatefulWidget {
  const TikaSathiApp({super.key});

  @override
  ConsumerState<TikaSathiApp> createState() => _TikaSathiAppState();
}

class _TikaSathiAppState extends ConsumerState<TikaSathiApp> {
  bool? _hasCompletedOnboarding;
  late final TtsController _ttsController =
      ref.read(ttsControllerProvider.notifier);
  late final TtsNavigationObserver _ttsNavigationObserver =
      TtsNavigationObserver(
    stopSpeech: _ttsController.stop,
  );

  // Reminder taps arrive outside any widget, so opening a child's page needs a
  // navigator the app can reach from here.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<String>? _reminderTaps;

  @override
  void initState() {
    super.initState();
    _reminderTaps = ref
        .read(notificationServiceProvider)
        .openedChildIds
        .listen(_openChildFromReminder);
    _checkOnboarding();
  }

  @override
  void dispose() {
    unawaited(_ttsController.stop());
    _reminderTaps?.cancel();
    super.dispose();
  }

  Future<void> _checkOnboarding() async {
    final storage = ref.read(secureStorageServiceProvider);
    final completed = await storage.hasCompletedOnboarding();

    if (mounted) {
      setState(() {
        _hasCompletedOnboarding = completed;
      });
    }

    // A tap on a reminder may be what started the app. Wait for the home
    // screen to be built, then open that child on top of it.
    final String? launchedFor =
        await ref.read(notificationServiceProvider).childIdThatLaunchedApp();
    if (launchedFor != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openChildFromReminder(launchedFor),
      );
    }
  }

  Future<void> _openChildFromReminder(String childId) async {
    // Before onboarding there is no home screen to return to.
    if (_hasCompletedOnboarding != true) {
      return;
    }
    await openChildFromReminder(
      navigator: _navigatorKey.currentState,
      database: ref.read(appDatabaseProvider),
      childId: childId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppLanguage> languageState =
        ref.watch(languageControllerProvider);
    final Locale locale =
        languageState.asData?.value.locale ?? AppLanguage.nepali.locale;

    return MaterialApp(
      navigatorKey: _navigatorKey,
      navigatorObservers: <NavigatorObserver>[_ttsNavigationObserver],
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
        error: (Object error, StackTrace stackTrace) {
          final AppLocalizations localizations = AppLocalizations.of(context)!;
          return Scaffold(
            body: Center(
              child: Text(localizations.appLanguageLoadError(error.toString())),
            ),
          );
        },
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
