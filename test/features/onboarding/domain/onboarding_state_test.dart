import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/native.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:tikasathi/features/home/domain/home_helpers.dart';
import 'package:tikasathi/features/onboarding/domain/onboarding_state.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/settings_repository.dart';

import '../../../helpers/fake_settings_repository.dart';

class _MockSecureStorageService extends Mock implements SecureStorageService {}

final class _FailingSettingsRepository implements SettingsRepository {
  @override
  Future<AppLanguage> getLanguage() async => AppLanguage.nepali;

  @override
  Future<void> setLanguage(AppLanguage language) async {
    throw Exception('write failed');
  }
}

void main() {
  late _MockSecureStorageService secureStorage;

  setUp(() {
    secureStorage = _MockSecureStorageService();
    when(
      () => secureStorage.saveCaregiverProfile(
        name: any(named: 'name'),
        phone: any(named: 'phone'),
        address: any(named: 'address'),
      ),
    ).thenAnswer((_) async {});
    when(secureStorage.setOnboardingCompleted).thenAnswer((_) async {});
  });

  ProviderContainer containerWith(SettingsRepository repository) {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        secureStorageServiceProvider.overrideWithValue(secureStorage),
        settingsRepositoryProvider.overrideWith((ref) => repository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('finishSetup persists language through SettingsRepository', () async {
    final FakeSettingsRepository repository = FakeSettingsRepository(
      language: AppLanguage.english,
    );
    final ProviderContainer container = containerWith(repository);
    final OnboardingController controller =
        container.read(onboardingControllerProvider.notifier);

    controller.updateLanguage(AppLanguage.nepali);
    final String? success = await controller.finishSetup();

    expect(success, isNotNull);
    expect(repository.language, AppLanguage.nepali);
    verify(secureStorage.setOnboardingCompleted).called(1);
  });

  test('finishSetup stops when language persistence fails', () async {
    final ProviderContainer container = containerWith(
      _FailingSettingsRepository(),
    );
    final OnboardingController controller =
        container.read(onboardingControllerProvider.notifier);

    final String? success = await controller.finishSetup();

    expect(success, isNull);
    expect(container.read(onboardingControllerProvider).error, isNotNull);
    verifyNever(secureStorage.setOnboardingCompleted);
  });

  test('finishSetup persists the selected boy value and avatar mapping',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(database),
        secureStorageServiceProvider.overrideWithValue(secureStorage),
        settingsRepositoryProvider.overrideWith(
          (ref) => FakeSettingsRepository(language: AppLanguage.english),
        ),
      ],
    );
    addTearDown(container.dispose);

    final OnboardingController controller =
        container.read(onboardingControllerProvider.notifier);
    controller.updateChildInfo(
      name: 'Nima',
      dob: DateTime(2020),
      sex: 'Boy',
    );

    final String? childId = await controller.finishSetup();
    final ChildProfile? profile =
        await database.childProfilesDao.getChildProfileById(childId!);

    expect(profile?.sex, 'Boy');
    expect(childSexFromString(profile?.sex), ChildSex.male);
    expect(
      getChildAvatar(
        sex: childSexFromString(profile?.sex),
        dateOfBirth: profile!.dateOfBirth,
      ),
      '👦',
    );
  });
}
