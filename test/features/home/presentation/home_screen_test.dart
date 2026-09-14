import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/home/domain/home_models.dart';
import 'package:tikasathi/features/home/domain/home_helpers.dart';
import 'package:tikasathi/features/home/presentation/home_screen.dart';
import 'package:tikasathi/features/onboarding/presentation/child_screen.dart';
import 'package:tikasathi/features/settings/domain/health_facilitator_controller.dart';
import 'package:tikasathi/features/settings/presentation/health_facilitator_screen.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  group('HomeScreen', () {
    HomeChildSummary buildChild({
      required String name,
      required DateTime dateOfBirth,
      required String nextVaccineCode,
      required bool canRecordDose,
      String sex = 'female',
    }) {
      return HomeChildSummary(
        name: name,
        childId: name.toLowerCase(),
        dateOfBirth: dateOfBirth,
        nextVaccineCode: nextVaccineCode,
        sex: sex,
        avatarEmoji: '👶',
        canRecordDose: canRecordDose,
      );
    }

    List<HomeStatusGroup> buildHomeGroups() {
      final DateTime now = DateTime.now();
      final HomeChildSummary dueTodayChild = buildChild(
        name: 'Aisha',
        dateOfBirth: now.subtract(const Duration(days: 12)),
        nextVaccineCode: 'Rotavirus',
        canRecordDose: true,
        sex: 'male',
      );
      final HomeChildSummary dueSoonChild = buildChild(
        name: 'Bikash',
        dateOfBirth: now.subtract(const Duration(days: 45)),
        nextVaccineCode: 'TCV',
        canRecordDose: false,
      );
      final HomeChildSummary upToDateChild = buildChild(
        name: 'Sara',
        dateOfBirth: now.subtract(const Duration(days: 1460)),
        nextVaccineCode: 'DPT',
        canRecordDose: false,
      );

      return <HomeStatusGroup>[
        HomeStatusGroup(
          group: HomeVaccinationGroup.dueToday,
          children: <HomeChildSummary>[dueTodayChild],
        ),
        HomeStatusGroup(
          group: HomeVaccinationGroup.dueSoon,
          children: <HomeChildSummary>[dueSoonChild],
        ),
        HomeStatusGroup(
          group: HomeVaccinationGroup.upToDate,
          children: <HomeChildSummary>[upToDateChild],
        ),
      ];
    }

    testWidgets('renders localized age text for English and Nepali locales',
        (WidgetTester tester) async {
      final groups = buildHomeGroups();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
            healthFacilitatorProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: HomeScreen(groups: groups)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final englishLocalizations = AppLocalizations.of(
        tester.element(find.text('Aisha')),
      )!;
      final expectedEnglishAge =
          formatAge(groups[0].children.first.dateOfBirth, englishLocalizations);
      expect(find.text('Aisha'), findsOneWidget);
      expect(find.textContaining(expectedEnglishAge), findsOneWidget);
      expect(find.textContaining('Male'), findsOneWidget);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
            healthFacilitatorProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('ne'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: HomeScreen(groups: groups)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nepaliLocalizations = AppLocalizations.of(
        tester.element(find.text('Aisha')),
      )!;
      final expectedNepaliAge =
          formatAge(groups[0].children.first.dateOfBirth, nepaliLocalizations);
      expect(find.textContaining(expectedNepaliAge), findsOneWidget);
      expect(find.text('तपाईंको बच्चाहरू'), findsOneWidget);
    });

    testWidgets(
        'onboarding child screen keeps the onboarding header and action',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChildScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final AppLocalizations localizations =
          AppLocalizations.of(tester.element(find.byType(ChildScreen)))!;
      expect(
          find.text(localizations.onboardingStepLabel(2, 3)), findsOneWidget);
      expect(find.text(localizations.onboardingContinue), findsOneWidget);
      expect(find.text('Add a new child'), findsNothing);
      expect(find.text('Save child'), findsNothing);
    });

    testWidgets('home add child page shows the home-specific heading',
        (WidgetTester tester) async {
      final groups = buildHomeGroups();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
            healthFacilitatorProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: HomeScreen(
                groups: groups,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('home-add-child-button')));
      await tester.pumpAndSettle();

      expect(find.byType(ChildScreen), findsOneWidget);
      expect(find.text('Add a new child'), findsOneWidget);
      expect(find.text('Save child'), findsOneWidget);
    });

    testWidgets('shows record dose action and unsaved facilitator card',
        (WidgetTester tester) async {
      final groups = buildHomeGroups();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
            healthFacilitatorProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('ne'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: HomeScreen(groups: groups)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('record-dose-Aisha')), findsOneWidget);
      expect(find.text('खोप दर्ता गर्नुहोस्'), findsAtLeastNWidgets(1));
      await tester.drag(
        find.byType(ListView).first,
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home-health-facilitator-card')),
          findsOneWidget);
      expect(
        find.text('आफ्नो नजिकको स्वास्थ्य संस्था बचत गर्नुहोस्'),
        findsOneWidget,
      );
    });

    testWidgets('renders empty state when no children are available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
            healthFacilitatorProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('ne'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: HomeScreen(groups: <HomeStatusGroup>[])),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home-empty-state')), findsOneWidget);
      expect(find.text('अहिलेसम्म कुनै बच्चा थपिएको छैन।'), findsOneWidget);
      expect(find.byKey(const Key('home-add-child-button')), findsOneWidget);
    });

    testWidgets('displays saved facilitator details and opens edit screen',
        (WidgetTester tester) async {
      const facilitator = HealthFacilitator(
        id: 'local',
        name: 'Maya Health Post',
        address: 'Main Street',
        phone: '555-0100',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
            healthFacilitatorProvider.overrideWith(
              (ref) => Stream.value(facilitator),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: HomeScreen(groups: buildHomeGroups()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(ListView).first,
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your local health facility'), findsOneWidget);
      expect(find.textContaining('Facility Name: Maya Health Post'),
          findsOneWidget);
      expect(find.textContaining('Address: Main Street'), findsOneWidget);
      expect(find.textContaining('Phone Number: 555-0100'), findsOneWidget);
      expect(
        tester
            .getTopLeft(find.byKey(const Key('home-health-facilitator-card')))
            .dy,
        greaterThan(
          tester.getBottomLeft(find.byKey(const Key('home-group-upToDate'))).dy,
        ),
      );

      await tester.tap(find.byKey(const Key('home-health-facilitator-card')));
      await tester.pumpAndSettle();

      expect(find.byType(HealthFacilitatorScreen), findsOneWidget);
      expect(find.text('Maya Health Post'), findsOneWidget);
      expect(find.text('Main Street'), findsOneWidget);
      expect(find.text('555-0100'), findsOneWidget);
    });

    testWidgets('shows facilitator setup card when none is saved',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
            healthFacilitatorProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: HomeScreen(groups: buildHomeGroups()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(ListView).first,
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home-health-facilitator-card')),
          findsOneWidget);
      expect(find.text('Save your closest health facility'), findsOneWidget);
      expect(
        tester
            .getTopLeft(find.byKey(const Key('home-health-facilitator-card')))
            .dy,
        greaterThan(
          tester.getBottomLeft(find.byKey(const Key('home-group-upToDate'))).dy,
        ),
      );
      await tester.tap(find.byKey(const Key('home-health-facilitator-card')));
      await tester.pumpAndSettle();

      expect(find.byType(HealthFacilitatorScreen), findsOneWidget);
      expect(find.text('Enter the facility\'s name'), findsOneWidget);
    });

    testWidgets('renders without layout overflow on narrow screens',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
            healthFacilitatorProvider.overrideWith(
              (ref) => Stream.value(null),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('ne'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: HomeScreen(groups: buildHomeGroups())),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home-title')), findsOneWidget);
      await tester.drag(
        find.byType(ListView).first,
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('record-dose-Aisha')), findsOneWidget);
      expect(find.byKey(const Key('home-health-facilitator-card')),
          findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
