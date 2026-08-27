import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';
import 'package:tikasathi/features/settings/domain/settings_repository.dart';

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository({
    AppLanguage language = AppLanguage.english,
    this.readError,
    this.writeError,
  }) : _language = language;

  AppLanguage _language;
  final Exception? readError;
  final Exception? writeError;

  @override
  Future<AppLanguage> getLanguage() async {
    final Exception? error = readError;
    if (error != null) {
      throw error;
    }
    return _language;
  }

  @override
  Future<void> setLanguage(AppLanguage language) async {
    final Exception? error = writeError;
    if (error != null) {
      throw error;
    }
    _language = language;
  }
}

void main() {
  ProviderContainer containerWith(_FakeSettingsRepository repository) {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        settingsRepositoryProvider.overrideWith((ref) => repository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('LanguageController', () {
    test('loads language from the repository', () async {
      final ProviderContainer container = containerWith(
        _FakeSettingsRepository(language: AppLanguage.nepali),
      );

      final AppLanguage language =
          await container.read(languageControllerProvider.future);

      expect(language, AppLanguage.nepali);
    });

    test('setLanguage persists and notifies watchers', () async {
      final _FakeSettingsRepository repository = _FakeSettingsRepository();
      final ProviderContainer container = containerWith(repository);
      final List<AppLanguage> seen = <AppLanguage>[];

      container.listen<AsyncValue<AppLanguage>>(
        languageControllerProvider,
        (AsyncValue<AppLanguage>? previous, AsyncValue<AppLanguage> next) {
          next.whenData(seen.add);
        },
        fireImmediately: true,
      );

      await container.read(languageControllerProvider.future);
      final bool saved = await container
          .read(languageControllerProvider.notifier)
          .setLanguage(AppLanguage.nepali);

      expect(saved, isTrue);
      expect(await repository.getLanguage(), AppLanguage.nepali);
      expect(
        container.read(languageControllerProvider).requireValue,
        AppLanguage.nepali,
      );
      expect(seen, <AppLanguage>[AppLanguage.english, AppLanguage.nepali]);
    });

    test('surfaces a read error as AsyncError', () async {
      final ProviderContainer container = containerWith(
        _FakeSettingsRepository(readError: Exception('read failed')),
      );

      await expectLater(
        container.read(languageControllerProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(languageControllerProvider).hasError, isTrue);
    });

    test('keeps the loaded language when persist fails', () async {
      final ProviderContainer container = containerWith(
        _FakeSettingsRepository(writeError: Exception('write failed')),
      );

      await container.read(languageControllerProvider.future);
      final bool saved = await container
          .read(languageControllerProvider.notifier)
          .setLanguage(AppLanguage.nepali);

      expect(saved, isFalse);
      expect(container.read(languageControllerProvider).hasError, isFalse);
      expect(
        container.read(languageControllerProvider).requireValue,
        AppLanguage.english,
      );
    });
  });
}
