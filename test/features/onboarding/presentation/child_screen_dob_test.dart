import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

      // Enter future date (e.g. year 2099)
      await tester.enterText(find.byType(TextField).at(1), '15');
      await tester.enterText(find.byType(TextField).at(2), '09');
      await tester.enterText(find.byType(TextField).at(3), '2099');

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Tap Save child button
      final saveBtn = find.text('Save child');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify SnackBar with future DOB error is displayed
      expect(
          find.text('Date of Birth cannot be in the future'), findsOneWidget);
    });
  });
}
