import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
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
      expect(enText, isNot(contains('Completed vaccines')));

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
      expect(npText, isNot(contains('लागेका खोपहरू')));
    });

    testWidgets(
        'childProfileScreenText handles overdue, today, and future vaccines',
        (WidgetTester tester) async {
      final DateTime now = DateTime(2025, 6, 1);
      final ChildProfile child = ChildProfile(
        id: 'status-child',
        name: 'Maya',
        dateOfBirth: DateTime(2025, 5, 10),
        sex: 'Female',
        isSetupComplete: true,
      );

      ChildProfileDetails detailsFor(
        List<VaccinationDue> dueVaccines,
      ) {
        return ChildProfileDetails(
          child: child,
          dueVaccines: dueVaccines,
          records: const <VaccinationRecord>[],
          now: now,
        );
      }

      String buildText(
        BuildContext context,
        ChildProfileDetails details,
      ) {
        return ScreenSpeechHelper.childProfileScreenText(
          context: context,
          localizations: AppLocalizations.of(context)!,
          details: details,
        );
      }

      late String overdueEnglish;
      late String todayEnglish;
      late String futureEnglish;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              overdueEnglish = buildText(
                context,
                detailsFor(<VaccinationDue>[
                  VaccinationDue(
                    id: 'overdue',
                    childId: child.id,
                    vaccineCode: 'BCG',
                    doseNumber: 1,
                    dueDate: DateTime(2025, 5, 20),
                  ),
                  VaccinationDue(
                    id: 'future',
                    childId: child.id,
                    vaccineCode: 'Penta 1',
                    doseNumber: 1,
                    dueDate: DateTime(2025, 6, 21),
                  ),
                ]),
              );
              todayEnglish = buildText(
                context,
                detailsFor(<VaccinationDue>[
                  VaccinationDue(
                    id: 'today',
                    childId: child.id,
                    vaccineCode: 'BCG',
                    doseNumber: 1,
                    dueDate: now,
                  ),
                ]),
              );
              futureEnglish = buildText(
                context,
                detailsFor(<VaccinationDue>[
                  VaccinationDue(
                    id: 'future-only',
                    childId: child.id,
                    vaccineCode: 'Penta 1',
                    doseNumber: 1,
                    dueDate: DateTime(2025, 6, 21),
                  ),
                ]),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(
        overdueEnglish,
        contains('Overdue since 20 May 2025'),
      );
      expect(
        overdueEnglish,
        contains(
          'Please visit your nearest health facility for advice on missed vaccines.',
        ),
      );
      expect(overdueEnglish, isNot(contains('Completed vaccines')));
      expect(todayEnglish, contains('Vaccines are due today for Maya: BCG.'));
      expect(todayEnglish, isNot(contains('Overdue since')));
      expect(todayEnglish, isNot(contains('health facility')));
      expect(
        futureEnglish,
        contains('due on 21 June 2025'),
      );
      expect(futureEnglish, isNot(contains('Overdue since')));
      expect(futureEnglish, isNot(contains('health facility')));

      late String overdueNepali;
      late String todayNepali;
      late String futureNepali;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ne'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              overdueNepali = buildText(
                context,
                detailsFor(<VaccinationDue>[
                  VaccinationDue(
                    id: 'overdue-ne',
                    childId: child.id,
                    vaccineCode: 'BCG',
                    doseNumber: 1,
                    dueDate: DateTime(2025, 5, 20),
                  ),
                ]),
              );
              todayNepali = buildText(
                context,
                detailsFor(<VaccinationDue>[
                  VaccinationDue(
                    id: 'today-ne',
                    childId: child.id,
                    vaccineCode: 'BCG',
                    doseNumber: 1,
                    dueDate: now,
                  ),
                ]),
              );
              futureNepali = buildText(
                context,
                detailsFor(<VaccinationDue>[
                  VaccinationDue(
                    id: 'future-ne',
                    childId: child.id,
                    vaccineCode: 'Penta 1',
                    doseNumber: 1,
                    dueDate: DateTime(2025, 6, 21),
                  ),
                ]),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(overdueNepali, contains('देखि ढिलो'));
      expect(
        overdueNepali,
        contains(
            'छुटेका खोपबारे सल्लाह लिन कृपया आफ्नो नजिकको स्वास्थ्य संस्थामा जानुहोस्।'),
      );
      expect(overdueNepali, isNot(contains('लागेका खोपहरू')));
      expect(todayNepali, contains('आज Mayaको खोप लगाउने मिति हो: BCG।'));
      expect(todayNepali, isNot(contains('देखि ढिलो')));
      expect(todayNepali, isNot(contains('स्वास्थ्य संस्था')));
      expect(futureNepali, contains('मिति: २१ जुन २०२५'));
      expect(futureNepali, isNot(contains('देखि ढिलो')));
      expect(futureNepali, isNot(contains('स्वास्थ्य संस्था')));
    });

    testWidgets('childProfileScreenText localizes incomplete setup speech',
        (WidgetTester tester) async {
      final ChildProfileDetails details = ChildProfileDetails(
        child: ChildProfile(
          id: 'incomplete',
          name: 'Nima',
          dateOfBirth: DateTime(2025, 5, 10),
          sex: 'Male',
          isSetupComplete: false,
        ),
        dueVaccines: const <VaccinationDue>[],
        records: const <VaccinationRecord>[],
        now: DateTime(2025, 6, 1),
      );

      late String enText;
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

      expect(
        enText,
        "Nima's past vaccine history hasn't been set up yet. "
        'Please complete the setup to get an accurate vaccination schedule.',
      );
      expect(enText, isNot(contains('Setup is pending')));

      late String npText;
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

      expect(
        npText,
        'Nimaको पहिले लगाइएका खोपहरूको इतिहास सेटअप गरिएको छैन। '
        'सही खोप तालिका प्राप्त गर्न कृपया सेटअप पूरा गर्नुहोस्।',
      );
      expect(npText, contains('Nima'));
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
      late String groupedNepaliText;
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final dues = <VaccinationDue>[
        VaccinationDue(
          id: 'd1',
          childId: 'c1',
          vaccineCode: 'PENTA',
          doseNumber: 1,
          dueDate: today.subtract(const Duration(days: 1)),
        ),
        VaccinationDue(
          id: 'd2',
          childId: 'c1',
          vaccineCode: 'PCV',
          doseNumber: 1,
          dueDate: today.subtract(const Duration(days: 1)),
        ),
        VaccinationDue(
          id: 'd3',
          childId: 'c1',
          vaccineCode: 'MMR',
          doseNumber: 1,
          dueDate: today,
        ),
        VaccinationDue(
          id: 'd4',
          childId: 'c1',
          vaccineCode: 'BCG',
          doseNumber: 1,
          dueDate: today.add(const Duration(days: 1)),
        ),
        VaccinationDue(
          id: 'd5',
          childId: 'c1',
          vaccineCode: 'OPV',
          doseNumber: 1,
          dueDate: today.add(const Duration(days: 1)),
        ),
      ];
      final records = <VaccinationRecord>[
        VaccinationRecord(
          id: 'r1',
          childId: 'c1',
          vaccineCode: 'BCG',
          doseNumber: 1,
          administeredDate: DateTime(2025, 1, 1),
        ),
        VaccinationRecord(
          id: 'r2',
          childId: 'c1',
          vaccineCode: 'PENTA',
          doseNumber: 1,
          administeredDate: DateTime(2025, 1, 1),
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
                records: records,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(
        groupedText,
        contains(
          'PENTA 1 and PCV 1 are overdue since',
        ),
      );
      expect(
        groupedText,
        contains(
          'Please visit your nearest health facility for advice on missed vaccines.',
        ),
      );
      expect(
        groupedText,
        contains('MMR 1 is due today.'),
      );
      expect(groupedText, contains('BCG and OPV 1 are due on'));
      expect(groupedText, contains('Administered vaccines.'));
      expect(groupedText, contains('Missed vaccines.'));
      expect(groupedText, contains('Upcoming vaccines.'));
      expect(groupedText, contains('BCG and PENTA 1 were given on'));
      expect(
        groupedText.indexOf('Administered vaccines.'),
        lessThan(groupedText.indexOf('Missed vaccines.')),
      );
      expect(
        groupedText.indexOf('Missed vaccines.'),
        lessThan(groupedText.indexOf('Upcoming vaccines.')),
      );
      expect(
        groupedText.indexOf(
          'Please visit your nearest health facility for advice on missed vaccines.',
        ),
        lessThan(groupedText.indexOf('Upcoming vaccines.')),
      );
      expect(
        groupedText
                .split(DateFormat('d MMMM y', 'en')
                    .format(today.add(const Duration(days: 1))))
                .length -
            1,
        1,
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ne'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              groupedNepaliText = ScreenSpeechHelper.vaccineScheduleScreenText(
                context: context,
                localizations: AppLocalizations.of(context)!,
                dues: dues,
                records: records,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(groupedNepaliText, contains('लगाइएका खोपहरू।'));
      expect(groupedNepaliText, contains('छुटेका खोपहरू।'));
      expect(groupedNepaliText, contains('आगामी खोपहरू।'));
      expect(groupedNepaliText, contains('PENTA 1 र PCV 1'));
      expect(groupedNepaliText, contains('आज लगाउनुपर्नेछ'));
      expect(
        groupedNepaliText,
        contains(
            'छुटेका खोपबारे सल्लाह लिन कृपया आफ्नो नजिकको स्वास्थ्य संस्थामा जानुहोस्।'),
      );

      late String noMissedText;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              noMissedText = ScreenSpeechHelper.vaccineScheduleScreenText(
                context: context,
                localizations: AppLocalizations.of(context)!,
                dues: dues.where((VaccinationDue due) {
                  return !due.dueDate.isBefore(today);
                }).toList(),
                records: records,
              );
              return const SizedBox();
            },
          ),
        ),
      );
      expect(noMissedText, isNot(contains('Missed vaccines.')));
      expect(
        noMissedText,
        isNot(contains('Please visit your nearest health facility')),
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
      late String enUpToDate;
      late String enEmptyAgeAppropriate;
      late String enFullEmpty;
      late String enFullComplete;
      late String npUpToDate;
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
                recordedVaccineNames: const <String>['BCG'],
                unrecordedVaccineNames: const <String>['Penta dose 1'],
                isUpToDate: false,
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
                recordedVaccineNames: const <String>['BCG'],
                unrecordedVaccineNames: const <String>['Penta dose 1'],
                isUpToDate: false,
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
                recordedVaccineNames: const <String>['BCG'],
                unrecordedVaccineNames: const <String>['Penta dose 1'],
                isUpToDate: false,
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
                recordedVaccineNames: const <String>['BCG'],
                unrecordedVaccineNames: const <String>['Penta dose 1'],
                isUpToDate: false,
              );
              enUpToDate = ScreenSpeechHelper.vaccineRecordsScreenText(
                context: context,
                localizations: l10n,
                childName: 'Maya',
                isRegistrationFlow: false,
                showAllVaccines: false,
                visibleVaccineNames: const <String>[],
                tickedVaccineNames: const <String>[],
                records: records,
                dues: const <VaccinationDue>[],
                recordedVaccineNames: const <String>[
                  'BCG',
                  'Penta dose 1',
                ],
                isUpToDate: true,
              );
              enEmptyAgeAppropriate =
                  ScreenSpeechHelper.vaccineRecordsScreenText(
                context: context,
                localizations: l10n,
                childName: 'Maya',
                isRegistrationFlow: false,
                showAllVaccines: false,
                visibleVaccineNames: const <String>[],
                tickedVaccineNames: const <String>[],
                records: const <VaccinationRecord>[],
                dues: dues,
                unrecordedVaccineNames: const <String>['BCG'],
                isUpToDate: false,
              );
              enFullEmpty = ScreenSpeechHelper.vaccineRecordsScreenText(
                context: context,
                localizations: l10n,
                childName: 'Maya',
                isRegistrationFlow: false,
                showAllVaccines: true,
                visibleVaccineNames: const <String>[],
                tickedVaccineNames: const <String>[],
                records: const <VaccinationRecord>[],
                dues: const <VaccinationDue>[],
              );
              enFullComplete = ScreenSpeechHelper.vaccineRecordsScreenText(
                context: context,
                localizations: l10n,
                childName: 'Maya',
                isRegistrationFlow: false,
                showAllVaccines: true,
                visibleVaccineNames: const <String>[],
                tickedVaccineNames: const <String>[],
                records: records,
                dues: const <VaccinationDue>[],
                recordedVaccineNames: const <String>['BCG'],
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
      expect(
        enHistoryAgeAppropriate,
        contains(
          'Maya has these age-appropriate vaccines recorded as received: BCG.',
        ),
      );
      expect(
        enHistoryAgeAppropriate,
        contains(
          'These age-appropriate vaccines have not been recorded as received: Penta dose 1.',
        ),
      );
      expect(
        enHistoryAgeAppropriate,
        isNot(contains('Upcoming vaccines')),
      );

      // Child page history: all vaccines selected -> reads upcoming vaccines
      expect(enHistoryAll, contains("Maya's full vaccine history is shown."));
      expect(
        enHistoryAll,
        contains('Vaccines recorded as received include BCG.'),
      );
      expect(
        enHistoryAll,
        contains('Other vaccines have not been recorded as received.'),
      );
      expect(enHistoryAll, isNot(contains('Penta dose 1')));
      expect(
        enUpToDate,
        "Maya has received all age-appropriate vaccines. "
        "These include BCG and Penta dose 1. "
        "You can untick a vaccine if it was selected by mistake, or edit the vaccination date if the recorded date is incorrect.",
      );
      expect(
        enEmptyAgeAppropriate,
        contains(
          'No age-appropriate vaccines have been recorded as received for Maya yet.',
        ),
      );
      expect(
        enEmptyAgeAppropriate,
        contains(
            'These age-appropriate vaccines have not been recorded as received: BCG.'),
      );
      expect(enEmptyAgeAppropriate,
          contains('Please visit your nearest health facility'));
      expect(enEmptyAgeAppropriate, isNot(contains('2025')));
      expect(
        enFullEmpty,
        "Maya's full vaccine history is shown. No vaccines have been recorded as received yet. "
        "You can tick vaccines that have already been given, untick vaccines selected by mistake, or edit the vaccination date of a vaccine that is already ticked.",
      );
      expect(enFullComplete, contains("Maya's full vaccine history is shown."));
      expect(enFullComplete,
          contains('Vaccines recorded as received include BCG.'));
      expect(enFullComplete, isNot(contains('Other vaccines')));
      expect(enFullComplete, isNot(contains('Some may be scheduled')));

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
              npUpToDate = ScreenSpeechHelper.vaccineRecordsScreenText(
                context: context,
                localizations: l10n,
                childName: 'Maya',
                isRegistrationFlow: false,
                showAllVaccines: false,
                visibleVaccineNames: const <String>[],
                tickedVaccineNames: const <String>[],
                records: records,
                dues: const <VaccinationDue>[],
                recordedVaccineNames: const <String>['BCG'],
                isUpToDate: true,
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
      expect(npUpToDate, contains('उमेरअनुसारका सबै खोप लगाइएको छ'));
      expect(npUpToDate, contains('यी खोपहरू समावेश छन्: BCG'));
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
