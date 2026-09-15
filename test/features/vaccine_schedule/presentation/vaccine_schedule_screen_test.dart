import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/vaccine_schedule/presentation/vaccine_schedule_screen.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  testWidgets('shows due doses, dates, and relative time', (
    WidgetTester tester,
  ) async {
    const childId = 'child-schedule';
    final now = DateTime(2026, 9, 14, 10);

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
                  dateOfBirth: DateTime(2026, 1, 1),
                  sex: 'female',
                  isSetupComplete: true,
                ),
                dueVaccines: [
                  VaccinationDue(
                    id: 'due-today',
                    childId: childId,
                    vaccineCode: 'BCG',
                    doseNumber: 1,
                    dueDate: now,
                  ),
                  VaccinationDue(
                    id: 'due-month',
                    childId: childId,
                    vaccineCode: 'PENTA',
                    doseNumber: 2,
                    dueDate: now.add(const Duration(days: 30)),
                  ),
                  VaccinationDue(
                    id: 'due-year',
                    childId: childId,
                    vaccineCode: 'MR',
                    doseNumber: 2,
                    dueDate: now.add(const Duration(days: 425)),
                  ),
                ],
                records: const [],
                now: now,
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: VaccineScheduleScreen(childId: childId),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Vaccine schedule'), findsOneWidget);
    expect(find.text('Vaccine dose'), findsOneWidget);
    expect(find.text('Date due'), findsOneWidget);
    expect(find.text('BCG (Dose 1)'), findsOneWidget);
    expect(find.text('PENTA (Dose 2)'), findsOneWidget);
    expect(find.text('MR (Dose 2)'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('In 1 yr 2 mo'), findsOneWidget);
  });

  testWidgets('shows an empty state when there are no due vaccines', (
    WidgetTester tester,
  ) async {
    const childId = 'empty-schedule';
    final now = DateTime(2026, 9, 14);

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
                  dateOfBirth: DateTime(2025, 1, 1),
                  sex: 'male',
                  isSetupComplete: true,
                ),
                dueVaccines: const [],
                records: const [],
                now: now,
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: VaccineScheduleScreen(childId: childId),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('There are no upcoming vaccines.'), findsOneWidget);
    expect(find.text('Return'), findsOneWidget);
  });
}
