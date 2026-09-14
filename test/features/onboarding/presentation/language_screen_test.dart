import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/onboarding/presentation/language_screen.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  group('LanguageScreen', () {
    testWidgets('synchronizes initial language and allows switching',
        (WidgetTester tester) async {
      final repository = FakeSettingsRepository(language: AppLanguage.english);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith((ref) => repository),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final language = ref.watch(languageControllerProvider).value ??
                  AppLanguage.nepali;
              return MaterialApp(
                locale: language.locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const LanguageScreen(),
              );
            },
          ),
        ),
      );

      // Initial pump
      await tester.pump();
      // Post frame callback synchronizes language to Nepali
      await tester.pumpAndSettle();

      // Verify Nepali is displayed
      expect(find.text('स्वागत छ!'), findsOneWidget);

      // Tap English button by flag
      await tester.tap(find.text('🇬🇧'));
      await tester.pumpAndSettle();

      // Verify Welcome is displayed in English
      expect(find.text('Welcome!'), findsOneWidget);

      // Tap Nepali back by flag
      await tester.tap(find.text('🇳🇵'));
      await tester.pumpAndSettle();

      // Verify welcome in Nepali is back
      expect(find.text('स्वागत छ!'), findsOneWidget);
    });
  });
}
