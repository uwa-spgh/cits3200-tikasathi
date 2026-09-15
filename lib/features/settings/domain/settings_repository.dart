import 'package:tikasathi/features/settings/domain/app_language.dart';

/// app settings persistence contract.
abstract class SettingsRepository {
  // read language or default to Nepali if nothing
  Future<AppLanguage> getLanguage();

  // persist language
  Future<void> setLanguage(AppLanguage language);
}
