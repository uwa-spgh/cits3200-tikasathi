import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/home/domain/home_models.dart';
import 'package:tikasathi/features/home/presentation/home_screen.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';

import '../../../helpers/fake_settings_repository.dart';

import 'package:tikasathi/features/home/domain/home_helpers.dart';

void main() {
  group('HomeScreen', () {
    HomeChildSummary buildChild({
      required String name,
      required DateTime dateOfBirth,
      required String nextVaccineCode,
      required bool canRecordVaccine,
      required bool canFindClinic,
    }) {
      return HomeChildSummary(
        name: name,
        childId: name.toLowerCase(),
        dateOfBirth: dateOfBirth,
        nextVaccineCode: nextVaccineCode,
        avatarEmoji: '👶',
        canRecordVaccine: canRecordVaccine,
        canFindClinic: canFindClinic,
      );
    }

    List<HomeStatusGroup> buildHomeGroups() {
      final DateTime now = DateTime.now();
      final HomeChildSummary dueTodayChild = buildChild(
        name: 'Aisha',
        dateOfBirth: now.subtract(const Duration(days: 12)),
        nextVaccineCode: 'Rotavirus',
        canRecordVaccine: true,
        canFindClinic: true,
      );
      final HomeChildSummary dueSoonChild = buildChild(
        name: 'Bikash',
        dateOfBirth: now.subtract(const Duration(days: 45)),
        nextVaccineCode: 'TCV',
        canRecordVaccine: false,
        canFindClinic: true,
      );
      final HomeChildSummary upToDateChild = buildChild(
        name: 'Sara',
        dateOfBirth: now.subtract(const Duration(days: 1460)),
        nextVaccineCode: 'DPT',
        canRecordVaccine: false,
        canFindClinic: false,
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
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
            locale: const Locale('ne'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: HomeScreen(groups: groups)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('home-add-child-button')));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('record-vaccine-Aisha')));
      await tester.pumpAndSettle();
      expect(find.text('स्थगित कार्य: खोप रेकर्ड'), findsOneWidget);

      await tester.tap(find.byKey(const Key('find-clinic-Aisha')));
      await tester.pumpAndSettle();
      expect(find.text('स्थगित कार्य: क्लिनिक खोज्नुहोस्'), findsOneWidget);
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
      expect(find.byKey(const Key('record-vaccine-Aisha')), findsOneWidget);
      expect(find.byKey(const Key('find-clinic-Aisha')), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
