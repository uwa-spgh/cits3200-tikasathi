import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/services/screen_speech_helper.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/home/domain/home_models.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

void main() {
  group('ScreenSpeechHelper', () {
    testWidgets('extractVisibleText collects visible Text and RichText',
        (WidgetTester tester) async {
      late String extracted;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return Column(
                  children: [
                    const Text('Childhood Immunisation'),
                    RichText(
                      text: const TextSpan(
                        text: 'Next vaccine is due tomorrow',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        extracted =
                            ScreenSpeechHelper.extractVisibleText(context);
                      },
                      child: const Text('Extract'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(extracted, contains('Childhood Immunisation'));
      expect(extracted, contains('Next vaccine is due tomorrow'));
      expect(extracted, contains('Extract'));
    });

    testWidgets('homeScreenText formats English and Nepali correctly',
        (WidgetTester tester) async {
      late String enEmpty;
      late String npEmpty;
      late String enPopulated;
      late String npPopulated;

      final List<HomeStatusGroup> groups = <HomeStatusGroup>[
        HomeStatusGroup(
          group: HomeVaccinationGroup.upToDate,
          children: <HomeChildSummary>[
            HomeChildSummary(
              name: 'Aarav',
              dateOfBirth: DateTime(2025, 1, 1),
              avatarEmoji: '👶',
              canRecordDose: true,
            ),
          ],
        ),
        HomeStatusGroup(
          group: HomeVaccinationGroup.dueToday,
          children: <HomeChildSummary>[
            HomeChildSummary(
              name: 'Maya',
              dateOfBirth: DateTime(2024, 6, 1),
              avatarEmoji: '👧',
              canRecordDose: true,
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              final AppLocalizations l10n = AppLocalizations.of(context)!;
              enEmpty = ScreenSpeechHelper.homeScreenText(
                context: context,
                localizations: l10n,
                groups: const <HomeStatusGroup>[],
              );
              enPopulated = ScreenSpeechHelper.homeScreenText(
                context: context,
                localizations: l10n,
                groups: groups,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(enEmpty, contains('Welcome to TikaSathi'));
      expect(enEmpty,
          isNot(contains('TikaSathi Childhood Immunisation Tracking')));
      expect(enPopulated, contains('Vaccinations are up to date for: Aarav'));
      expect(enPopulated, contains('Vaccines due today for: Maya'));
      expect(enPopulated,
          isNot(contains('TikaSathi Childhood Immunisation Tracking')));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ne'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              final AppLocalizations l10n = AppLocalizations.of(context)!;
              npEmpty = ScreenSpeechHelper.homeScreenText(
                context: context,
                localizations: l10n,
                groups: const <HomeStatusGroup>[],
              );
              npPopulated = ScreenSpeechHelper.homeScreenText(
                context: context,
                localizations: l10n,
                groups: groups,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(npEmpty, contains('टिकासार्थीमा स्वागत छ'));
      expect(npEmpty, isNot(contains('टिकासार्थी बाल खोप ट्र्याकिङ')));
      expect(
          npPopulated, contains('खोप पूर्ण अवस्थामा रहेका बालबालिका: Aarav'));
      expect(npPopulated, contains('आज खोप लगाउने मिति भएका बालबालिका: Maya'));
      expect(npPopulated, isNot(contains('टिकासार्थी बाल खोप ट्र्याकिङ')));
    });

    testWidgets('childProfileScreenText builds natural narrative',
        (WidgetTester tester) async {
      late String enText;
      late String npText;

      final ChildProfileDetails details = ChildProfileDetails(
        child: ChildProfile(
          id: '1',
          name: 'Maya',
          dateOfBirth: DateTime(2025, 5, 10),
          sex: 'Female',
          isSetupComplete: true,
        ),
        dueVaccines: <VaccinationDue>[
          VaccinationDue(
            id: 'd1',
            childId: '1',
            vaccineCode: 'Penta 1',
            doseNumber: 1,
            dueDate: DateTime(2025, 6, 21),
          ),
        ],
        records: <VaccinationRecord>[
          VaccinationRecord(
            id: 'r1',
            childId: '1',
            vaccineCode: 'BCG',
            doseNumber: 1,
            administeredDate: DateTime(2025, 5, 11),
          ),
        ],
        now: DateTime(2025, 6, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              enText = ScreenSpeechHelper.childProfileScreenText(
                context: context,
                localizations: AppLocalizations.of(context)!,
                details: details,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(enText, contains('Child profile for Maya'));
      expect(enText, contains('Next vaccine: Penta 1'));
      expect(enText, contains('Completed vaccines: 1 doses'));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ne'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              npText = ScreenSpeechHelper.childProfileScreenText(
                context: context,
                localizations: AppLocalizations.of(context)!,
                details: details,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(npText, contains('Mayaको खोप विवरण'));
      expect(npText, contains('अर्को खोप: Penta 1'));
      expect(npText, contains('लागेका खोपहरू: 1 मात्रा'));
    });

    testWidgets(
        'vaccineScheduleScreenText includes core immunisation milestones',
        (WidgetTester tester) async {
      late String enText;
      late String npText;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              enText = ScreenSpeechHelper.vaccineScheduleScreenText(
                context: context,
                localizations: AppLocalizations.of(context)!,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(enText, contains('National Immunisation Schedule of Nepal'));
      expect(enText, contains('BCG'));
      expect(enText, contains('Pentavalent'));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ne'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              npText = ScreenSpeechHelper.vaccineScheduleScreenText(
                context: context,
                localizations: AppLocalizations.of(context)!,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(npText, contains('नेपालको राष्ट्रिय बाल खोप तालिका'));
      expect(npText, contains('बीसीजी'));
      expect(npText, contains('पेन्टाभालेन्ट'));
    });

    testWidgets('settingsScreenText formats instructions',
        (WidgetTester tester) async {
      late String enSettings;
      late String npSettings;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              final AppLocalizations l10n = AppLocalizations.of(context)!;
              enSettings = ScreenSpeechHelper.settingsScreenText(
                context: context,
                localizations: l10n,
                currentLanguage: AppLanguage.english,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(enSettings, contains('Settings'));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ne'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              final AppLocalizations l10n = AppLocalizations.of(context)!;
              npSettings = ScreenSpeechHelper.settingsScreenText(
                context: context,
                localizations: l10n,
                currentLanguage: AppLanguage.nepali,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(npSettings, contains('सेटिङहरू'));
    });

    testWidgets(
        'recordDoseScreenText formats 2 steps with ticked or available vaccines',
        (WidgetTester tester) async {
      late String enNoTicks;
      late String enWithTicks;
      late String npWithTicks;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              final AppLocalizations l10n = AppLocalizations.of(context)!;
              enNoTicks = ScreenSpeechHelper.recordDoseScreenText(
                context: context,
                localizations: l10n,
                childName: 'Aarav',
                administeredDate: DateTime(2025, 6, 1),
                tickedVaccineNames: const <String>[],
                availableVaccineNames: const <String>['BCG', 'OPV 0'],
              );
              enWithTicks = ScreenSpeechHelper.recordDoseScreenText(
                context: context,
                localizations: l10n,
                childName: 'Aarav',
                administeredDate: DateTime(2025, 6, 1),
                tickedVaccineNames: const <String>['BCG'],
                availableVaccineNames: const <String>['BCG', 'OPV 0'],
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(enNoTicks, contains('Log vaccine dose for Aarav'));
      expect(enNoTicks, contains('Step 1: Check the date given'));
      expect(enNoTicks, contains('Step 2: Tick the given vaccines'));
      expect(enNoTicks, contains('No vaccines ticked yet'));
      expect(enNoTicks, contains('Available vaccines: BCG, OPV 0'));
      expect(enNoTicks, isNot(contains('Step 3')));
      expect(enNoTicks, isNot(contains('Step 4')));

      expect(enWithTicks, contains('Step 1: Check the date given'));
      expect(enWithTicks, contains('Step 2: Tick the given vaccines'));
      expect(enWithTicks, contains('Ticked vaccines: BCG'));
      expect(enWithTicks, contains('Tap save to record'));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ne'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              final AppLocalizations l10n = AppLocalizations.of(context)!;
              npWithTicks = ScreenSpeechHelper.recordDoseScreenText(
                context: context,
                localizations: l10n,
                childName: 'Aarav',
                administeredDate: DateTime(2025, 6, 1),
                tickedVaccineNames: const <String>['BCG'],
                availableVaccineNames: const <String>['BCG', 'OPV 0'],
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(npWithTicks, contains('Aaravको खोप मात्रा दर्ता'));
      expect(npWithTicks, contains('चरण १: खोप लगाएको मिति जाँच गर्नुहोस्'));
      expect(npWithTicks, contains('चरण २: लगाइएका खोपहरूमा चिन्ह लगाउनुहोस्'));
      expect(npWithTicks, contains('चिन्ह लगाइएका खोपहरू: BCG'));
      expect(npWithTicks, isNot(contains('चरण ३')));
      expect(npWithTicks, isNot(contains('चरण ४')));
    });

    testWidgets(
        'vaccineRecordsScreenText reflects onboarding vs history flow correctly',
        (WidgetTester tester) async {
      late String enOnboardingAgeAppropriate;
      late String enOnboardingAll;
      late String enHistoryAgeAppropriate;
      late String enHistoryAll;
      late String npOnboarding;

      final List<VaccinationRecord> records = <VaccinationRecord>[
        VaccinationRecord(
          id: 'r1',
          childId: 'c1',
          vaccineCode: 'BCG',
          doseNumber: 1,
          administeredDate: DateTime(2025, 1, 1),
        ),
      ];

      final List<VaccinationDue> dues = <VaccinationDue>[
        VaccinationDue(
          id: 'd1',
          childId: 'c1',
          vaccineCode: 'Penta 1',
          doseNumber: 1,
          dueDate: DateTime(2025, 3, 1),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              final AppLocalizations l10n = AppLocalizations.of(context)!;
              enOnboardingAgeAppropriate =
                  ScreenSpeechHelper.vaccineRecordsScreenText(
                context: context,
                localizations: l10n,
                childName: 'Maya',
                isRegistrationFlow: true,
                showAllVaccines: false,
                visibleVaccineNames: const <String>['BCG', 'OPV 0'],
                tickedVaccineNames: const <String>['BCG'],
                records: records,
                dues: dues,
              );
              enOnboardingAll = ScreenSpeechHelper.vaccineRecordsScreenText(
                context: context,
                localizations: l10n,
                childName: 'Maya',
                isRegistrationFlow: true,
                showAllVaccines: true,
                visibleVaccineNames: const <String>[
                  'BCG',
                  'OPV 0',
                  'Penta 1',
                  'Rota 1'
                ],
                tickedVaccineNames: const <String>['BCG'],
                records: records,
                dues: dues,
              );
              enHistoryAgeAppropriate =
                  ScreenSpeechHelper.vaccineRecordsScreenText(
                context: context,
                localizations: l10n,
                childName: 'Maya',
                isRegistrationFlow: false,
                showAllVaccines: false,
                visibleVaccineNames: const <String>['BCG'],
                tickedVaccineNames: const <String>['BCG'],
                records: records,
                dues: dues,
              );
              enHistoryAll = ScreenSpeechHelper.vaccineRecordsScreenText(
                context: context,
                localizations: l10n,
                childName: 'Maya',
                isRegistrationFlow: false,
                showAllVaccines: true,
                visibleVaccineNames: const <String>['BCG', 'Penta 1'],
                tickedVaccineNames: const <String>['BCG'],
                records: records,
                dues: dues,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      // Onboarding with age-appropriate tab
      expect(
        enOnboardingAgeAppropriate,
        contains('Please tick the vaccines already given to Maya'),
      );
      expect(
        enOnboardingAgeAppropriate,
        contains('Showing age-appropriate vaccines: BCG, OPV 0'),
      );
      expect(enOnboardingAgeAppropriate, contains('Ticked vaccines: BCG'));
      expect(
        enOnboardingAgeAppropriate,
        contains('You can also skip this for now'),
      );
      expect(
        enOnboardingAgeAppropriate,
        isNot(contains('Upcoming vaccines')),
      );

      // Onboarding with all vaccines tab
      expect(
        enOnboardingAll,
        contains('Showing all schedule vaccines: BCG, OPV 0, Penta 1, Rota 1'),
      );

      // Child page history: age-appropriate selected -> does NOT read upcoming vaccines
      expect(enHistoryAgeAppropriate, contains('Vaccine history for Maya'));
      expect(enHistoryAgeAppropriate, contains('Completed vaccines: BCG'));
      expect(
        enHistoryAgeAppropriate,
        isNot(contains('Upcoming vaccines')),
      );

      // Child page history: all vaccines selected -> reads upcoming vaccines
      expect(enHistoryAll, contains('Vaccine history for Maya'));
      expect(enHistoryAll, contains('Completed vaccines: BCG'));
      expect(enHistoryAll, contains('Upcoming vaccines: Penta 1'));

      // Nepali onboarding
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ne'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              final AppLocalizations l10n = AppLocalizations.of(context)!;
              npOnboarding = ScreenSpeechHelper.vaccineRecordsScreenText(
                context: context,
                localizations: l10n,
                childName: 'Maya',
                isRegistrationFlow: true,
                showAllVaccines: false,
                visibleVaccineNames: const <String>['BCG', 'OPV 0'],
                tickedVaccineNames: const <String>[],
                records: records,
                dues: dues,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(npOnboarding,
          contains('कृपया Maya लाई लगाइसकेका खोपहरूमा चिन्ह लगाउनुहोस्'));
      expect(npOnboarding,
          contains('उमेर अनुसारका खोपहरू देखाइएको छ: BCG, OPV 0'));
      expect(npOnboarding, contains('तपाईं यसलाई अहिले छोड्न पनि सक्नुहुन्छ'));
    });
  });
}
