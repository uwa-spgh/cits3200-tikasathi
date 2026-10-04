import 'dart:io';

import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

/// Every SQLite file starts with these 16 bytes. An encrypted file looks like
/// random noise instead, so this tells the two apart.
const String _plaintextHeader = 'SQLite format 3\u0000';

/// The database file exists but the key that unlocks it does not.
///
/// This happens when the file is copied to a phone without the secure
/// storage that held its key. The data cannot be recovered, so the app
/// refuses to open it rather than quietly starting over.
class DatabaseKeyLostException implements Exception {
  const DatabaseKeyLostException();

  @override
  String toString() =>
      'DatabaseKeyLostException: the database is encrypted but its key is '
      'missing from secure storage';
}

/// Tells `package:sqlite3` to load SQLCipher instead of the system SQLite.
///
/// It must run on every isolate that opens the database, before it does.
void useSqlCipher() {
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
}

/// Android before 6.0 cannot load the bundled SQLCipher without this
/// workaround. Call it once on the main isolate before opening the database.
Future<void> prepareSqlCipherOnAndroid() async {
  if (Platform.isAndroid) {
    await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
  }
}

/// Whether [file] is a readable, unencrypted SQLite database.
bool isPlaintextSqlite(File file) {
  if (!file.existsSync()) {
    return false;
  }
  final RandomAccessFile reader = file.openSync();
  try {
    final List<int> header = reader.readSync(_plaintextHeader.length);
    return String.fromCharCodes(header) == _plaintextHeader;
  } finally {
    reader.closeSync();
  }
}

String _rawKeyLiteral(String hexKey) => "x'$hexKey'";

/// Unlocks [database] with [hexKey] and proves the key is right.
///
/// Throws when the SQLCipher library is missing: without it `PRAGMA key`
/// silently does nothing and the app would write a plaintext database.
void unlockDatabase(Database database, String hexKey) {
  if (database.select('PRAGMA cipher_version').isEmpty) {
    throw StateError(
      'SQLCipher is not available. Check that sqlcipher_flutter_libs is the '
      'only SQLite library in the build.',
    );
  }
  database.execute('PRAGMA key = "${_rawKeyLiteral(hexKey)}"');
  // A wrong key only shows up on the first read.
  database.select('SELECT count(*) FROM sqlite_master');
}

/// Replaces the plaintext database at [path] with an encrypted copy.
///
/// The copy is built beside the original and checked before it takes the
/// original's place. If anything fails the original is left as it was.
void encryptPlaintextDatabase({required String path, required String hexKey}) {
  final File copy = File('$path.encrypting');
  if (copy.existsSync()) {
    copy.deleteSync();
  }

  try {
    final Database plain = sqlite3.open(path);
    final int userVersion;
    final int objectCount;
    try {
      userVersion = _userVersion(plain);
      objectCount = _objectCount(plain);
      plain.execute('ATTACH DATABASE ? AS encrypted KEY ?', <Object>[
        copy.path,
        _rawKeyLiteral(hexKey),
      ]);
      plain.select("SELECT sqlcipher_export('encrypted')");
      // sqlcipher_export copies tables but not the schema version drift uses.
      plain.execute('PRAGMA encrypted.user_version = $userVersion');
      plain.execute('DETACH DATABASE encrypted');
    } finally {
      plain.dispose();
    }

    final Database encrypted = sqlite3.open(copy.path);
    try {
      unlockDatabase(encrypted, hexKey);
      if (_userVersion(encrypted) != userVersion ||
          _objectCount(encrypted) != objectCount) {
        throw StateError('The encrypted copy does not match the original.');
      }
    } finally {
      encrypted.dispose();
    }

    copy.renameSync(path);
  } catch (_) {
    if (copy.existsSync()) {
      copy.deleteSync();
    }
    rethrow;
  }
}

int _userVersion(Database database) =>
    database.select('PRAGMA user_version').first.values.first! as int;

int _objectCount(Database database) =>
    database.select('SELECT count(*) FROM sqlite_master').first.values.first!
        as int;
