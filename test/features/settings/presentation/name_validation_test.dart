import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:tikasathi/features/onboarding/presentation/caregiver_screen.dart';
import 'package:tikasathi/features/onboarding/presentation/child_screen.dart';
import 'package:tikasathi/features/settings/presentation/caregiver_edit_screen.dart';
import 'package:tikasathi/features/settings/presentation/child_edit_screen.dart';

class _MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  const childId = 'child-name-validation';

  Widget localized(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('onboarding child shows the child invalid-name message',
      (tester) async {
    await tester
        .pumpWidget(localized(const ChildScreen(isOnboardingFlow: false)));
    await tester.pumpAndSettle();
    _setRawText(tester, 0, 'Child2');
    await _enterValidDob(tester);
    final saveChild = find.text('Save child');
    await tester.ensureVisible(saveChild);
    await tester.tap(saveChild);
    await tester.pump();
    expect(find.text("Please enter a valid child's name."), findsOneWidget);
  });

  testWidgets('onboarding caregiver shows the caregiver invalid-name message',
      (tester) async {
    await tester.pumpWidget(localized(const CaregiverScreen()));
    await tester.pumpAndSettle();
    _setRawText(tester, 0, 'Caregiver2');
    await tester.enterText(find.byType(TextField).at(1), '+9800000000');
    final continueButton = find.text('Continue');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pump();
    expect(
      find.text("Please enter a valid caregiver's name."),
      findsOneWidget,
    );
  });

  testWidgets('child edit shows the child invalid-name message',
      (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.childProfilesDao.insertChildProfile(
      ChildProfilesCompanion.insert(
        id: childId,
        name: 'Maya',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365)),
        sex: 'female',
      ),
    );
    await tester.pumpWidget(localized(
      const ChildEditScreen(childId: childId),
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    ));
    await tester.pumpAndSettle();
    _setRawText(tester, 0, 'Child2');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text("Please enter a valid child's name."), findsOneWidget);
  });

  testWidgets('caregiver edit shows the caregiver invalid-name message',
      (tester) async {
    final storage = _MockSecureStorageService();
    when(() => storage.getCaregiverProfile()).thenAnswer(
      (_) async => <String, String?>{
        'name': 'Maya',
        'phone': '+9800000000',
        'address': '',
      },
    );
    await tester.pumpWidget(localized(
      const CaregiverEditScreen(),
      overrides: [secureStorageServiceProvider.overrideWithValue(storage)],
    ));
    await tester.pumpAndSettle();
    _setRawText(tester, 0, 'Caregiver2');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(
      find.text("Please enter a valid caregiver's name."),
      findsOneWidget,
    );
  });
}

Future<void> _enterValidDob(WidgetTester tester) async {
  final date = DateTime.now().subtract(const Duration(days: 365));
  await tester.enterText(find.byType(TextField).at(1), '${date.day}');
  await tester.enterText(find.byType(TextField).at(2), '${date.month}');
  await tester.enterText(find.byType(TextField).at(3), '${date.year}');
}

void _setRawText(WidgetTester tester, int index, String text) {
  tester.widget<TextField>(find.byType(TextField).at(index)).controller!.value =
      TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );
}
