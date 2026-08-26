import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
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
    final bool completed = await controller.finishSetup();

    expect(completed, isTrue);
    expect(repository.language, AppLanguage.nepali);
    verify(secureStorage.setOnboardingCompleted).called(1);
  });

  test('finishSetup stops when language persistence fails', () async {
    final ProviderContainer container = containerWith(
      _FailingSettingsRepository(),
    );
    final OnboardingController controller =
        container.read(onboardingControllerProvider.notifier);

    final bool completed = await controller.finishSetup();

    expect(completed, isFalse);
    expect(container.read(onboardingControllerProvider).error, isNotNull);
    verifyNever(secureStorage.setOnboardingCompleted);
  });
}
