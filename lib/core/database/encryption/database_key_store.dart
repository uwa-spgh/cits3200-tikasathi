import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the key that encrypts the local database in the device's secure
/// storage (Android Keystore, iOS Keychain).
///
/// The key is 32 random bytes from a cryptographically secure generator,
/// stored as 64 hex characters. It never leaves the device and is never
/// derived from anything the user types.
class DatabaseKeyStore {
  DatabaseKeyStore(this._storage, {Random? random})
      : _random = random ?? Random.secure();

  static const String storageKey = 'database_encryption_key';
  static const int keyLengthBytes = 32;

  static final RegExp _validKey = RegExp(r'^[0-9a-f]{64}$');

  final FlutterSecureStorage _storage;
  final Random _random;

  /// The stored key, or null when none exists yet or the stored value is
  /// not a well-formed key.
  Future<String?> read() async {
    final String? value = await _storage.read(key: storageKey);
    if (value == null || !_validKey.hasMatch(value)) {
      return null;
    }
    return value;
  }

  /// Makes a fresh key, saves it, and returns it.
  ///
  /// The key is written before the caller encrypts anything with it, so a
  /// crash cannot leave data locked behind a key that was never saved.
  Future<String> create() async {
    final StringBuffer hex = StringBuffer();
    for (int i = 0; i < keyLengthBytes; i++) {
      hex.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    final String key = hex.toString();
    await _storage.write(key: storageKey, value: key);
    return key;
  }
}
