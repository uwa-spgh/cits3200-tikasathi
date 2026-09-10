part of '../app_database.dart';

@DriftAccessor(
    tables: [ChildProfiles, VaccinationDues, VaccinationRecords, Reminders])
class ChildProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$ChildProfilesDaoMixin {
  ChildProfilesDao(super.db);

  Future<int> insertChildProfile(ChildProfilesCompanion childProfile) {
    return into(childProfiles).insert(childProfile);
  }

  Stream<List<ChildProfile>> streamAllChildProfiles() {
    return select(childProfiles).watch();
  }

  Future<List<ChildProfile>> getAllChildProfiles() {
    return select(childProfiles).get();
  }

  Future<ChildProfile?> getChildProfileById(String id) {
    return (select(childProfiles)..where((row) => row.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> updateChildProfile({
    required String id,
    required String name,
    required DateTime dateOfBirth,
    required String sex,
  }) {
    return (update(childProfiles)..where((row) => row.id.equals(id))).write(
      ChildProfilesCompanion(
        name: Value(name),
        dateOfBirth: Value(dateOfBirth),
        sex: Value(sex),
      ),
    );
  }

  /// Removes the child and that child's reminders, dues and records.
  ///
  /// Reminders go first: they reference both the child and its dues, so
  /// deleting either one out from under them trips the foreign key.
  Future<int> deleteChildProfile(String id) {
    return transaction(() async {
      await (delete(reminders)..where((row) => row.childId.equals(id))).go();
      await (delete(vaccinationDues)..where((row) => row.childId.equals(id)))
          .go();
      await (delete(vaccinationRecords)..where((row) => row.childId.equals(id)))
          .go();
      return (delete(childProfiles)..where((row) => row.id.equals(id))).go();
    });
  }

  Future<int> setSetupComplete(String id, bool isComplete) {
    return (update(childProfiles)..where((row) => row.id.equals(id))).write(
      ChildProfilesCompanion(
        isSetupComplete: Value(isComplete),
      ),
    );
  }
}
