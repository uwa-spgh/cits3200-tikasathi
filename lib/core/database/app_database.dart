import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'daos/child_profiles_dao.dart';
part 'tables/child_profiles.dart';
part 'app_database.g.dart';

/// The central Drift database for TikaSathi.
///
/// **How to extend this:**
/// 1. Define your Drift table class (e.g. `class Children extends Table { ... }`)
///    inside `lib/core/database/tables/` or your feature's `data/` layer.
/// 2. Add the table to the `tables` list in the `@DriftDatabase` annotation below.
/// 3. Create a DAO class annotated with `@DriftAccessor(tables: [YourTable])`.
/// 4. Add the DAO to the `daos` list in the `@DriftDatabase` annotation below.
/// 5. Run: `dart run build_runner build --delete-conflicting-outputs`
///
/// See the `proven_drift_sqlite` skill in `.agents/skills/` for the full pattern.
@DriftDatabase(tables: [ChildProfiles], daos: [ChildProfilesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  /// Bump this when you change a table schema and add a migration.
  @override
  int get schemaVersion => 1;
}

/// Opens a persistent SQLite database file in the app's documents directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tikasathi.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
