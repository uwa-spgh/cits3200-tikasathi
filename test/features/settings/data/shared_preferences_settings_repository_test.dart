import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tikasathi/features/settings/data/settings_keys.dart';
import 'package:tikasathi/features/settings/data/shared_preferences_settings_repository.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';

class _MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferencesSettingsRepository> repositoryWith({
    Map<String, Object> values = const <String, Object>{},
  }) async {
    SharedPreferences.setMockInitialValues(values);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return SharedPreferencesSettingsRepository(prefs);
  }

  group('SharedPreferencesSettingsRepository', () {
    test('reads nepali when no language is stored', () async {
      final SharedPreferencesSettingsRepository repository =
          await repositoryWith();

      expect(await repository.getLanguage(), AppLanguage.nepali);
    });

    test('reads a stored language', () async {
      final SharedPreferencesSettingsRepository repository =
          await repositoryWith(
        values: <String, Object>{SettingsKeys.language: 'ne'},
      );

      expect(await repository.getLanguage(), AppLanguage.nepali);
    });

    test('falls back to nepali when the stored code is invalid', () async {
      final SharedPreferencesSettingsRepository repository =
          await repositoryWith(
        values: <String, Object>{SettingsKeys.language: 'xx'},
      );

      expect(await repository.getLanguage(), AppLanguage.nepali);
    });

    test('writes the language code', () async {
      final SharedPreferencesSettingsRepository repository =
          await repositoryWith();

      await repository.setLanguage(AppLanguage.nepali);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(SettingsKeys.language), 'ne');
      expect(await repository.getLanguage(), AppLanguage.nepali);
    });

    test('updates a previously stored language', () async {
      final SharedPreferencesSettingsRepository repository =
          await repositoryWith(
        values: <String, Object>{SettingsKeys.language: 'en'},
      );

      expect(await repository.getLanguage(), AppLanguage.english);

      await repository.setLanguage(AppLanguage.nepali);

      expect(await repository.getLanguage(), AppLanguage.nepali);
    });

    test('throws when the platform fails to persist', () async {
      final _MockSharedPreferences prefs = _MockSharedPreferences();
      when(() => prefs.setString(SettingsKeys.language, 'ne'))
          .thenAnswer((_) async => false);

      final SharedPreferencesSettingsRepository repository =
          SharedPreferencesSettingsRepository(prefs);

      await expectLater(
        repository.setLanguage(AppLanguage.nepali),
        throwsA(isA<Exception>()),
      );
    });
  });
}
