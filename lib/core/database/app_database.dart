import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:tikasathi/core/nip/generate.dart';
import 'package:tikasathi/core/nip/vaccine_catalogue.dart';
import 'package:uuid/uuid.dart';

part 'daos/child_profiles_dao.dart';
part 'daos/vaccination_records_dao.dart';
part 'daos/vaccination_dues_dao.dart';
part 'tables/child_profiles.dart';
part 'tables/vaccination_records.dart';
part 'tables/vaccination_dues.dart';
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
@DriftDatabase(
  tables: [ChildProfiles, VaccinationRecords, VaccinationDues],
  daos: [ChildProfilesDao, VaccinationRecordsDao, VaccinationDuesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  /// Pre-release: stay at 1. Do not add onUpgrade yet.
  /// After a schema change, wipe the local app / delete `tikasathi.sqlite`.
  /// Start versioned migrations after the first user release.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (OpeningDetails details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

/// Opens a persistent SQLite database file in the app's documents directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tikasathi.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
