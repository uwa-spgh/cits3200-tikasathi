import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/encryption/database_key_store.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';

part 'app_database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase(
    keyStore: DatabaseKeyStore(ref.watch(secureStorageProvider)),
  );
  // A database that never opened, such as one whose key was lost, throws the
  // same error again on close. There is nothing to close, so drop it.
  ref.onDispose(() => db.close().then((_) {}, onError: (Object _) {}));
  return db;
}
