import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

part 'tts_service.g.dart';

/// Playback status of the TTS engine.
enum TtsStatus {
  stopped,
  playing,
  paused,
  error,
}

/// Result returned after attempting to speak.
class TtsSpeakResult {
  const TtsSpeakResult({
    required this.success,
    required this.resolvedLanguage,
    this.usedPhoneticFallback = false,
    this.errorMessage,
  });

  final bool success;
  final String resolvedLanguage;
  final bool usedPhoneticFallback;
  final String? errorMessage;
}

/// Service that interfaces with the device's native offline TTS engine
/// via [FlutterTts]. Supports English and Nepali (with phonetic Hindi fallback
/// on devices / platforms such as iOS where native Nepali voices are unavailable).
class TtsService {
  TtsService(this._tts);

  final FlutterTts _tts;
  bool _isInitialized = false;

  void Function(TtsStatus status)? onStatusChanged;
  void Function(String error)? onError;

  /// Initializes the TTS audio session, speech rate, and platform handlers.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambient,
          <IosTextToSpeechAudioCategoryOptions>[
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }

      // Slightly lower speech rate (0.45) for clarity with low-literacy users
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        onStatusChanged?.call(TtsStatus.playing);
      });

      _tts.setCompletionHandler(() {
        onStatusChanged?.call(TtsStatus.stopped);
      });

      _tts.setCancelHandler(() {
        onStatusChanged?.call(TtsStatus.stopped);
      });

      _tts.setPauseHandler(() {
        onStatusChanged?.call(TtsStatus.paused);
      });

      _tts.setContinueHandler(() {
        onStatusChanged?.call(TtsStatus.playing);
      });

      _tts.setErrorHandler((dynamic message) {
        final String err = message?.toString() ?? 'TTS synthesis error';
        onError?.call(err);
        onStatusChanged?.call(TtsStatus.error);
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialization warning: $e');
    }
  }

  /// Checks if a language code is available on the device.
  Future<bool> isLanguageAvailable(String langCode) async {
    try {
      final dynamic res = await _tts.isLanguageAvailable(langCode);
      if (res == true || res == 1) return true;

      final dynamic list = await _tts.getLanguages;
      if (list is List) {
        final String normalized = langCode.toLowerCase().replaceAll('_', '-');
        return list.any((dynamic item) =>
            item.toString().toLowerCase().replaceAll('_', '-') == normalized);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Resolves the best available TTS voice code for the specified [AppLanguage].
  ///
  /// For Nepali, checks `ne-NP` and `ne`. If unavailable (e.g. on iOS or
  /// Android without Nepali voice data), falls back to `hi-IN` or `hi` which
  /// shares the exact same Devanagari script and phonetics.
  Future<({String code, bool usedPhoneticFallback})> resolveLanguage(
    AppLanguage language,
  ) async {
    if (language == AppLanguage.english) {
      const List<String> englishCandidates = <String>[
        'en-US',
        'en-GB',
        'en-IN',
        'en',
      ];
      for (final String code in englishCandidates) {
        if (await isLanguageAvailable(code)) {
          return (code: code, usedPhoneticFallback: false);
        }
      }
      return (code: 'en-US', usedPhoneticFallback: false);
    }

    // Nepali candidates
    const List<String> nepaliCandidates = <String>['ne-NP', 'ne'];
    for (final String code in nepaliCandidates) {
      if (await isLanguageAvailable(code)) {
        return (code: code, usedPhoneticFallback: false);
      }
    }

    // Fallback: Hindi (Devanagari script phonetically reads Nepali)
    const List<String> hindiCandidates = <String>['hi-IN', 'hi'];
    for (final String code in hindiCandidates) {
      if (await isLanguageAvailable(code)) {
        return (code: code, usedPhoneticFallback: true);
      }
    }

    // If device doesn't report availability accurately, default according to platform
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      // iOS has built-in Hindi (hi-IN) but not Nepali (ne-NP)
      return (code: 'hi-IN', usedPhoneticFallback: true);
    }
    return (code: 'ne-NP', usedPhoneticFallback: false);
  }

  /// Speaks the given [text] in [language].
  /// Stops any currently playing speech before beginning.
  Future<TtsSpeakResult> speak(
    String text, {
    required AppLanguage language,
  }) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const TtsSpeakResult(
        success: false,
        resolvedLanguage: '',
        errorMessage: 'Text is empty',
      );
    }

    await initialize();
    await stop();

    final ({String code, bool usedPhoneticFallback}) resolved =
        await resolveLanguage(language);

    try {
      await _tts.setLanguage(resolved.code);
    } catch (e) {
      // If setting language failed and we were trying Nepali, try Hindi fallback
      if (language == AppLanguage.nepali && !resolved.usedPhoneticFallback) {
        try {
          await _tts.setLanguage('hi-IN');
        } catch (_) {}
      }
    }

    try {
      final dynamic result = await _tts.speak(trimmed);
      final bool started = result == 1 || result == true;
      if (started) {
        onStatusChanged?.call(TtsStatus.playing);
      }
      return TtsSpeakResult(
        success: started,
        resolvedLanguage: resolved.code,
        usedPhoneticFallback: resolved.usedPhoneticFallback,
      );
    } catch (e) {
      final String err = e.toString();
      onError?.call(err);
      onStatusChanged?.call(TtsStatus.error);
      return TtsSpeakResult(
        success: false,
        resolvedLanguage: resolved.code,
        usedPhoneticFallback: resolved.usedPhoneticFallback,
        errorMessage: err,
      );
    }
  }

  /// Stops any ongoing speech immediately.
  Future<void> stop() async {
    try {
      await _tts.stop();
      onStatusChanged?.call(TtsStatus.stopped);
    } catch (e) {
      debugPrint('TTS stop warning: $e');
    }
  }

  /// Pauses current speech.
  Future<void> pause() async {
    try {
      await _tts.pause();
      onStatusChanged?.call(TtsStatus.paused);
    } catch (e) {
      debugPrint('TTS pause warning: $e');
    }
  }
}

@Riverpod(keepAlive: true)
FlutterTts flutterTts(FlutterTtsRef ref) {
  return FlutterTts();
}

@Riverpod(keepAlive: true)
TtsService ttsService(TtsServiceRef ref) {
  final FlutterTts tts = ref.watch(flutterTtsProvider);
  return TtsService(tts);
}
