import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/onboarding/domain/onboarding_state.dart';
import 'package:tikasathi/features/onboarding/presentation/caregiver_screen.dart';
import 'package:tikasathi/features/onboarding/presentation/child_screen.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

void main() {
  testWidgets('restores caregiver fields from onboarding draft',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(onboardingControllerProvider.notifier).updateCaregiverInfo(
          name: 'Mina',
          phone: '9841234567',
          address: 'Kathmandu',
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CaregiverScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text,
        'Mina');
    expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller?.text,
        '9841234567');
    expect(
        tester.widget<TextField>(find.byType(TextField).at(2)).controller?.text,
        'Kathmandu');
  });

  testWidgets('restores child fields from onboarding draft',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(onboardingControllerProvider.notifier).updateChildInfo(
          name: 'Nima',
          dob: DateTime(2020, 1, 2),
          sex: 'male',
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChildScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text,
        'Nima');
    expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller?.text,
        '02');
    expect(
        tester.widget<TextField>(find.byType(TextField).at(2)).controller?.text,
        '01');
    expect(
        tester.widget<TextField>(find.byType(TextField).at(3)).controller?.text,
        '2020');
    expect(find.text('Boy'), findsOneWidget);
  });

  test('language selection remains in onboarding draft', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(onboardingControllerProvider.notifier);

    controller.updateLanguage(AppLanguage.english);

    expect(
      container.read(onboardingControllerProvider).selectedLanguage,
      AppLanguage.english,
    );
  });
}
