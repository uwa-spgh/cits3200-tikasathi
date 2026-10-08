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
import 'package:tikasathi/features/onboarding/presentation/language_screen.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/vaccine_records/presentation/vaccine_records_screen.dart';

import '../../../helpers/fake_settings_repository.dart';

class _MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  testWidgets('preserves the onboarding draft across the full navigation flow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final secureStorage = _MockSecureStorageService();
    when(
      () => secureStorage.saveCaregiverProfile(
        name: any(named: 'name'),
        phone: any(named: 'phone'),
        address: any(named: 'address'),
      ),
    ).thenAnswer((_) async {});
    when(secureStorage.setOnboardingCompleted).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          secureStorageServiceProvider.overrideWithValue(secureStorage),
          settingsRepositoryProvider.overrideWith(
            (ref) => FakeSettingsRepository(language: AppLanguage.nepali),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LanguageScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Mina');
    await tester.enterText(find.byType(TextField).at(1), '9841234567');
    await tester.enterText(find.byType(TextField).at(2), 'Kathmandu');
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Nima');
    await tester.enterText(find.byType(TextField).at(1), '02');
    await tester.enterText(find.byType(TextField).at(2), '01');
    await tester.enterText(find.byType(TextField).at(3), '2020');
    await tester.tap(find.text('Boy'));
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(VaccineRecordsScreen), findsOneWidget);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    expect(await db.childProfilesDao.getAllChildProfiles(), hasLength(1));
    expect(
      await (db.select(db.vaccinationRecords)).get(),
      isEmpty,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(ChildScreen), findsOneWidget);
    expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text,
        'Nima');
    expect(find.text('Boy'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(CaregiverScreen), findsOneWidget);
    expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text,
        'Mina');
    expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller?.text,
        '9841234567');
    expect(
        tester.widget<TextField>(find.byType(TextField).at(2)).controller?.text,
        'Kathmandu');

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageScreen), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(VaccineRecordsScreen), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isTrue);
    expect(await db.childProfilesDao.getAllChildProfiles(), hasLength(1));
    expect(
      await (db.select(db.vaccinationRecords)).get(),
      isEmpty,
    );
  });
}
