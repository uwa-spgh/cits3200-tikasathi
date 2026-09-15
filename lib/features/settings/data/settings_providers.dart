import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tikasathi/features/settings/data/shared_preferences_settings_repository.dart';
import 'package:tikasathi/features/settings/domain/settings_repository.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
SharedPreferencesAsync sharedPreferences(SharedPreferencesRef ref) {
  return SharedPreferencesAsync();
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  return SharedPreferencesSettingsRepository(
    ref.watch(sharedPreferencesProvider),
  );
}
