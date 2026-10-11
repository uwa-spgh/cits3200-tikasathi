import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/database_recovery.dart';
import 'package:tikasathi/core/database/encryption/database_key_store.dart';
import 'package:tikasathi/core/database/encryption/sqlcipher.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';

void main() {
  group('canOpenDatabase', () {
    setUp(() {
      final previousMultipleDatabaseWarningSetting =
          driftRuntimeOptions.dontWarnAboutMultipleDatabases;
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      addTearDown(() {
        driftRuntimeOptions.dontWarnAboutMultipleDatabases =
            previousMultipleDatabaseWarningSetting;
      });
    });

    test('is false when the key is lost', () async {
      final AppDatabase database = AppDatabase.forTesting(
        LazyDatabase(() => throw const DatabaseKeyLostException()),
      );
      addTearDown(() => database.close().then((_) {}, onError: (Object _) {}));

      expect(await canOpenDatabase(database), isFalse);
    });

    test('rethrows any other failure instead of calling it lost', () async {
      final AppDatabase database = AppDatabase.forTesting(
        LazyDatabase(() => throw StateError('disk is busy')),
      );
      addTearDown(() => database.close().then((_) {}, onError: (Object _) {}));

      await expectLater(canOpenDatabase(database), throwsStateError);
    });
  });

  group('eraseLocalData', () {
    late Directory directory;
    late File databaseFile;
    late FlutterSecureStorage storage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      storage = const FlutterSecureStorage();
      directory = Directory.systemTemp.createTempSync('tikasathi_reset_');
      databaseFile = File('${directory.path}/tikasathi.sqlite');
    });

    tearDown(() {
      directory.deleteSync(recursive: true);
    });

    test('deletes the database files and every stored secret', () async {
      for (final String suffix in <String>['', '-journal', '-wal', '-shm']) {
        File('${databaseFile.path}$suffix').writeAsStringSync('data');
      }
      File('${databaseFile.path}.encrypting').writeAsStringSync('data');
      File('${directory.path}/keep.txt').writeAsStringSync('other file');
      final SecureStorageService secure = SecureStorageService(storage);
      await DatabaseKeyStore(storage).create();
      await secure.saveCaregiverProfile(
        name: 'Sita',
        phone: '9801234567',
        address: 'Kathmandu',
      );
      await secure.setOnboardingCompleted();

      await eraseLocalData(databaseFile: databaseFile, secureStorage: secure);

      expect(
        directory
            .listSync()
            .map((FileSystemEntity e) => e.uri.pathSegments.last),
        <String>['keep.txt'],
      );
      expect(await storage.readAll(), isEmpty);
    });

    test('works when the files are already gone', () async {
      await eraseLocalData(
        databaseFile: databaseFile,
        secureStorage: SecureStorageService(storage),
      );

      expect(directory.listSync(), isEmpty);
    });
  });
}
