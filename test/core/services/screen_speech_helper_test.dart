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
      expect(enPopulated, contains('Vaccinations are up to date for: Aarav'));
      expect(enPopulated, contains('Vaccines due today for: Maya'));

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
      expect(
          npPopulated, contains('खोप पूर्ण अवस्थामा रहेका बालबालिका: Aarav'));
      expect(npPopulated, contains('आज खोप लगाउने मिति भएका बालबालिका: Maya'));
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

    testWidgets(
        'settingsScreenText and recordDoseScreenText format instructions',
        (WidgetTester tester) async {
      late String enSettings;
      late String npSettings;
      late String enRecord;
      late String npRecord;

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
              enRecord = ScreenSpeechHelper.recordDoseScreenText(
                context: context,
                localizations: l10n,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(enSettings, contains('Settings'));
      expect(enRecord, contains('Step 1: Select child'));

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
              npRecord = ScreenSpeechHelper.recordDoseScreenText(
                context: context,
                localizations: l10n,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(npSettings, contains('सेटिङहरू'));
      expect(npRecord, contains('चरण १: खोप लगाउने बच्चा छान्नुहोस्'));
    });
  });
}
