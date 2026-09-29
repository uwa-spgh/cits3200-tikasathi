import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tikasathi/core/services/tts_service.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';

part 'tts_controller.freezed.dart';
part 'tts_controller.g.dart';

@freezed
class TtsStateData with _$TtsStateData {
  const factory TtsStateData({
    @Default(TtsStatus.stopped) TtsStatus status,
    @Default('') String currentText,
    @Default(false) bool isSpeaking,
    @Default(false) bool usedPhoneticFallback,
    String? errorMessage,
  }) = _TtsStateData;
}

@Riverpod(keepAlive: true)
class TtsController extends _$TtsController {
  @override
  TtsStateData build() {
    final TtsService service = ref.watch(ttsServiceProvider);

    service.onStatusChanged = (TtsStatus status) {
      state = state.copyWith(
        status: status,
        isSpeaking: status == TtsStatus.playing,
      );
    };

    service.onError = (String error) {
      state = state.copyWith(
        status: TtsStatus.error,
        isSpeaking: false,
        errorMessage: error,
      );
    };

    ref.onDispose(() {
      service.onStatusChanged = null;
      service.onError = null;
    });

    return const TtsStateData();
  }

  Future<TtsSpeakResult> speak(String text, {AppLanguage? language}) async {
    final AppLanguage currentLanguage = language ??
        ref.read(languageControllerProvider).asData?.value ??
        AppLanguage.nepali;

    state = state.copyWith(
      status: TtsStatus.playing,
      isSpeaking: true,
      currentText: text,
      errorMessage: null,
    );

    final TtsService service = ref.read(ttsServiceProvider);
    final TtsSpeakResult result =
        await service.speak(text, language: currentLanguage);

    state = state.copyWith(
      status: result.success ? TtsStatus.playing : TtsStatus.error,
      isSpeaking: result.success,
      usedPhoneticFallback: result.usedPhoneticFallback,
      errorMessage: result.errorMessage,
    );

    return result;
  }

  Future<void> stop() async {
    final TtsService service = ref.read(ttsServiceProvider);
    await service.stop();
    state = state.copyWith(
      status: TtsStatus.stopped,
      isSpeaking: false,
      currentText: '',
    );
  }
}
