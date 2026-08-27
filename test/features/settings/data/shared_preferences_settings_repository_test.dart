import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tikasathi/features/settings/data/settings_keys.dart';
import 'package:tikasathi/features/settings/data/shared_preferences_settings_repository.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

class _MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

void main() {
  SharedPreferencesSettingsRepository repositoryWith({
    Map<String, Object> values = const <String, Object>{},
  }) {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(values);
    return SharedPreferencesSettingsRepository(SharedPreferencesAsync());
  }

  group('SharedPreferencesSettingsRepository', () {
    test('reads nepali when no language is stored', () async {
      final SharedPreferencesSettingsRepository repository = repositoryWith();

      expect(await repository.getLanguage(), AppLanguage.nepali);
    });

    test('reads a stored language', () async {
      final SharedPreferencesSettingsRepository repository = repositoryWith(
        values: <String, Object>{SettingsKeys.language: 'en'},
      );

      expect(await repository.getLanguage(), AppLanguage.english);
    });

    test('falls back to nepali when the stored code is invalid', () async {
      final SharedPreferencesSettingsRepository repository = repositoryWith(
        values: <String, Object>{SettingsKeys.language: 'xx'},
      );

      expect(await repository.getLanguage(), AppLanguage.nepali);
    });

    test('writes the language code', () async {
      final SharedPreferencesSettingsRepository repository = repositoryWith();

      await repository.setLanguage(AppLanguage.english);

      expect(
        await SharedPreferencesAsync().getString(SettingsKeys.language),
        'en',
      );
      expect(await repository.getLanguage(), AppLanguage.english);
    });

    test('updates a previously stored language', () async {
      final SharedPreferencesSettingsRepository repository = repositoryWith(
        values: <String, Object>{SettingsKeys.language: 'en'},
      );

      expect(await repository.getLanguage(), AppLanguage.english);

      await repository.setLanguage(AppLanguage.nepali);

      expect(await repository.getLanguage(), AppLanguage.nepali);
    });

    test('throws when the platform fails to persist', () async {
      final _MockSharedPreferencesAsync prefs = _MockSharedPreferencesAsync();
      when(() => prefs.setString(SettingsKeys.language, 'en')).thenAnswer(
        (_) => Future<void>.error(Exception('persist failed')),
      );

      final SharedPreferencesSettingsRepository repository =
          SharedPreferencesSettingsRepository(prefs);

      await expectLater(
        repository.setLanguage(AppLanguage.english),
        throwsA(isA<Exception>()),
      );
    });
  });
}
