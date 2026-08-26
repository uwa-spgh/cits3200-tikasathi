import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';

class LearnPlaceholderScreen extends ConsumerWidget {
  const LearnPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppLanguage> languageState =
        ref.watch(languageControllerProvider);

    return languageState.when(
      data: (AppLanguage language) => Center(
        child: Text(
          language == AppLanguage.nepali
              ? 'सिक्नुहोस् (Placeholder)'
              : 'Learn placeholder',
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => Center(
        child: Text('Unable to load language settings: $error'),
      ),
    );
  }
}
