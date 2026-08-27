import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/settings_repository.dart';

final class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({this.language = AppLanguage.nepali});

  AppLanguage language;

  @override
  Future<AppLanguage> getLanguage() async => language;

  @override
  Future<void> setLanguage(AppLanguage language) async {
    this.language = language;
  }
}
