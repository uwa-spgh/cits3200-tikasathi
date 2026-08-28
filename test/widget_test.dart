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
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/health_facilitator_controller.dart';
import 'package:tikasathi/main.dart';

import 'helpers/fake_settings_repository.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    AppLanguage language = AppLanguage.nepali,
  }) async {
    final MockSecureStorageService mockStorage = MockSecureStorageService();
    when(() => mockStorage.hasCompletedOnboarding())
        .thenAnswer((_) async => true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            final AppDatabase db =
                AppDatabase.forTesting(NativeDatabase.memory());
            ref.onDispose(db.close);
            return db;
          }),
          secureStorageServiceProvider.overrideWithValue(mockStorage),
          settingsRepositoryProvider.overrideWith(
            (ref) => FakeSettingsRepository(language: language),
          ),
          healthFacilitatorProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const TikaSathiApp(),
      ),
    );

    await tester.pumpAndSettle();
  }

  Locale localeOfHome(WidgetTester tester) {
    final BuildContext context =
        tester.element(find.byKey(const Key('home-title')));
    return Localizations.localeOf(context);
  }

  testWidgets('App boots into shell with bottom navigation',
      (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.byType(AppBottomNavigationBar), findsOneWidget);
    expect(find.byKey(const Key('home-title')), findsOneWidget);
  });

  testWidgets('uses the persisted Nepali locale on MaterialApp',
      (WidgetTester tester) async {
    await pumpApp(tester, language: AppLanguage.nepali);

    expect(localeOfHome(tester), const Locale('ne'));
  });

  testWidgets('uses the persisted English locale on MaterialApp',
      (WidgetTester tester) async {
    await pumpApp(tester, language: AppLanguage.english);

    expect(localeOfHome(tester), const Locale('en'));
  });

  testWidgets('AppLocalizations resolves English and Nepali locales',
      (WidgetTester tester) async {
    const Locale englishLocale = Locale('en');
    const Locale nepaliLocale = Locale('ne');

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

    final BuildContext englishContext = tester.element(find.byType(SizedBox));
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

    final BuildContext nepaliContext = tester.element(find.byType(SizedBox));
    expect(AppLocalizations.of(nepaliContext)!.appTitle, 'टीकासाथी');
  });
}
