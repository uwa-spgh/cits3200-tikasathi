import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/encryption/sqlcipher.dart';

/// Where Homebrew installs SQLCipher (`brew install sqlcipher`). These tests
/// need a real SQLCipher library, so they are skipped when it is absent.
const String _hostSqlCipher =
    '/opt/homebrew/opt/sqlcipher/lib/libsqlcipher.dylib';

final String _key = 'ab' * 32;
final String _otherKey = 'cd' * 32;

void main() {
  final bool hasSqlCipher = File(_hostSqlCipher).existsSync();

  group('SQLCipher encryption', skip: hasSqlCipher ? false : 'needs SQLCipher',
      () {
    late Directory directory;
    late String path;

    setUpAll(() {
      open.overrideFor(
        OperatingSystem.macOS,
        () => DynamicLibrary.open(_hostSqlCipher),
      );
    });

    setUp(() {
      directory = Directory.systemTemp.createTempSync('tikasathi_cipher_');
      path = '${directory.path}/tikasathi.sqlite';
    });

    tearDown(() {
      directory.deleteSync(recursive: true);
    });

    Database openPlain() => sqlite3.open(path);

    void writePlainDatabase() {
      final Database db = openPlain();
      db.execute('CREATE TABLE notes (id INTEGER PRIMARY KEY, body TEXT)');
      db.execute("INSERT INTO notes (body) VALUES ('first'), ('second')");
      db.execute('PRAGMA user_version = 2');
      db.dispose();
    }

    group('isPlaintextSqlite', () {
      test('is false when the file does not exist', () {
        expect(isPlaintextSqlite(File(path)), isFalse);
      });

      test('is false for an empty file', () {
        File(path).writeAsBytesSync(<int>[]);

        expect(isPlaintextSqlite(File(path)), isFalse);
      });

      test('is true for a plain SQLite database', () {
        writePlainDatabase();

        expect(isPlaintextSqlite(File(path)), isTrue);
      });

      test('is false once the database is encrypted', () {
        writePlainDatabase();
        encryptPlaintextDatabase(path: path, hexKey: _key);

        expect(isPlaintextSqlite(File(path)), isFalse);
      });
    });

    group('unlockDatabase', () {
      test('creates a database that only the key can read', () {
        final Database db = openPlain();
        unlockDatabase(db, _key);
        db.execute('CREATE TABLE notes (body TEXT)');
        db.dispose();

        expect(isPlaintextSqlite(File(path)), isFalse);

        final Database again = openPlain();
        addTearDown(again.dispose);
        unlockDatabase(again, _key);
        expect(
          again.select('SELECT count(*) AS n FROM notes').first['n'],
          0,
        );
      });

      test('rejects the wrong key', () {
        final Database db = openPlain();
        unlockDatabase(db, _key);
        db.execute('CREATE TABLE notes (body TEXT)');
        db.dispose();

        final Database again = openPlain();
        addTearDown(again.dispose);

        expect(
          () => unlockDatabase(again, _otherKey),
          throwsA(isA<SqliteException>()),
        );
      });
    });

    group('encryptPlaintextDatabase', () {
      test('keeps every row and the schema version', () {
        writePlainDatabase();

        encryptPlaintextDatabase(path: path, hexKey: _key);

        final Database db = openPlain();
        addTearDown(db.dispose);
        unlockDatabase(db, _key);
        expect(
          db.select('SELECT body FROM notes ORDER BY id').map((r) => r['body']),
          <Object?>['first', 'second'],
        );
        expect(db.select('PRAGMA user_version').first.values.first, 2);
      });

      test('leaves no plaintext in the file', () {
        writePlainDatabase();

        encryptPlaintextDatabase(path: path, hexKey: _key);

        final String bytes = String.fromCharCodes(File(path).readAsBytesSync());
        expect(bytes, isNot(contains('first')));
        expect(bytes, isNot(contains('notes')));
      });

      test('cleans up its working copy', () {
        writePlainDatabase();

        encryptPlaintextDatabase(path: path, hexKey: _key);

        expect(File('$path.encrypting').existsSync(), isFalse);
      });

      test('replaces a stale working copy from an interrupted run', () {
        writePlainDatabase();
        File('$path.encrypting').writeAsStringSync('half written');

        encryptPlaintextDatabase(path: path, hexKey: _key);

        final Database db = openPlain();
        addTearDown(db.dispose);
        unlockDatabase(db, _key);
        expect(db.select('SELECT count(*) AS n FROM notes').first['n'], 2);
        expect(File('$path.encrypting').existsSync(), isFalse);
      });

      test('leaves the original untouched when it cannot be encrypted', () {
        File(path).writeAsStringSync('this is not a database' * 10);
        final List<int> before = File(path).readAsBytesSync();

        expect(
          () => encryptPlaintextDatabase(path: path, hexKey: _key),
          throwsA(isA<SqliteException>()),
        );

        expect(File(path).readAsBytesSync(), before);
        expect(File('$path.encrypting').existsSync(), isFalse);
      });
    });

    group('with the app schema', () {
      test('an upgraded database opens without being recreated', () async {
        final AppDatabase plain = AppDatabase.forTesting(
          NativeDatabase(File(path)),
        );
        await plain.childProfilesDao.insertChildProfile(
          ChildProfilesCompanion.insert(
            id: 'child-1',
            name: 'Aarav',
            dateOfBirth: DateTime(2023, 4, 15),
            sex: 'male',
            isSetupComplete: const Value(true),
          ),
        );
        await plain.close();

        encryptPlaintextDatabase(path: path, hexKey: _key);

        final AppDatabase encrypted = AppDatabase.forTesting(
          NativeDatabase(
            File(path),
            setup: (Database db) => unlockDatabase(db, _key),
          ),
        );
        addTearDown(encrypted.close);
        final List<ChildProfile> profiles =
            await encrypted.childProfilesDao.getAllChildProfiles();
        expect(profiles.single.name, 'Aarav');
        expect(profiles.single.isSetupComplete, isTrue);
      });
    });
  });
}
