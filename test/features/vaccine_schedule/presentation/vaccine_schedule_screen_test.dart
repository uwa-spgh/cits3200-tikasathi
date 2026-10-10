import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/vaccine_schedule/presentation/vaccine_schedule_editor_screen.dart';
import 'package:tikasathi/features/vaccine_schedule/presentation/vaccine_schedule_screen.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  testWidgets('shows due doses and dates', (
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
    expect(find.text('BCG'), findsOneWidget);
    expect(find.text('BCG (Dose 1)'), findsNothing);
    expect(find.text('PENTA (Dose 2)'), findsOneWidget);
    expect(find.text('MR (Dose 2)'), findsOneWidget);
    expect(find.text('Today · 14 Sep 2026'), findsOneWidget);
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
  });

  testWidgets('opens vaccine editing when the card body is tapped', (
    WidgetTester tester,
  ) async {
    await _pumpEditor(tester);

    await tester.tap(find.text('PENTA (Dose 2)'));
    await tester.pumpAndSettle();

    expect(find.text('Edit scheduled vaccine'), findsOneWidget);
    expect(find.text('PENTA'), findsOneWidget);
  });

  testWidgets('opens vaccine editing when the edit icon is tapped', (
    WidgetTester tester,
  ) async {
    await _pumpEditor(tester);

    await tester.tap(find.byIcon(Icons.edit_calendar));
    await tester.pumpAndSettle();

    expect(find.text('Edit scheduled vaccine'), findsOneWidget);
    expect(find.text('PENTA'), findsOneWidget);
  });

  testWidgets(
      'editor filter shows overdue, due today and due soon doses by default', (
    WidgetTester tester,
  ) async {
    // Born 15 Jan 2026 and up to date: the 9-month doses are 5 days away.
    final now = DateTime(2026, 10, 10, 9);
    await _pumpEditor(
      tester,
      now: now,
      dateOfBirth: DateTime(2026, 1, 15),
      dues: [
        _due('PCV', 2, now.subtract(const Duration(days: 12))),
        _due('PENTA', 3, now),
        _due('MR', 1, now.add(const Duration(days: 5))),
        _due('FIPV', 2, now.add(const Duration(days: 14))),
        _due('JE', 1, now.add(const Duration(days: 15))),
      ],
    );

    expect(find.text('PCV (Dose 2)'), findsOneWidget);
    expect(find.text('PENTA (Dose 3)'), findsOneWidget);
    expect(find.text('MR (Dose 1)'), findsOneWidget);
    expect(find.text('FIPV (Dose 2)'), findsOneWidget);
    expect(find.text('JE'), findsNothing);
    expect(find.text('No outstanding vaccines are scheduled.'), findsNothing);
  });

  testWidgets('editor filter uses the scheduled date, not the standard age', (
    WidgetTester tester,
  ) async {
    // A catch-up PCV 3 due in 7 days, months before its standard 9-month age.
    final now = DateTime(2026, 10, 10, 9);
    await _pumpEditor(
      tester,
      now: now,
      dateOfBirth: DateTime(2026, 7, 4),
      dues: [_due('PCV', 3, now.add(const Duration(days: 7)))],
    );

    expect(find.text('PCV (Dose 3)'), findsOneWidget);
  });

  testWidgets('editor shows later doses only after Show all vaccines', (
    WidgetTester tester,
  ) async {
    final now = DateTime(2026, 10, 10, 9);
    await _pumpEditor(
      tester,
      now: now,
      dateOfBirth: DateTime(2026, 1, 15),
      dues: [_due('JE', 1, DateTime(2027, 1, 15))],
    );

    expect(find.text('JE'), findsNothing);
    expect(find.text('No outstanding vaccines are scheduled.'), findsOneWidget);

    await tester.tap(find.text('Show all vaccines'));
    await tester.pumpAndSettle();

    expect(find.text('JE'), findsOneWidget);
  });
}

VaccinationDue _due(String vaccineCode, int doseNumber, DateTime dueDate) {
  return VaccinationDue(
    id: 'due-$vaccineCode-$doseNumber',
    childId: 'editor-child',
    vaccineCode: vaccineCode,
    doseNumber: doseNumber,
    dueDate: dueDate,
  );
}

Future<void> _pumpEditor(
  WidgetTester tester, {
  DateTime? now,
  DateTime? dateOfBirth,
  List<VaccinationDue>? dues,
}) async {
  const childId = 'editor-child';
  now ??= DateTime(2026, 9, 14);

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
                dateOfBirth: dateOfBirth ?? DateTime(2026, 1, 1),
                sex: 'female',
                isSetupComplete: true,
              ),
              dueVaccines: dues ?? [_due('PENTA', 2, now!)],
              records: const [],
              now: now!,
            ),
          ),
        ),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VaccineScheduleEditorScreen(childId: childId),
      ),
    ),
  );

  await tester.pumpAndSettle();
}
