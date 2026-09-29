import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tikasathi/core/services/tts_controller.dart';
import 'package:tikasathi/core/services/tts_service.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';

class _MockTtsService extends Mock implements TtsService {
  @override
  void Function(TtsStatus status)? onStatusChanged;
  @override
  void Function(String error)? onError;
}

void main() {
  setUpAll(() {
    registerFallbackValue(AppLanguage.nepali);
  });

  group('TtsController', () {
    late _MockTtsService mockService;
    late ProviderContainer container;

    setUp(() {
      mockService = _MockTtsService();

      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(
        () => mockService.speak(
          any(),
          language: any(named: 'language'),
        ),
      ).thenAnswer(
        (_) async => const TtsSpeakResult(
          success: true,
          resolvedLanguage: 'ne-NP',
        ),
      );
      when(() => mockService.stop()).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          ttsServiceProvider.overrideWith((ref) => mockService),
          languageControllerProvider.overrideWith(
            () => _FakeLanguageController(AppLanguage.nepali),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is stopped and not speaking', () {
      final TtsStateData state = container.read(ttsControllerProvider);

      expect(state.status, TtsStatus.stopped);
      expect(state.isSpeaking, isFalse);
      expect(state.currentText, isEmpty);
      expect(state.errorMessage, isNull);
    });

    test('speak updates state to playing and delegates to TtsService',
        () async {
      final TtsSpeakResult result =
          await container.read(ttsControllerProvider.notifier).speak('नमस्ते');

      expect(result.success, isTrue);
      final TtsStateData state = container.read(ttsControllerProvider);
      expect(state.status, TtsStatus.playing);
      expect(state.isSpeaking, isTrue);
      expect(state.currentText, 'नमस्ते');

      verify(
        () => mockService.speak(
          'नमस्ते',
          language: AppLanguage.nepali,
        ),
      ).called(1);
    });

    test('stop delegates to TtsService and resets state', () async {
      await container.read(ttsControllerProvider.notifier).speak('नमस्ते');
      expect(container.read(ttsControllerProvider).isSpeaking, isTrue);

      await container.read(ttsControllerProvider.notifier).stop();

      final TtsStateData state = container.read(ttsControllerProvider);
      expect(state.status, TtsStatus.stopped);
      expect(state.isSpeaking, isFalse);
      expect(state.currentText, isEmpty);
      verify(() => mockService.stop()).called(1);
    });

    test('updates state when service callbacks trigger', () async {
      // Initialize provider so listener handlers are attached
      container.read(ttsControllerProvider);

      // Verify onStatusChanged callback
      final void Function(TtsStatus)? statusCallback =
          mockService.onStatusChanged;
      expect(statusCallback, isNotNull);

      statusCallback!(TtsStatus.playing);
      expect(container.read(ttsControllerProvider).isSpeaking, isTrue);
      expect(container.read(ttsControllerProvider).status, TtsStatus.playing);

      statusCallback(TtsStatus.stopped);
      expect(container.read(ttsControllerProvider).isSpeaking, isFalse);
      expect(container.read(ttsControllerProvider).status, TtsStatus.stopped);

      // Verify onError callback
      final void Function(String)? errorCallback = mockService.onError;
      expect(errorCallback, isNotNull);

      errorCallback!('Engine crash');
      expect(container.read(ttsControllerProvider).status, TtsStatus.error);
      expect(container.read(ttsControllerProvider).isSpeaking, isFalse);
      expect(
          container.read(ttsControllerProvider).errorMessage, 'Engine crash');
    });

    test('records phonetic fallback flag when fallback is used', () async {
      when(
        () => mockService.speak(
          any(),
          language: any(named: 'language'),
        ),
      ).thenAnswer(
        (_) async => const TtsSpeakResult(
          success: true,
          resolvedLanguage: 'hi-IN',
          usedPhoneticFallback: true,
        ),
      );

      final TtsSpeakResult res = await container
          .read(ttsControllerProvider.notifier)
          .speak('खोप विवरण', language: AppLanguage.nepali);

      expect(res.usedPhoneticFallback, isTrue);
      final TtsStateData state = container.read(ttsControllerProvider);
      expect(state.usedPhoneticFallback, isTrue);
    });
  });
}

class _FakeLanguageController extends LanguageController {
  _FakeLanguageController(this._initial);

  final AppLanguage _initial;

  @override
  Future<AppLanguage> build() async => _initial;
}
