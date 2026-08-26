import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drift/native.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tikasathi/features/app_shell/presentation/app_bottom_navigation_bar.dart';
import 'package:tikasathi/main.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  testWidgets('App boots into shell with bottom navigation',
      (WidgetTester tester) async {
    final mockStorage = MockSecureStorageService();
    when(() => mockStorage.hasCompletedOnboarding())
        .thenAnswer((_) async => true);
    when(() => mockStorage.getLanguage()).thenAnswer((_) async => 'en');

    // Wrap in ProviderScope as required by Riverpod
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            final db = AppDatabase.forTesting(NativeDatabase.memory());
            ref.onDispose(db.close);
            return db;
          }),
          secureStorageServiceProvider.overrideWithValue(mockStorage),
        ],
        child: const TikaSathiApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNavigationBar), findsOneWidget);
    expect(find.byKey(const Key('home-title')), findsOneWidget);
  });

  testWidgets('AppLocalizations resolves English and Nepali locales',
      (WidgetTester tester) async {
    const englishLocale = Locale('en');
    const nepaliLocale = Locale('ne');

    await tester.pumpWidget(
      const MaterialApp(
        locale: englishLocale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final englishContext = tester.element(find.byType(SizedBox));
    expect(AppLocalizations.of(englishContext)!.appTitle, 'TikaSathi');

    await tester.pumpWidget(
      const MaterialApp(
        locale: nepaliLocale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final nepaliContext = tester.element(find.byType(SizedBox));
    expect(AppLocalizations.of(nepaliContext)!.appTitle, 'टीकासाथी');
  });
}
