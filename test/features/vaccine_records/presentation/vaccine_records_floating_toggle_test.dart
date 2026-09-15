import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/vaccine_records/presentation/vaccine_records_screen.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  group('VaccineRecordsScreen floating filter toggle', () {
    testWidgets(
        'renders floating filter toggle at top and toggles between age-appropriate and all vaccines',
        (WidgetTester tester) async {
      const childId = 'child-test-123';
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final now = DateTime.now();
      // 6-week-old child
      final dob = now.subtract(const Duration(days: 42));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(language: AppLanguage.english),
            ),
            childProfileProvider(childId).overrideWith(
              (ref) => Future.value(
                ChildProfileDetails(
                  child: ChildProfile(
                    id: childId,
                    name: 'Aayush',
                    dateOfBirth: dob,
                    sex: 'male',
                    isSetupComplete: true,
                  ),
                  dueVaccines: const <VaccinationDue>[],
                  records: const <VaccinationRecord>[],
                  now: now,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VaccineRecordsScreen(
              childId: childId,
              isOnboardingFlow: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify floating selector is positioned at top
      final positionedFinder = find.ancestor(
        of: find.text('Age-appropriate only'),
        matching: find.byType(Positioned),
      );
      expect(positionedFinder, findsOneWidget);
      final Positioned positionedWidget = tester.widget(positionedFinder);
      expect(positionedWidget.top, 10);

      // Verify toggle button to Show all vaccines works
      final showAllBtn = find.text('Show all vaccines');
      expect(showAllBtn, findsOneWidget);
      await tester.tap(showAllBtn);
      await tester.pumpAndSettle();

      // Tap back to Age-appropriate only
      await tester.tap(find.text('Age-appropriate only'));
      await tester.pumpAndSettle();
    });
  });
}
