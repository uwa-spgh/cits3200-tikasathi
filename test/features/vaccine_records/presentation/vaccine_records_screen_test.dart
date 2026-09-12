import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/vaccine_records/presentation/vaccine_records_screen.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  group('VaccineRecordsScreen', () {
    testWidgets('shows all recorded vaccinations', (WidgetTester tester) async {

      const childId = 'child-1';
      final now = DateTime.now();
      final dob = now.subtract(const Duration(days: 105));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(language: AppLanguage.english),
            ),
            childProfileProvider(childId).overrideWith(
              (ref) => Future.value(
                ChildProfileDetails(
                  child: ChildProfile(
                    id: childId,
                    name: 'Maya',
                    dateOfBirth: dob,
                    sex: 'female',
                    isSetupComplete: true,
                  ),
                  dueVaccines: const <VaccinationDue>[],
                  records: <VaccinationRecord>[
                    VaccinationRecord(id: 'rec-1', childId: childId, vaccineCode: 'BCG', doseNumber: 1, administeredDate: dob.add(const Duration(days: 1))),
                    VaccinationRecord(id: 'rec-2', childId: childId, vaccineCode: 'PENTA', doseNumber: 1, administeredDate: dob.add(const Duration(days: 42))),
                    VaccinationRecord(id: 'rec-3', childId: childId, vaccineCode: 'PENTA', doseNumber: 2, administeredDate: dob.add(const Duration(days: 70))),
                    VaccinationRecord(id: 'rec-4', childId: childId, vaccineCode: 'PENTA', doseNumber: 3, administeredDate: dob.add(const Duration(days: 98))),
                    VaccinationRecord(id: 'rec-5', childId: childId, vaccineCode: 'BOPV', doseNumber: 1, administeredDate: dob.add(const Duration(days: 42))),
                    VaccinationRecord(id: 'rec-6', childId: childId, vaccineCode: 'BOPV', doseNumber: 2, administeredDate: dob.add(const Duration(days: 70))),
                    VaccinationRecord(id: 'rec-7', childId: childId, vaccineCode: 'BOPV', doseNumber: 3, administeredDate: dob.add(const Duration(days: 98))),
                    VaccinationRecord(id: 'rec-8', childId: childId, vaccineCode: 'FIPV', doseNumber: 1, administeredDate: dob.add(const Duration(days: 98))),
                    VaccinationRecord(id: 'rec-9', childId: childId, vaccineCode: 'ROTA', doseNumber: 1, administeredDate: dob.add(const Duration(days: 42))),
                    VaccinationRecord(id: 'rec-10', childId: childId, vaccineCode: 'ROTA', doseNumber: 2, administeredDate: dob.add(const Duration(days: 70))),
                    VaccinationRecord(id: 'rec-11', childId: childId, vaccineCode: 'PCV', doseNumber: 1, administeredDate: dob.add(const Duration(days: 42))),
                    VaccinationRecord(id: 'rec-12', childId: childId, vaccineCode: 'PCV', doseNumber: 2, administeredDate: dob.add(const Duration(days: 70))),
                  ],
                  now: now,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VaccineRecordsScreen(childId: childId),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('BCG (Dose 1)'), findsOneWidget);
      expect(find.text('PENTA (Dose 1)'), findsOneWidget);
      expect(find.text('PENTA (Dose 2)'), findsOneWidget);
      expect(find.text('PENTA (Dose 3)'), findsOneWidget);
      expect(find.text('BOPV (Dose 1)'), findsOneWidget);
      expect(find.text('BOPV (Dose 2)'), findsOneWidget);
      expect(find.text('BOPV (Dose 3)'), findsOneWidget);
      expect(find.text('FIPV (Dose 1)'), findsOneWidget);
      expect(find.text('ROTA (Dose 1)'), findsOneWidget);
      expect(find.text('ROTA (Dose 2)'), findsOneWidget);
      expect(find.text('PCV (Dose 1)'), findsOneWidget);
      expect(find.text('PCV (Dose 2)'), findsOneWidget);
      expect(find.text('Return'), findsOneWidget);
    });

    testWidgets('shows that there are no records', (WidgetTester tester) async {
      const childId = 'child-2';
      final now = DateTime.now();
      final dob = now.subtract(const Duration(days: 105));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(language: AppLanguage.english),
            ),
            childProfileProvider(childId).overrideWith(
              (ref) => Future.value(
                ChildProfileDetails(
                  child: ChildProfile(
                    id: childId,
                    name: 'Nima',
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
            home: VaccineRecordsScreen(childId: childId),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('There are no recorded vaccinations.'), findsOneWidget);
      expect(find.text('Return'), findsOneWidget);
    });
  });

}