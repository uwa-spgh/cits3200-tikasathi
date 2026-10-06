import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/encryption/database_key_store.dart';
import 'package:tikasathi/core/database/encryption/encrypted_database.dart';
import 'package:tikasathi/core/database/encryption/sqlcipher.dart';

/// Runs the real SQLCipher build on a device or emulator:
/// `flutter test integration_test/database_encryption_test.dart -d <device>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late File file;
  late DatabaseKeyStore keys;
  const FlutterSecureStorage storage = FlutterSecureStorage();

  setUp(() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    file = File(p.join(directory.path, 'encryption_test.sqlite'));
    keys = DatabaseKeyStore(storage);
    await _cleanUp(file, storage);
  });

  tearDown(() => _cleanUp(file, storage));

  Future<AppDatabase> openApp() async {
    return AppDatabase.forTesting(
      await openEncryptedDatabase(file: file, keys: keys),
    );
  }

  Future<void> addChild(AppDatabase database, String name) {
    return database.childProfilesDao.insertChildProfile(
      ChildProfilesCompanion.insert(
        id: 'child-1',
        name: name,
        dateOfBirth: DateTime(2023, 4, 15),
        sex: 'male',
      ),
    );
  }

  testWidgets('a new database is encrypted and survives a reopen',
      (WidgetTester tester) async {
    final AppDatabase first = await openApp();
    await addChild(first, 'Aarav');
    await first.close();

    expect(isPlaintextSqlite(file), isFalse);

    final AppDatabase second = await openApp();
    addTearDown(second.close);
    final List<ChildProfile> profiles =
        await second.childProfilesDao.getAllChildProfiles();
    expect(profiles.single.name, 'Aarav');
  });

  testWidgets('a plaintext database from an older build is encrypted',
      (WidgetTester tester) async {
    useSqlCipher();
    final AppDatabase legacy = AppDatabase.forTesting(NativeDatabase(file));
    await addChild(legacy, 'Aarav');
    await legacy.close();
    expect(isPlaintextSqlite(file), isTrue);

    final AppDatabase upgraded = await openApp();
    addTearDown(upgraded.close);

    final List<ChildProfile> profiles =
        await upgraded.childProfilesDao.getAllChildProfiles();
    expect(profiles.single.name, 'Aarav');
    expect(isPlaintextSqlite(file), isFalse);
  });

  testWidgets('an encrypted database without its key is refused',
      (WidgetTester tester) async {
    final AppDatabase database = await openApp();
    await addChild(database, 'Aarav');
    await database.close();

    await storage.delete(key: DatabaseKeyStore.storageKey);

    expect(
      openEncryptedDatabase(file: file, keys: keys),
      throwsA(isA<DatabaseKeyLostException>()),
    );
  });
}

Future<void> _cleanUp(File file, FlutterSecureStorage storage) async {
  await storage.delete(key: DatabaseKeyStore.storageKey);
  for (final String suffix in <String>['', '-journal', '-wal', '-shm']) {
    final File candidate = File('${file.path}$suffix');
    if (candidate.existsSync()) {
      candidate.deleteSync();
    }
  }
}
