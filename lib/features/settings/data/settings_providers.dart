import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tikasathi/features/settings/data/shared_preferences_settings_repository.dart';
import 'package:tikasathi/features/settings/domain/settings_repository.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
Future<SettingsRepository> settingsRepository(SettingsRepositoryRef ref) async {
  final SharedPreferences prefs =
      await ref.watch(sharedPreferencesProvider.future);
  return SharedPreferencesSettingsRepository(prefs);
}
