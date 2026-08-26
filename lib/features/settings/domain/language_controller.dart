import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/settings_repository.dart';

part 'language_controller.g.dart';

@Riverpod(keepAlive: true)
class LanguageController extends _$LanguageController {
  @override
  Future<AppLanguage> build() async {
    final SettingsRepository repository =
        await ref.watch(settingsRepositoryProvider.future);
    return repository.getLanguage();
  }

  Future<void> setLanguage(AppLanguage language) async {
    final SettingsRepository repository =
        await ref.read(settingsRepositoryProvider.future);
    state = await AsyncValue.guard(() async {
      await repository.setLanguage(language);
      return language;
    });
  }
}
