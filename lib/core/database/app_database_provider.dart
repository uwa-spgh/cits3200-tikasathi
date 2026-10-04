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
  ref.onDispose(db.close);
  return db;
}
