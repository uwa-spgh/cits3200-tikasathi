import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/features/home/domain/home_models.dart';
import 'package:tikasathi/features/home/presentation/home_screen.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  group('HomeScreen', () {
    const dueTodayChild = HomeChildSummary(
      name: 'Aisha',
      ageLabel: '9 months old',
      vaccineLabel: 'Rotavirus',
      avatarEmoji: '👶',
      canRecordVaccine: true,
      canFindClinic: true,
    );

    const dueSoonChild = HomeChildSummary(
      name: 'Bikash',
      ageLabel: '14 months old',
      vaccineLabel: 'TCV',
      avatarEmoji: '🧒',
      canRecordVaccine: false,
      canFindClinic: true,
    );

    const upToDateChild = HomeChildSummary(
      name: 'Sara',
      ageLabel: '4 years old',
      vaccineLabel: 'DPT',
      avatarEmoji: '👧',
      canRecordVaccine: false,
      canFindClinic: false,
    );

    List<HomeStatusGroup> buildHomeGroups() {
      const List<HomeStatusGroup> homeGroups = <HomeStatusGroup>[
        HomeStatusGroup(
          group: HomeVaccinationGroup.dueToday,
          headerLabel: 'Vaccine due TODAY',
          children: <HomeChildSummary>[dueTodayChild],
        ),
        HomeStatusGroup(
          group: HomeVaccinationGroup.dueSoon,
          headerLabel: 'Due in 2 weeks',
          children: <HomeChildSummary>[dueSoonChild],
        ),
        HomeStatusGroup(
          group: HomeVaccinationGroup.upToDate,
          headerLabel: 'All up to date',
          children: <HomeChildSummary>[upToDateChild],
        ),
      ];
      return homeGroups;
    }

    testWidgets('renders provided child details and status groups',
        (WidgetTester tester) async {
      final groups = buildHomeGroups();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: HomeScreen(groups: groups),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home-title')), findsOneWidget);
      expect(find.text('तपाईंको बच्चाहरू'), findsOneWidget);
      expect(find.byKey(const Key('home-group-dueToday')), findsOneWidget);
      expect(find.byKey(const Key('home-group-dueSoon')), findsOneWidget);
      expect(find.text('Aisha'), findsOneWidget);
      expect(find.text('Bikash'), findsOneWidget);
      expect(find.byKey(const Key('home-add-child-button')), findsOneWidget);
      expect(find.byKey(const Key('record-vaccine-Aisha')), findsOneWidget);
      expect(find.byKey(const Key('find-clinic-Aisha')), findsOneWidget);
      expect(find.byKey(const Key('find-clinic-Bikash')), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('home-group-upToDate')),
        100,
      );
      expect(find.byKey(const Key('home-group-upToDate')), findsOneWidget);
      expect(find.text('Sara'), findsOneWidget);
      expect(find.byKey(const Key('find-clinic-Sara')), findsNothing);
    });

    testWidgets('shows placeholder feedback for action buttons',
        (WidgetTester tester) async {
      final groups = buildHomeGroups();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: HomeScreen(groups: groups),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('home-add-child-button')));
      await tester.pumpAndSettle();
      // The Add child button should open the registration dialog.
      expect(find.byType(AlertDialog), findsOneWidget);

      // Close the dialog so we can interact with the rest of the UI.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('record-vaccine-Aisha')));
      await tester.pumpAndSettle();
      expect(find.text('खोप रेकर्ड is not available yet.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('find-clinic-Aisha')));
      await tester.pumpAndSettle();
      expect(find.text('क्लिनिक खोज्नुहोस् is not available yet.'),
          findsOneWidget);
    });

    testWidgets('renders empty state when no children are available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeScreen(groups: <HomeStatusGroup>[]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home-empty-state')), findsOneWidget);
      expect(find.text('अहिलेसम्म कुनै बच्चा थपिएको छैन।'), findsOneWidget);
      expect(find.byKey(const Key('home-add-child-button')), findsOneWidget);
    });

    testWidgets('renders without layout overflow on narrow screens',
        (WidgetTester tester) async {
      // Narrow viewport
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Pump the HomeScreen with test groups and settle
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: HomeScreen(groups: buildHomeGroups()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Basic assertions
      expect(find.byKey(const Key('home-title')), findsOneWidget);
      expect(find.byKey(const Key('record-vaccine-Aisha')), findsOneWidget);
      expect(find.byKey(const Key('find-clinic-Aisha')), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
