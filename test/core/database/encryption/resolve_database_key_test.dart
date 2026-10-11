import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/encryption/database_key_store.dart';
import 'package:tikasathi/core/database/encryption/encrypted_database.dart';
import 'package:tikasathi/core/database/encryption/sqlcipher.dart';

/// Covers the key decisions made at launch. No SQLCipher library is needed:
/// the files are fakes and encryption is replaced by a recorder.
void main() {
  group('resolveDatabaseKey', () {
    late Directory directory;
    late File file;
    late DatabaseKeyStore keys;
    late List<({String path, String hexKey})> encrypted;

    void recordEncrypt({required String path, required String hexKey}) {
      encrypted.add((path: path, hexKey: hexKey));
    }

    void writePlaintextDatabase() {
      file.writeAsBytesSync(<int>[
        ...'SQLite format 3\u0000'.codeUnits,
        ...List<int>.filled(100, 0),
      ]);
    }

    void writeEncryptedDatabase() {
      file.writeAsBytesSync(List<int>.generate(4096, (int i) => (i * 7) % 256));
    }

    setUp(() {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      keys = DatabaseKeyStore(const FlutterSecureStorage());
      directory = Directory.systemTemp.createTempSync('tikasathi_key_');
      file = File('${directory.path}/tikasathi.sqlite');
      encrypted = <({String path, String hexKey})>[];
    });

    tearDown(() {
      directory.deleteSync(recursive: true);
    });

    Future<String> resolve() =>
        resolveDatabaseKey(file: file, keys: keys, encrypt: recordEncrypt);

    test('makes and saves a key on first launch', () async {
      final String key = await resolve();

      expect(await keys.read(), key);
      expect(encrypted, isEmpty);
    });

    test('reuses the stored key when there is no file yet', () async {
      final String stored = await keys.create();

      expect(await resolve(), stored);
    });

    test('treats an empty file as a new database', () async {
      file.writeAsBytesSync(<int>[]);

      final String key = await resolve();

      expect(await keys.read(), key);
      expect(encrypted, isEmpty);
    });

    test('opens an encrypted database with the stored key', () async {
      final String stored = await keys.create();
      writeEncryptedDatabase();

      expect(await resolve(), stored);
      expect(encrypted, isEmpty);
    });

    test('encrypts a plaintext database with a new key', () async {
      writePlaintextDatabase();

      final String key = await resolve();

      expect(await keys.read(), key);
      expect(encrypted, <({String path, String hexKey})>[
        (path: file.path, hexKey: key),
      ]);
    });

    test('encrypts a plaintext database with the stored key', () async {
      final String stored = await keys.create();
      writePlaintextDatabase();

      expect(await resolve(), stored);
      expect(encrypted.single.hexKey, stored);
    });

    test('refuses an encrypted database whose key is gone', () async {
      writeEncryptedDatabase();

      await expectLater(resolve(), throwsA(isA<DatabaseKeyLostException>()));
      expect(await keys.read(), isNull);
    });

    test('keeps the key when encryption fails so a retry can use it', () async {
      writePlaintextDatabase();

      await expectLater(
        resolveDatabaseKey(
          file: file,
          keys: keys,
          encrypt: ({required String path, required String hexKey}) {
            throw StateError('disk full');
          },
        ),
        throwsStateError,
      );

      final String stored = (await keys.read())!;
      expect(await resolve(), stored);
      expect(encrypted.single.hexKey, stored);
    });
  });
}
