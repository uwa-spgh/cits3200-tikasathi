import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

/// Caregiver profile and onboarding flag, the pieces a backup stores outside
/// the database.
abstract interface class BackupProfileStore {
  Future<Map<String, String?>> getCaregiverProfile();

  Future<void> writeCaregiverProfile({
    required String? name,
    required String? phone,
    required String? address,
  });

  Future<bool> hasCompletedOnboarding();

  Future<void> writeOnboardingCompleted(bool completed);
}

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}

class SecureStorageService implements BackupProfileStore {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  Future<void> setOnboardingCompleted() {
    return writeOnboardingCompleted(true);
  }

  @override
  Future<void> writeOnboardingCompleted(bool completed) async {
    await _storage.write(
      key: 'onboarding_completed',
      value: completed ? 'true' : 'false',
    );
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    final value = await _storage.read(key: 'onboarding_completed');
    return value == 'true';
  }

  Future<void> saveCaregiverProfile({
    required String name,
    required String phone,
    required String address,
  }) {
    return writeCaregiverProfile(name: name, phone: phone, address: address);
  }

  @override
  Future<void> writeCaregiverProfile({
    required String? name,
    required String? phone,
    required String? address,
  }) async {
    await _writeOrDelete('caregiver_name', name);
    await _writeOrDelete('caregiver_phone', phone);
    await _writeOrDelete('caregiver_address', address);
  }

  Future<void> _writeOrDelete(String key, String? value) async {
    if (value == null) {
      await _storage.delete(key: key);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  @override
  Future<Map<String, String?>> getCaregiverProfile() async {
    return {
      'name': await _storage.read(key: 'caregiver_name'),
      'phone': await _storage.read(key: 'caregiver_phone'),
      'address': await _storage.read(key: 'caregiver_address'),
    };
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(SecureStorageServiceRef ref) {
  return SecureStorageService(ref.watch(secureStorageProvider));
}
