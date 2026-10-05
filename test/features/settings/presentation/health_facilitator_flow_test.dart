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
import 'package:tikasathi/features/settings/presentation/settings_screen.dart';
import 'package:tikasathi/features/settings/presentation/health_facilitator_screen.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
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
    final facilitatorStream = StreamController<HealthFacilitator?>.broadcast();
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

  testWidgets('saves and edits the facilitator from Settings',
      (WidgetTester tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final facilitatorStream = StreamController<HealthFacilitator?>.broadcast();
    addTearDown(facilitatorStream.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          healthFacilitatorProvider.overrideWith(
            (ref) => facilitatorStream.stream,
          ),
          settingsRepositoryProvider.overrideWith(
            (ref) => FakeSettingsRepository(
              language: AppLanguage.english,
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SettingsScreen()),
        ),
      ),
    );
    await tester.pump();
    facilitatorStream.add(null);
    await tester.pump();

    expect(find.text('Save your closest health facility'), findsOneWidget);
    final facilitatorAction =
        find.byKey(const Key('health-facilitator-action'));
    await tester.ensureVisible(facilitatorAction);
    await tester.tap(facilitatorAction);
    await tester.pumpAndSettle();
    expect(find.byType(HealthFacilitatorScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Maya');
    await tester.enterText(find.byType(TextField).at(1), 'Ward 4');
    await tester.enterText(find.byType(TextField).at(2), '9800000000');
    final saveButton = find.widgetWithText(ElevatedButton, 'Save').first;
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    facilitatorStream
        .add(await database.healthFacilitatorsDao.getLocalFacilitator());
    await tester.pumpAndSettle();
    expect(find.text('Your local health facility'), findsOneWidget);
    expect(find.textContaining('Facility Name: Maya'), findsOneWidget);
    expect(find.textContaining('Address: Ward 4'), findsOneWidget);
    expect(find.textContaining('Phone Number: 9800000000'), findsOneWidget);
    await tester.ensureVisible(facilitatorAction);
    await tester.tap(facilitatorAction);
    await tester.pumpAndSettle();
    expect(find.byType(HealthFacilitatorScreen), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextField && widget.controller?.text == 'Maya',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TextField && widget.controller?.text == 'Ward 4',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.controller?.text == '9800000000',
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
