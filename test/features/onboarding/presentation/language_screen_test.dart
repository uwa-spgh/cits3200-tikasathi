import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/l10n/app_localizations.dart';
import 'package:tikasathi/features/onboarding/presentation/language_screen.dart';

void main() {
  testWidgets('LanguageScreen renders localized strings correctly in English',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: LanguageScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('LanguageScreen renders localized strings correctly in Nepali',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('ne'), // The ARB locale code is 'ne'
          home: LanguageScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('स्वागत छ!'), findsOneWidget);
    // Actually continue is अगाडि बढ्नुहोस्, but let's test one string
    expect(find.text('अगाडि बढ्नुहोस्'), findsOneWidget);
  });
}
