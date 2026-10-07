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

    testWidgets(
        'adds a localized scroll instruction only when content overflows',
        (WidgetTester tester) async {
      final List<HomeStatusGroup> groups = <HomeStatusGroup>[
        HomeStatusGroup(
          group: HomeVaccinationGroup.upToDate,
          children: <HomeChildSummary>[
            HomeChildSummary(
              name: 'Aarav',
              dateOfBirth: DateTime(2025, 1, 1),
              avatarEmoji: '👶',
              canRecordDose: false,
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ListView(
            children: <Widget>[
              Builder(
                builder: (BuildContext context) => Container(
                  key: const Key('overflow-context'),
                  height: 50,
                ),
              ),
              const SizedBox(height: 1000),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext overflowContext =
          tester.element(find.byKey(const Key('overflow-context')));
      final AppLocalizations overflowLocalizations =
          AppLocalizations.of(overflowContext)!;
      final String overflowText = ScreenSpeechHelper.homeScreenText(
        context: overflowContext,
        localizations: overflowLocalizations,
        groups: groups,
      );

      expect(overflowText, endsWith('Scroll down to see all children.'));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) => Container(
              key: const Key('fitting-context'),
              height: 50,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext fittingContext =
          tester.element(find.byKey(const Key('fitting-context')));
      final AppLocalizations fittingLocalizations =
          AppLocalizations.of(fittingContext)!;
      final String fittingText = ScreenSpeechHelper.homeScreenText(
        context: fittingContext,
        localizations: fittingLocalizations,
        groups: groups,
      );

      expect(fittingText, isNot(contains('Scroll down to see all children.')));
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

      expect(enText, isNot(contains('Age:')));
      expect(enText, isNot(contains('Date of birth:')));
      expect(enText, isNot(contains('Born on:')));
      expect(enText, isNot(contains('Sex:')));
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

      expect(npText, isNot(contains('उमेर:')));
      expect(npText, isNot(contains('जन्म मिति:')));
      expect(npText, isNot(contains('लिङ्ग:')));
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

    testWidgets('vaccineScheduleScreenText groups outstanding vaccines by date',
        (WidgetTester tester) async {
      late String groupedText;
      final dues = <VaccinationDue>[
        VaccinationDue(
          id: 'd1',
          childId: 'c1',
          vaccineCode: 'PENTA',
          doseNumber: 1,
          dueDate: DateTime(2026, 10, 10),
        ),
        VaccinationDue(
          id: 'd2',
          childId: 'c1',
          vaccineCode: 'PCV',
          doseNumber: 1,
          dueDate: DateTime(2026, 10, 10),
        ),
        VaccinationDue(
          id: 'd3',
          childId: 'c1',
          vaccineCode: 'MMR',
          doseNumber: 1,
          dueDate: DateTime(2026, 11, 20),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              groupedText = ScreenSpeechHelper.vaccineScheduleScreenText(
                context: context,
                localizations: AppLocalizations.of(context)!,
                dues: dues,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(
        groupedText,
        contains(
          'PENTA 1 and PCV 1 are due on 10 October 2026.',
        ),
      );
      expect(
        groupedText,
        contains('MMR 1 is due on 20 November 2026.'),
      );
      expect(
        groupedText.split('10 October 2026').length - 1,
        1,
      );
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
      expect(
        enSettings,
        'Settings. Language options: English or Nepali. '
        'Manage profiles: Caregiver profile editing. '
        'Child profiles editing. Delete child profile. '
        "Edit child's vaccination schedule. "
        'This is for healthcare professionals only. '
        'Backup. Export backup. Import backup. '
        'Your records do not move to a new phone by themselves. Before changing phones, export a backup. '
        "Keep this file somewhere safe and only share it with people you trust. It contains your child's health information.",
      );

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
              expect(
                npSettings,
                'सेटिङहरू। भाषा छनोट: हाल नेपाली भाषा चयन गरिएको छ। '
                'प्रोफाइलहरू व्यवस्थापन गर्नुहोस्: हेरचाहकर्ताको प्रोफाइल सम्पादन। '
                'बालबालिकाको प्रोफाइल सम्पादन। बालबालिकाको प्रोफाइल मेटाउनुहोस्। '
                'बच्चाको खोप तालिका सम्पादन गर्नुहोस्। यो स्वास्थ्यकर्मीका लागि मात्र हो। '
                '${l10n.backupSectionTitle}. ${l10n.backupExportAction}. '
                '${l10n.backupImportAction}. ${l10n.backupPhoneChangeNote} '
                '${l10n.backupPrivacyNote}',
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(npSettings, contains('सेटिङहरू'));
      expect(npSettings, contains('ब्याकअप निकाल्नुहोस्'));
      expect(npSettings, contains('तपाईंको बच्चाको स्वास्थ्य जानकारी'));
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

    testWidgets('healthFacilityScreenText formats populated and empty states',
        (WidgetTester tester) async {
      late String enPopulated;
      late String enEmpty;
      late String npPopulated;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              final AppLocalizations l10n = AppLocalizations.of(context)!;
              enPopulated = ScreenSpeechHelper.healthFacilityScreenText(
                context: context,
                localizations: l10n,
                facilityName: 'Kanti Children Hospital',
                facilityAddress: 'Kathmandu',
                facilityPhone: '9841234567',
              );
              enEmpty = ScreenSpeechHelper.healthFacilityScreenText(
                context: context,
                localizations: l10n,
                facilityName: '',
                facilityAddress: '',
                facilityPhone: '',
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(enPopulated, contains('Local health facility details'));
      expect(enPopulated, contains('Name: Kanti Children Hospital'));
      expect(enPopulated, contains('Address: Kathmandu'));
      expect(enPopulated, contains('Phone number: 9 8 4 1 2 3 4 5 6 7'));
      expect(enPopulated, contains('You can edit these details and tap save'));

      expect(enEmpty, contains('Local health facility details'));
      expect(
          enEmpty,
          contains(
              'Please enter your local health facility name, address, and phone number'));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ne'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              final AppLocalizations l10n = AppLocalizations.of(context)!;
              npPopulated = ScreenSpeechHelper.healthFacilityScreenText(
                context: context,
                localizations: l10n,
                facilityName: 'कान्ति बाल अस्पताल',
                facilityAddress: 'काठमाडौँ',
                facilityPhone: '9841234567',
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(npPopulated, contains('स्थानीय स्वास्थ्य संस्थाको विवरण'));
      expect(npPopulated, contains('नाम: कान्ति बाल अस्पताल'));
      expect(npPopulated, contains('ठेगाना: काठमाडौँ'));
      expect(npPopulated, contains('फोन नम्बर: 9 8 4 1 2 3 4 5 6 7'));
    });

    testWidgets(
        'addChildScreenText and caregiverScreenText format simple instructions',
        (WidgetTester tester) async {
      late String enAddChild;
      late String npAddChild;
      late String enCaregiver;
      late String enCaregiverEdit;
      late String enChildEdit;
      late String npCaregiver;
      late String npChildEdit;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              final AppLocalizations l10n = AppLocalizations.of(context)!;
              enAddChild = ScreenSpeechHelper.addChildScreenText(
                context: context,
                localizations: l10n,
                isOnboardingFlow: true,
              );
              enCaregiver = ScreenSpeechHelper.caregiverScreenText(
                context: context,
                localizations: l10n,
                isEditing: false,
              );
              enCaregiverEdit = ScreenSpeechHelper.caregiverScreenText(
                context: context,
                localizations: l10n,
                isEditing: true,
              );
              enChildEdit = ScreenSpeechHelper.childEditScreenText(
                context: context,
                localizations: l10n,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(enAddChild, contains('Add child details'));
      expect(enAddChild,
          contains('full name, date of birth, and select their sex'));
      expect(enAddChild, contains('press save child'));
      expect(enAddChild, isNot(contains('continue')));
      expect(enCaregiver, contains('Caregiver information'));
      expect(enCaregiver, contains('full name, phone number, and address'));
      expect(enCaregiverEdit, contains('Edit caregiver profile'));
      expect(
        enChildEdit,
        'Edit child profile. Please update the child\'s name, date of birth, '
        'or sex, then tap save.',
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ne'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              final AppLocalizations l10n = AppLocalizations.of(context)!;
              npAddChild = ScreenSpeechHelper.addChildScreenText(
                context: context,
                localizations: l10n,
                isOnboardingFlow: false,
              );
              npCaregiver = ScreenSpeechHelper.caregiverScreenText(
                context: context,
                localizations: l10n,
                isEditing: false,
              );
              npChildEdit = ScreenSpeechHelper.childEditScreenText(
                context: context,
                localizations: l10n,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(npAddChild, contains('बच्चाको विवरण दर्ता गर्नुहोस्'));
      expect(npAddChild, contains('पूरा नाम र जन्म मिति'));
      expect(npAddChild, contains('बच्चा सेभ गर्नुहोस्'));
      expect(npCaregiver, contains('अभिभावकको विवरण'));
      expect(npCaregiver, contains('पूरा नाम, फोन नम्बर, र ठेगाना'));
      expect(
        npChildEdit,
        'बच्चाको प्रोफाइल सम्पादन गर्नुहोस्। '
        'कृपया बच्चाको नाम, जन्म मिति, वा लिङ्ग सम्पादन गर्नुहोस्, र सेभ थिच्नुहोस्।',
      );
    });
  });
}
