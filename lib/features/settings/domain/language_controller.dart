import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/settings_repository.dart';

part 'language_controller.g.dart';

@Riverpod(keepAlive: true)
class LanguageController extends _$LanguageController {
  @override
  Future<AppLanguage> build() async {
    final SettingsRepository repository = ref.watch(settingsRepositoryProvider);
    return repository.getLanguage();
  }

  Future<bool> setLanguage(AppLanguage language) async {
    final SettingsRepository repository = ref.read(settingsRepositoryProvider);
    try {
      await repository.setLanguage(language);
      state = AsyncData<AppLanguage>(language);
      return true;
    } catch (_) {
      return false;
    }
  }
}
