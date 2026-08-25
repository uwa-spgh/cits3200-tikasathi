import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  Future<void> setOnboardingCompleted() async {
    await _storage.write(key: 'onboarding_completed', value: 'true');
  }

  Future<bool> hasCompletedOnboarding() async {
    final value = await _storage.read(key: 'onboarding_completed');
    return value == 'true';
  }

  Future<void> saveCaregiverProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    await _storage.write(key: 'caregiver_name', value: name);
    await _storage.write(key: 'caregiver_phone', value: phone);
    await _storage.write(key: 'caregiver_address', value: address);
  }

  Future<Map<String, String?>> getCaregiverProfile() async {
    return {
      'name': await _storage.read(key: 'caregiver_name'),
      'phone': await _storage.read(key: 'caregiver_phone'),
      'address': await _storage.read(key: 'caregiver_address'),
    };
  }

  Future<void> saveLanguage(String lang) async {
    await _storage.write(key: 'app_language', value: lang);
  }

  Future<String?> getLanguage() async {
    return await _storage.read(key: 'app_language');
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(SecureStorageServiceRef ref) {
  return SecureStorageService(ref.watch(secureStorageProvider));
}
