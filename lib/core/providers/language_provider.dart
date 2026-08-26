import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';

part 'language_provider.g.dart';

@riverpod
class Language extends _$Language {
  @override
  String build() {
    return 'np'; // default to Nepali until loaded
  }

  Future<void> loadLanguage() async {
    final storage = ref.read(secureStorageServiceProvider);
    final lang = await storage.getLanguage();
    if (lang != null) {
      state = lang;
    }
  }

  Future<void> setLanguage(String lang) async {
    state = lang;
    await ref.read(secureStorageServiceProvider).saveLanguage(lang);
  }
}
