import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/services/tts_service.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

class _FakeTtsService extends Fake implements TtsService {
  @override
  void Function(TtsStatus status)? onStatusChanged;
  @override
  void Function(String error)? onError;

  String? lastSpokenText;
  AppLanguage? lastLanguage;
  bool shouldFail = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<TtsSpeakResult> speak(
    String text, {
    required AppLanguage language,
  }) async {
    lastSpokenText = text;
    lastLanguage = language;
    if (shouldFail) {
      onStatusChanged?.call(TtsStatus.error);
      return const TtsSpeakResult(
        success: false,
        resolvedLanguage: '',
        errorMessage: 'Device TTS failure',
      );
    }
    onStatusChanged?.call(TtsStatus.playing);
    return const TtsSpeakResult(success: true, resolvedLanguage: 'en-US');
  }

  @override
  Future<void> stop() async {
    onStatusChanged?.call(TtsStatus.stopped);
  }
}

void main() {
  group('ReadAloudButton', () {
    late _FakeTtsService fakeService;

    setUp(() {
      fakeService = _FakeTtsService();
    });

    testWidgets('renders default idle state with record_voice_over icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWith((ref) => fakeService),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ReadAloudButton(
                tooltip: 'Read aloud',
                unavailableMessage: 'Unavailable',
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.record_voice_over), findsOneWidget);
      expect(find.byTooltip('Read aloud'), findsOneWidget);
      expect(find.byIcon(Icons.stop_rounded), findsNothing);
    });

    testWidgets('speaks explicit text and toggles to stop icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWith((ref) => fakeService),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ReadAloudButton(
                text: 'Hello from TikaSathi',
                tooltip: 'Read aloud',
                unavailableMessage: 'Unavailable',
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.record_voice_over));
      await tester.pump();

      expect(fakeService.lastSpokenText, 'Hello from TikaSathi');
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
      expect(find.byTooltip('Stop reading aloud'), findsOneWidget);

      // Tapping again stops speech
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pump();

      expect(find.byIcon(Icons.record_voice_over), findsOneWidget);
      expect(find.byTooltip('Read aloud'), findsOneWidget);
    });

    testWidgets('uses textGetter callback when tapped',
        (WidgetTester tester) async {
      int count = 1;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWith((ref) => fakeService),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ReadAloudButton(
                textGetter: () => 'Dynamic message ${count++}',
                tooltip: 'Read aloud',
                unavailableMessage: 'Unavailable',
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.record_voice_over));
      await tester.pump();

      expect(fakeService.lastSpokenText, 'Dynamic message 1');
    });

    testWidgets('extracts visible screen text if no text is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWith((ref) => fakeService),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Column(
                children: [
                  Text('Child Vaccine Schedule'),
                  Text('BCG given at birth'),
                  ReadAloudButton(
                    tooltip: 'Read aloud',
                    unavailableMessage: 'Unavailable',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.record_voice_over));
      await tester.pump();

      expect(fakeService.lastSpokenText, contains('Child Vaccine Schedule'));
      expect(fakeService.lastSpokenText, contains('BCG given at birth'));
    });

    testWidgets('shows snackbar when text is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWith((ref) => fakeService),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ReadAloudButton(
                text: '   ',
                tooltip: 'Read aloud',
                unavailableMessage: 'Unavailable',
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.record_voice_over));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('No text found to read aloud.'), findsOneWidget);
    });

    testWidgets('shows error snackbar when TTS fails',
        (WidgetTester tester) async {
      fakeService.shouldFail = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWith((ref) => fakeService),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ReadAloudButton(
                text: 'Some speech',
                tooltip: 'Read aloud',
                unavailableMessage: 'Unavailable',
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.record_voice_over));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(
          'Could not read text aloud. Please check your device speech settings.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays localized tooltips in Nepali',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWith((ref) => fakeService),
          ],
          child: const MaterialApp(
            locale: Locale('ne'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ReadAloudButton(
                text: 'नमस्ते',
                tooltip: 'पढाइ सुन्नुहोस्',
                unavailableMessage: 'उपलब्ध छैन',
              ),
            ),
          ),
        ),
      );

      expect(find.byTooltip('पढाइ सुन्नुहोस्'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.record_voice_over));
      await tester.pump();

      expect(find.byTooltip('पढाइ रोक्नुहोस्'), findsOneWidget);
    });
  });
}
