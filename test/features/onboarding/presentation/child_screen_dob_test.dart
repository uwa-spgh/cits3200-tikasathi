import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/onboarding/presentation/child_screen.dart';

void main() {
  group('ChildScreen DOB validation', () {
    testWidgets('rejects future Date of Birth with localized error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChildScreen(isOnboardingFlow: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(find.byType(TextField).at(0), 'Aarav');

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await tester.enterText(
        find.byType(TextField).at(1),
        tomorrow.day.toString(),
      );
      await tester.enterText(
        find.byType(TextField).at(2),
        tomorrow.month.toString(),
      );
      await tester.enterText(
        find.byType(TextField).at(3),
        tomorrow.year.toString(),
      );

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Tap Save child button
      final saveBtn = find.text('Save child');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(
          find.text('Date of Birth cannot be in the future'), findsOneWidget);
    });

    testWidgets('rejects negative date components',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChildScreen(isOnboardingFlow: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Aarav');
      await tester.enterText(find.byType(TextField).at(1), '-1');
      await tester.enterText(find.byType(TextField).at(2), '-1');
      await tester.enterText(find.byType(TextField).at(3), '-100');

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final saveBtn = find.text('Save child');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid Date of Birth'), findsOneWidget);
    });

    testWidgets('rejects a child who is 18 or older',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChildScreen(isOnboardingFlow: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final eighteenthBirthday = DateTime(now.year - 18, now.month, now.day);
      await tester.enterText(find.byType(TextField).at(0), 'Aarav');
      await tester.enterText(
        find.byType(TextField).at(1),
        eighteenthBirthday.day.toString(),
      );
      await tester.enterText(
        find.byType(TextField).at(2),
        eighteenthBirthday.month.toString(),
      );
      await tester.enterText(
        find.byType(TextField).at(3),
        eighteenthBirthday.year.toString(),
      );

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final saveBtn = find.text('Save child');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Child must be under 18 years old'), findsOneWidget);
    });

    testWidgets('allows an under-18 DOB through the save flow',
        (WidgetTester tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChildScreen(isOnboardingFlow: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Aarav');
      final birthday = DateTime.now();
      final under18Birthday =
          DateTime(birthday.year - 17, birthday.month, birthday.day);
      await tester.enterText(
        find.byType(TextField).at(1),
        under18Birthday.day.toString(),
      );
      await tester.enterText(
        find.byType(TextField).at(2),
        under18Birthday.month.toString(),
      );
      await tester.enterText(
        find.byType(TextField).at(3),
        under18Birthday.year.toString(),
      );

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final saveButton = find.text('Save child');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Child must be under 18 years old'), findsNothing);
      expect(
        await database.childProfilesDao.getAllChildProfiles(),
        hasLength(1),
      );
    });

    testWidgets('rejects an 18-year-old during the actual onboarding submit',
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

      final now = DateTime.now();
      final eighteenthBirthday = DateTime(now.year - 18, now.month, now.day);
      await tester.enterText(find.byType(TextField).at(0), 'Aarav');
      await tester.enterText(
        find.byType(TextField).at(1),
        eighteenthBirthday.day.toString(),
      );
      await tester.enterText(
        find.byType(TextField).at(2),
        eighteenthBirthday.month.toString(),
      );
      await tester.enterText(
        find.byType(TextField).at(3),
        eighteenthBirthday.year.toString(),
      );

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final continueButton = find.text('Continue');
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(find.text('Child must be under 18 years old'), findsOneWidget);
      expect(find.textContaining('Error saving setup'), findsNothing);
      expect(find.byType(ChildScreen), findsOneWidget);
    });
  });
}
