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
  group('VaccineRecordsScreen overdue advisory dialog', () {
    testWidgets(
        'shows overdue alert dialog with health facility prompt when child has overdue vaccines',
        (WidgetTester tester) async {
      const childId = 'child-overdue';
      tester.view.physicalSize = const Size(800, 2500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 300));

      // Insert child profile
      await db.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: childId,
          name: 'Sunita',
          dateOfBirth: pastDate,
          sex: 'female',
        ),
      );

      // Generate overdue dues for child
      await db.vaccinationDuesDao.insertDuesForChild(childId);

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
                    name: 'Sunita',
                    dateOfBirth: pastDate,
                    sex: 'female',
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
            home: VaccineRecordsScreen(
              childId: childId,
              isOnboardingFlow: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Save Changes button
      final saveBtn = find.text('Save Changes');
      expect(saveBtn, findsOneWidget);
      await tester.tap(saveBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify the Overdue dialog pops up with prompt to visit health facility
      expect(find.text('Missed Vaccines'), findsOneWidget);
      expect(
        find.text(
          'Visit health facility for missed vaccines.',
        ),
        findsOneWidget,
      );
      expect(find.text('OK'), findsOneWidget);

      // Tap OK to dismiss
      await tester.tap(find.text('OK'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Dialog is dismissed
      expect(find.text('Missed Vaccines'), findsNothing);
    });
  });
}
