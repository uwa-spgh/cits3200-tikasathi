import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/onboarding/presentation/child_screen.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/vaccine_records/presentation/vaccine_records_screen.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  group('Add Child Flow Secondary Skip Button', () {
    testWidgets(
        'creating a child via ChildScreen(isOnboardingFlow: false) displays Skip for now button and allows skipping to complete registration',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 30));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(language: AppLanguage.english),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChildScreen(isOnboardingFlow: false),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter child name
      await tester.enterText(find.byType(TextField).at(0), 'Aarav');

      // Enter date of birth (30 days ago)
      await tester.enterText(
        find.byType(TextField).at(1),
        pastDate.day.toString().padLeft(2, '0'),
      );
      await tester.enterText(
        find.byType(TextField).at(2),
        pastDate.month.toString().padLeft(2, '0'),
      );
      await tester.enterText(
        find.byType(TextField).at(3),
        pastDate.year.toString(),
      );

      // Tap Save child button
      final saveBtn = find.text('Save child');
      expect(saveBtn, findsOneWidget);
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify we are now on VaccineRecordsScreen with registration flow
      expect(find.byType(VaccineRecordsScreen), findsOneWidget);

      // CRITICAL CHECK: Verify the "Skip for now" button is present when creating a child
      final skipBtn = find.text('Skip for now');
      expect(skipBtn, findsOneWidget);

      // Also verify the Finish button is present
      expect(find.text('Finish'), findsOneWidget);

      // Tap Skip for now
      await tester.tap(skipBtn);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Overdue dialog must NOT appear when skipping setup
      expect(find.text('Missed Vaccines'), findsNothing);

      await tester.pump(const Duration(milliseconds: 500));

      // Verify the child in the database remains awaiting setup completion
      final children = await db.childProfilesDao.getAllChildProfiles();
      expect(children.length, 1);
      expect(children.first.name, 'Aarav');
      expect(children.first.isSetupComplete, isFalse);
    });
  });
}
