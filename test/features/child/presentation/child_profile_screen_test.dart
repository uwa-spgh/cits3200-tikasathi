import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/child/presentation/child_profile_screen.dart';
import 'package:tikasathi/features/onboarding/presentation/retroactive_vaccine_screen.dart';
import 'package:tikasathi/features/vaccine_schedule/presentation/vaccine_schedule_screen.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  group('ChildProfileScreen', () {
    testWidgets(
        'shows child details and vaccination status for a populated profile',
        (WidgetTester tester) async {
      const childId = 'child-1';
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = DateTime.now();

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
                    dateOfBirth: now.subtract(const Duration(days: 270)),
                    sex: 'female',
                    isSetupComplete: true,
                  ),
                  dueVaccines: <VaccinationDue>[
                    VaccinationDue(
                      id: 'due-1',
                      childId: childId,
                      vaccineCode: 'ROTA',
                      doseNumber: 1,
                      dueDate: now,
                    ),
                    VaccinationDue(
                      id: 'due-2',
                      childId: childId,
                      vaccineCode: 'BOPV',
                      doseNumber: 1,
                      dueDate: now.add(const Duration(days: 14)),
                    ),
                  ],
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
            home: ChildProfileScreen(childId: childId),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Maya'), findsAtLeastNWidgets(1));
      expect(find.text('Female'), findsOneWidget);
      expect(find.text("Maya's page"), findsOneWidget);
      expect(find.textContaining('Born'), findsOneWidget);
      expect(find.text('Vaccination due today'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.record_voice_over), findsOneWidget);
      expect(find.text('ROTA'), findsOneWidget);
      expect(find.text('BOPV'), findsOneWidget);
      expect(find.text('Next vaccine'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(
          find.byKey(const Key('child-vaccine-schedule-card')), findsOneWidget);
    });

    testWidgets('opens schedule and history pages from feature cards',
        (WidgetTester tester) async {
      const childId = 'child-actions';
      final now = DateTime.now();
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
                    dateOfBirth: now.subtract(const Duration(days: 200)),
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
            home: ChildProfileScreen(childId: childId),
          ),
        ),
      );

      await tester.pump();

      final scheduleCard = find.byKey(const Key('child-vaccine-schedule-card'));
      await tester.scrollUntilVisible(scheduleCard, 120);
      final scheduleRect = tester.getRect(scheduleCard);
      await tester.tapAt(scheduleRect.topLeft + const Offset(24, 24));
      await tester.pumpAndSettle();
      expect(find.byType(VaccineScheduleScreen), findsOneWidget);
      expect(find.text('Vaccine schedule'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      final historyCard = find.byKey(const Key('child-vaccine-history-card'));
      await tester.scrollUntilVisible(historyCard, 120);
      final historyRect = tester.getRect(historyCard);
      await tester.tapAt(historyRect.topLeft + const Offset(24, 24));
      await tester.pumpAndSettle();

      expect(find.byType(RetroactiveVaccineScreen), findsOneWidget);
    });

    testWidgets('shows the loading indicator while child data is loading',
        (WidgetTester tester) async {
      const childId = 'loading-child';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(language: AppLanguage.english),
            ),
            childProfileProvider(childId).overrideWith(
              (ref) => Future<ChildProfileDetails>.delayed(
                const Duration(seconds: 1),
                () => throw StateError('Delayed data'),
              ),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChildProfileScreen(childId: childId),
          ),
        ),
      );

      expect(find.text('Loading child details...'), findsOneWidget);
      expect(
        find.byType(CircularProgressIndicator),
        findsAtLeastNWidgets(1),
      );

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('shows the empty state when there are no due vaccines',
        (WidgetTester tester) async {
      const childId = 'child-empty';
      final now = DateTime.now();

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
                    name: 'Asha',
                    dateOfBirth: now.subtract(const Duration(days: 120)),
                    sex: 'female',
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
            home: ChildProfileScreen(childId: childId),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Asha'), findsAtLeastNWidgets(1));
      expect(find.text("Asha's page"), findsOneWidget);
      expect(
          find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == 'Up to date',
          ),
          findsAtLeastNWidgets(1));
      expect(find.text('No upcoming vaccines'), findsOneWidget);
    });

    testWidgets('shows a not-found state when the profile cannot be loaded',
        (WidgetTester tester) async {
      const childId = 'missing-child';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(language: AppLanguage.english),
            ),
            childProfileProvider(childId).overrideWith(
              (ref) => Future<ChildProfileDetails>.error('missing'),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChildProfileScreen(childId: childId),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('Child profile not found.'), findsOneWidget);
    });

    testWidgets(
        'shows awaiting setup completion state with info banner and Complete setup button when isSetupComplete is false',
        (WidgetTester tester) async {
      const childId = 'child-incomplete';
      final now = DateTime.now();

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
                    dateOfBirth: now.subtract(const Duration(days: 90)),
                    sex: 'male',
                    isSetupComplete: false,
                  ),
                  dueVaccines: <VaccinationDue>[
                    VaccinationDue(
                      id: 'due-1',
                      childId: childId,
                      vaccineCode: 'BCG',
                      doseNumber: 1,
                      dueDate: now.subtract(const Duration(days: 90)),
                    ),
                  ],
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
            home: ChildProfileScreen(childId: childId),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Awaiting setup completion'), findsOneWidget);
      expect(
        find.text(
          'Past vaccine history hasn\'t been set up yet. Complete setup to get an accurate schedule.',
        ),
        findsOneWidget,
      );
      expect(find.text('Complete setup'), findsOneWidget);
      expect(find.text('Setup required'), findsOneWidget);
      expect(
        find.text('Visit health facility for missed vaccines.'),
        findsNothing,
      );
    });
  });
}
