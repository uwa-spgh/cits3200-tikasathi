import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:tikasathi/core/database/encryption/database_key_store.dart';
import 'package:tikasathi/core/database/encryption/sqlcipher.dart';

/// Opens the SQLCipher database at [file], encrypted with the key in [keys].
///
/// - First launch: makes a key and creates an encrypted database.
/// - Upgrade from a build that stored plaintext: encrypts the existing data
///   in place before opening it.
/// - Later launches: opens the encrypted file with the stored key.
///
/// Throws [DatabaseKeyLostException] if the file is encrypted and its key is
/// gone.
Future<QueryExecutor> openEncryptedDatabase({
  required File file,
  required DatabaseKeyStore keys,
}) async {
  await prepareSqlCipherOnAndroid();
  useSqlCipher();

  final String key = await _prepareKey(file, keys);
  return NativeDatabase.createInBackground(
    file,
    isolateSetup: useSqlCipher,
    setup: (rawDb) => unlockDatabase(rawDb, key),
  );
}

Future<String> _prepareKey(File file, DatabaseKeyStore keys) async {
  final String? stored = await keys.read();

  if (isPlaintextSqlite(file)) {
    final String key = stored ?? await keys.create();
    encryptPlaintextDatabase(path: file.path, hexKey: key);
    return key;
  }

  final bool hasData = file.existsSync() && file.lengthSync() > 0;
  if (stored == null) {
    if (hasData) {
      throw const DatabaseKeyLostException();
    }
    return keys.create();
  }
  return stored;
}
