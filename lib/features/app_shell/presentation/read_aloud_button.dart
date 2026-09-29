import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/services/screen_speech_helper.dart';
import 'package:tikasathi/core/services/tts_controller.dart';
import 'package:tikasathi/core/services/tts_service.dart';

void showFeedbackSnackBar(BuildContext context, String message) {
  final ScaffoldMessengerState scaffoldMessenger =
      ScaffoldMessenger.of(context);
  scaffoldMessenger.hideCurrentSnackBar();
  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

class ReadAloudButton extends ConsumerWidget {
  const ReadAloudButton({
    super.key,
    this.text,
    this.textGetter,
    required this.tooltip,
    this.stopTooltip,
    required this.unavailableMessage,
  });

  /// Explicit text string to read aloud.
  final String? text;

  /// Dynamic callback returning the text to read aloud when tapped.
  final String Function()? textGetter;

  /// Tooltip displayed when not currently speaking.
  final String tooltip;

  /// Tooltip displayed when currently speaking.
  final String? stopTooltip;

  /// Retained for backwards compatibility / fallback.
  final String unavailableMessage;

  Future<void> _handlePress(BuildContext context, WidgetRef ref) async {
    final TtsStateData ttsState = ref.read(ttsControllerProvider);
    if (ttsState.isSpeaking) {
      await ref.read(ttsControllerProvider.notifier).stop();
      return;
    }

    final String speechText = text ??
        textGetter?.call() ??
        ScreenSpeechHelper.extractVisibleText(context);

    if (speechText.trim().isEmpty) {
      if (context.mounted) {
        final AppLocalizations? l10n = AppLocalizations.of(context);
        showFeedbackSnackBar(
          context,
          l10n?.childReadAloudNoContent ?? 'No text to read.',
        );
      }
      return;
    }

    final TtsSpeakResult result =
        await ref.read(ttsControllerProvider.notifier).speak(speechText);

    if (!result.success && context.mounted) {
      final AppLocalizations? l10n = AppLocalizations.of(context);
      showFeedbackSnackBar(
        context,
        result.errorMessage != null
            ? (l10n?.childReadAloudError ?? 'Could not read text aloud.')
            : unavailableMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TtsStateData ttsState = ref.watch(ttsControllerProvider);
    final bool isSpeaking = ttsState.isSpeaking;
    final AppLocalizations? localizations = AppLocalizations.of(context);

    final String activeTooltip = isSpeaking
        ? (stopTooltip ??
            localizations?.childReadAloudStopTooltip ??
            'Stop reading aloud')
        : tooltip;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSpeaking ? const Color(0xFF1D65C1) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF1D65C1),
          width: 1.5,
        ),
      ),
      child: IconButton(
        onPressed: () => _handlePress(context, ref),
        icon: Icon(
          isSpeaking ? Icons.stop_rounded : Icons.record_voice_over,
          color: isSpeaking ? Colors.white : const Color(0xFF1D65C1),
        ),
        tooltip: activeTooltip,
      ),
    );
  }
}
