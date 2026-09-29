import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tikasathi/core/services/tts_service.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

class _MockFlutterTts extends Mock implements FlutterTts {}

void main() {
  setUpAll(() {
    registerFallbackValue(IosTextToSpeechAudioCategory.ambient);
    registerFallbackValue(
      const <IosTextToSpeechAudioCategoryOptions>[
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      ],
    );
    registerFallbackValue(IosTextToSpeechAudioMode.voicePrompt);
  });

  group('TtsService', () {
    late _MockFlutterTts mockTts;
    late TtsService service;

    setUp(() {
      mockTts = _MockFlutterTts();
      service = TtsService(mockTts);

      when(() => mockTts.setSpeechRate(any())).thenAnswer((_) async => 1);
      when(() => mockTts.setVolume(any())).thenAnswer((_) async => 1);
      when(() => mockTts.setPitch(any())).thenAnswer((_) async => 1);
      when(() => mockTts.setSharedInstance(any()))
          .thenAnswer((_) async => true);
      when(() => mockTts.setIosAudioCategory(any(), any(), any()))
          .thenAnswer((_) async => 1);

      when(() => mockTts.setStartHandler(any())).thenReturn(null);
      when(() => mockTts.setCompletionHandler(any())).thenReturn(null);
      when(() => mockTts.setCancelHandler(any())).thenReturn(null);
      when(() => mockTts.setPauseHandler(any())).thenReturn(null);
      when(() => mockTts.setContinueHandler(any())).thenReturn(null);
      when(() => mockTts.setErrorHandler(any())).thenReturn(null);

      when(() => mockTts.setLanguage(any())).thenAnswer((_) async => 1);
      when(() => mockTts.speak(any())).thenAnswer((_) async => 1);
      when(() => mockTts.stop()).thenAnswer((_) async => 1);
      when(() => mockTts.pause()).thenAnswer((_) async => 1);
      when(() => mockTts.isLanguageAvailable(any())).thenAnswer((_) async => 1);
      when(() => mockTts.getLanguages)
          .thenAnswer((_) async => <String>['en-US', 'ne-NP', 'hi-IN']);
    });

    test('initialize sets up audio parameters and handlers', () async {
      await service.initialize();

      verify(() => mockTts.setSpeechRate(0.45)).called(1);
      verify(() => mockTts.setVolume(1.0)).called(1);
      verify(() => mockTts.setPitch(1.0)).called(1);
      verify(() => mockTts.setStartHandler(any())).called(1);
      verify(() => mockTts.setCompletionHandler(any())).called(1);
      verify(() => mockTts.setErrorHandler(any())).called(1);
    });

    test('resolves English to en-US when available', () async {
      when(() => mockTts.isLanguageAvailable('en-US'))
          .thenAnswer((_) async => 1);

      final ({String code, bool usedPhoneticFallback}) res =
          await service.resolveLanguage(AppLanguage.english);

      expect(res.code, 'en-US');
      expect(res.usedPhoneticFallback, isFalse);
    });

    test('resolves Nepali to ne-NP when ne-NP is available', () async {
      when(() => mockTts.isLanguageAvailable('ne-NP'))
          .thenAnswer((_) async => 1);

      final ({String code, bool usedPhoneticFallback}) res =
          await service.resolveLanguage(AppLanguage.nepali);

      expect(res.code, 'ne-NP');
      expect(res.usedPhoneticFallback, isFalse);
    });

    test('falls back to Hindi (hi-IN) when Nepali is unavailable', () async {
      when(() => mockTts.isLanguageAvailable('ne-NP'))
          .thenAnswer((_) async => 0);
      when(() => mockTts.isLanguageAvailable('ne')).thenAnswer((_) async => 0);
      when(() => mockTts.isLanguageAvailable('hi-IN'))
          .thenAnswer((_) async => 1);
      when(() => mockTts.getLanguages)
          .thenAnswer((_) async => <String>['en-US', 'hi-IN']);

      final ({String code, bool usedPhoneticFallback}) res =
          await service.resolveLanguage(AppLanguage.nepali);

      expect(res.code, 'hi-IN');
      expect(res.usedPhoneticFallback, isTrue);
    });

    test('speak stops prior speech and calls tts.speak', () async {
      final List<TtsStatus> statuses = <TtsStatus>[];
      service.onStatusChanged = (TtsStatus s) => statuses.add(s);

      final TtsSpeakResult result = await service.speak(
        'Hello from TikaSathi',
        language: AppLanguage.english,
      );

      expect(result.success, isTrue);
      expect(result.resolvedLanguage, 'en-US');
      verify(() => mockTts.stop()).called(1);
      verify(() => mockTts.setLanguage('en-US')).called(1);
      verify(() => mockTts.speak('Hello from TikaSathi')).called(1);
      expect(statuses, contains(TtsStatus.playing));
    });

    test('speak rejects empty text without invoking tts.speak', () async {
      final TtsSpeakResult result = await service.speak(
        '   ',
        language: AppLanguage.english,
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, 'Text is empty');
      verifyNever(() => mockTts.speak(any()));
    });

    test('handles speech error gracefully and notifies listeners', () async {
      when(() => mockTts.speak(any())).thenThrow(Exception('Engine failure'));

      final List<TtsStatus> statuses = <TtsStatus>[];
      String? errorMsg;
      service.onStatusChanged = (TtsStatus s) => statuses.add(s);
      service.onError = (String err) => errorMsg = err;

      final TtsSpeakResult result = await service.speak(
        'Test error',
        language: AppLanguage.english,
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Engine failure'));
      expect(errorMsg, contains('Engine failure'));
      expect(statuses, contains(TtsStatus.error));
    });

    test('stop calls tts.stop and updates status', () async {
      final List<TtsStatus> statuses = <TtsStatus>[];
      service.onStatusChanged = (TtsStatus s) => statuses.add(s);

      await service.stop();

      verify(() => mockTts.stop()).called(1);
      expect(statuses, contains(TtsStatus.stopped));
    });

    test('pause calls tts.pause and updates status', () async {
      final List<TtsStatus> statuses = <TtsStatus>[];
      service.onStatusChanged = (TtsStatus s) => statuses.add(s);

      await service.pause();

      verify(() => mockTts.pause()).called(1);
      expect(statuses, contains(TtsStatus.paused));
    });
  });
}
