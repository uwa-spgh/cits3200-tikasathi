import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/features/app_shell/presentation/app_bottom_navigation_bar.dart';
import 'package:tikasathi/features/app_shell/presentation/app_shell_screen.dart';
import 'package:drift/native.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/settings/domain/health_facilitator_controller.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';

import 'package:tikasathi/core/services/tts_service.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import '../../../helpers/fake_settings_repository.dart';

class _FakeTtsService extends Fake implements TtsService {
  @override
  void Function(TtsStatus status)? onStatusChanged;

  @override
  void Function(String error)? onError;

  @override
  Future<void> initialize() async {}

  @override
  Future<TtsSpeakResult> speak(
    String text, {
    required AppLanguage language,
  }) async {
    onStatusChanged?.call(TtsStatus.playing);
    return const TtsSpeakResult(success: true, resolvedLanguage: 'ne-NP');
  }

  @override
  Future<void> stop() async {
    onStatusChanged?.call(TtsStatus.stopped);
  }
}

void main() {
  group('AppShellScreen', () {
    late _FakeTtsService ttsService;

    setUp(() {
      ttsService = _FakeTtsService();
    });
    testWidgets('shows home screen by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) {
              final db = AppDatabase.forTesting(NativeDatabase.memory());
              ref.onDispose(db.close);
              return db;
            }),
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
            healthFacilitatorProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(
            locale: Locale('ne'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AppShellScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomNavigationBar), findsOneWidget);
      expect(find.byKey(const Key('home-title')), findsOneWidget);
      expect(find.text('सिक्नुहोस्'), findsWidgets);
      expect(find.text('भाषा छान्नुहोस्'), findsNothing);
      expect(find.byIcon(Icons.record_voice_over), findsOneWidget);
    });

    testWidgets('switches destinations from bottom navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) {
              final db = AppDatabase.forTesting(NativeDatabase.memory());
              ref.onDispose(db.close);
              return db;
            }),
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
            healthFacilitatorProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(
            locale: Locale('ne'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AppShellScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();
      expect(find.text('सिक्नुहोस्'), findsWidgets);
      expect(find.byKey(const Key('home-title')), findsNothing);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('भाषा छान्नुहोस्'), findsOneWidget);
      expect(find.text('सिक्नुहोस्'), findsWidgets);
    });

    testWidgets('shows read-aloud action feedback when pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) {
              final db = AppDatabase.forTesting(NativeDatabase.memory());
              ref.onDispose(db.close);
              return db;
            }),
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
            healthFacilitatorProvider.overrideWith((ref) => Stream.value(null)),
            ttsServiceProvider.overrideWith((ref) => ttsService),
          ],
          child: const MaterialApp(
            locale: Locale('ne'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AppShellScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('पढाइ सुन्नुहोस्'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.record_voice_over));
      await tester.pump();

      // Switches to playing state
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
      expect(find.byTooltip('पढाइ रोक्नुहोस्'), findsOneWidget);

      // Tapping again stops playback
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pump();
      expect(find.byIcon(Icons.record_voice_over), findsOneWidget);
      expect(find.byTooltip('पढाइ सुन्नुहोस्'), findsOneWidget);
    });
  });
}
