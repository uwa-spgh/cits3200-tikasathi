import 'package:shared_preferences/shared_preferences.dart';
import 'package:tikasathi/features/settings/data/settings_keys.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/settings_repository.dart';

/// implementation of [SettingsRepository]
class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<AppLanguage> getLanguage() async {
    final code = _prefs.getString(SettingsKeys.language);
    return AppLanguage.fromCode(code);
  }

  @override
  Future<void> setLanguage(AppLanguage language) async {
    await _prefs.setString(SettingsKeys.language, language.code);
  }
}
