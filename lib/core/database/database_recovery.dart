import 'dart:io';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/encryption/sqlcipher.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';

/// Whether [database] opens.
///
/// Returns false only when the database is encrypted and its key is gone,
/// which cannot be fixed. Any other failure is rethrown, so a passing glitch
/// is never mistaken for lost data.
Future<bool> canOpenDatabase(AppDatabase database) async {
  try {
    await database.customSelect('SELECT 1').get();
    return true;
  } on DatabaseKeyLostException {
    return false;
  }
}

/// Deletes the unreadable database and everything stored beside it, so the
/// app starts again as a new install.
///
/// The caregiver profile and onboarding flag go too. They describe children
/// that no longer exist, and keeping them would skip onboarding into an empty
/// app. Secure storage is cleared last: while the database file is still
/// there, a failed run leaves the app in the same recoverable state.
Future<void> eraseLocalData({
  required File databaseFile,
  required SecureStorageService secureStorage,
}) async {
  for (final String suffix in <String>[
    '',
    '-journal',
    '-wal',
    '-shm',
    '.encrypting',
  ]) {
    final File file = File('${databaseFile.path}$suffix');
    if (file.existsSync()) {
      file.deleteSync();
    }
  }
  await secureStorage.clearAll();
}
