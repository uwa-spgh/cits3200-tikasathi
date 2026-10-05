import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/health_facilitator_controller.dart';
import 'package:tikasathi/features/settings/presentation/health_facilitator_screen.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  testWidgets('limits facility fields when creating and editing',
      (WidgetTester tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    Future<void> pumpForm({HealthFacility? facility}) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(language: AppLanguage.english),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: HealthFacilitatorScreen(facility: facility)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpForm();
    await tester.enterText(find.byType(TextField).at(0), 'n' * 51);
    await tester.enterText(find.byType(TextField).at(1), 'a' * 81);
    await tester.enterText(find.byType(TextField).at(2), '1' * 21);

    expect(find.byType(TextField).at(0), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      hasLength(50),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      hasLength(80),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(2)).controller!.text,
      hasLength(20),
    );

    await pumpForm(
      facility: const HealthFacilitator(
        id: 'local',
        name: 'Existing facility',
        address: 'Existing address',
        phone: '9800000000',
      ),
    );
    await tester.enterText(find.byType(TextField).at(0), 'n' * 51);
    await tester.enterText(find.byType(TextField).at(1), 'a' * 81);
    await tester.enterText(find.byType(TextField).at(2), '1' * 21);

    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      hasLength(50),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      hasLength(80),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(2)).controller!.text,
      hasLength(20),
    );
  });

  testWidgets('allows an empty optional facilitator phone number',
      (WidgetTester tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          settingsRepositoryProvider.overrideWith(
            (ref) => FakeSettingsRepository(language: AppLanguage.english),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: HealthFacilitatorScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Maya');
    await tester.enterText(find.byType(TextField).at(1), 'Ward 4');
    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final facilitator =
        await database.healthFacilitatorsDao.getLocalFacilitator();
    expect(facilitator?.phone, isEmpty);
  });

  testWidgets('rejects invalid facilitator phone numbers without saving',
      (WidgetTester tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final facilitatorStream = StreamController<HealthFacility?>.broadcast();
    addTearDown(facilitatorStream.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          healthFacilitatorProvider.overrideWith(
            (ref) => facilitatorStream.stream,
          ),
          settingsRepositoryProvider.overrideWith(
            (ref) => FakeSettingsRepository(language: AppLanguage.english),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: HealthFacilitatorScreen()),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField).at(0), 'Maya');
    await tester.enterText(find.byType(TextField).at(1), 'Ward 4');
    await tester.enterText(find.byType(TextField).at(2), '98 000abc');
    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Please enter a valid phone number'), findsOneWidget);
    expect(await database.healthFacilitatorsDao.getLocalFacilitator(), isNull);
  });
}
