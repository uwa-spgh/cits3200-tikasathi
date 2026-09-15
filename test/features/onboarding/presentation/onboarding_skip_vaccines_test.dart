import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/app_shell/presentation/app_shell_screen.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/onboarding/presentation/caregiver_screen.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/health_facility_controller.dart';
import 'package:tikasathi/features/vaccine_records/presentation/vaccine_records_screen.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  group('Onboarding Skip Vaccines Flow', () {
    testWidgets(
        'tapping Skip for now completes onboarding and navigates to AppShellScreen rather than popping to step 1',
        (WidgetTester tester) async {
      const childId = 'child-onboard-skip';
      tester.view.physicalSize = const Size(800, 2500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final now = DateTime.now();
      // 2-week-old child
      final pastDate = now.subtract(const Duration(days: 14));

      await db.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: childId,
          name: 'Rohan',
          dateOfBirth: pastDate,
          sex: 'male',
        ),
      );
      await db.vaccinationDuesDao.insertDuesForChild(childId);

      // We simulate navigation stack: CaregiverScreen -> VaccineRecordsScreen
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(language: AppLanguage.english),
            ),
            healthFacilityProvider.overrideWith((ref) => Stream.value(null)),
            childProfileProvider(childId).overrideWith(
              (ref) => Future.value(
                ChildProfileDetails(
                  child: ChildProfile(
                    id: childId,
                    name: 'Rohan',
                    dateOfBirth: pastDate,
                    sex: 'male',
                    isSetupComplete: false,
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
            home: CaregiverScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Push VaccineRecordsScreen as onboarding step 3 (simulating pushReplacement after child screen)
      final navigatorState =
          tester.state<NavigatorState>(find.byType(Navigator));
      navigatorState.push<void>(
        MaterialPageRoute<void>(
          builder: (context) => const VaccineRecordsScreen(
            childId: childId,
            isOnboardingFlow: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Skip for now button is visible
      final skipBtn = find.text('Skip for now');
      expect(skipBtn, findsOneWidget);

      // Tap Skip for now
      await tester.tap(skipBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Overdue dialog must NOT appear when skipping setup
      expect(find.text('Missed Vaccines'), findsNothing);

      await tester.pumpAndSettle();

      // Verify we navigated to AppShellScreen and NOT CaregiverScreen
      expect(find.byType(AppShellScreen), findsOneWidget);
      expect(find.byType(CaregiverScreen), findsNothing);

      // Verify child setup remains incomplete in the database
      final updatedChild =
          await db.childProfilesDao.getChildProfileById(childId);
      expect(updatedChild?.isSetupComplete, isFalse);
    });
  });
}
