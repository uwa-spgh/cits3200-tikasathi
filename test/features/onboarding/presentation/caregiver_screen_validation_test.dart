import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/onboarding/presentation/caregiver_screen.dart';
import 'package:tikasathi/features/onboarding/presentation/child_screen.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CaregiverScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('requires caregiver name before continuing',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(1), '12345');
    final continueButton = find.text('Continue');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pump();

    expect(find.text("Please enter caregiver's name"), findsOneWidget);
    expect(find.byType(CaregiverScreen), findsOneWidget);
  });

  testWidgets('requires caregiver phone before continuing',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), 'Maya');
    final continueButton = find.text('Continue');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pump();

    expect(find.text("Please enter caregiver's phone number"), findsOneWidget);
    expect(find.byType(CaregiverScreen), findsOneWidget);
  });

  testWidgets('rejects invalid caregiver phone values',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), 'Maya');
    await tester.enterText(find.byType(TextField).at(1), '++');
    final continueButton = find.text('Continue');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pump();

    expect(find.text('Please enter a valid phone number'), findsOneWidget);
    expect(find.byType(CaregiverScreen), findsOneWidget);
  });

  testWidgets('accepts a plus-prefixed caregiver phone number',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), 'Maya');
    await tester.enterText(find.byType(TextField).at(1), '+9800000000');
    final continueButton = find.text('Continue');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.byType(CaregiverScreen), findsNothing);
  });

  testWidgets('rejects an 18-plus DOB after completing caregiver step',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), 'Maya');
    await tester.enterText(find.byType(TextField).at(1), '+9800000000');
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(ChildScreen), findsOneWidget);

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
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Child must be under 18 years old'), findsOneWidget);
    expect(find.textContaining('Error saving setup'), findsNothing);
    expect(find.byType(ChildScreen), findsOneWidget);
  });
}
