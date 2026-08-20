part of '../app_database.dart';

@DriftAccessor(tables: [ChildProfiles, VaccinationDues, VaccinationRecords])
class ChildProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$ChildProfilesDaoMixin {
  ChildProfilesDao(super.db);

  Future<int> insertChildProfile(ChildProfilesCompanion childProfile) {
    return into(childProfiles).insert(childProfile);
  }

  Stream<List<ChildProfile>> streamAllChildProfiles() {
    return select(childProfiles).watch();
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

  /// Removes the child and that child's dues and records.
  Future<int> deleteChildProfile(String id) {
    return transaction(() async {
      await (delete(vaccinationDues)..where((row) => row.childId.equals(id)))
          .go();
      await (delete(vaccinationRecords)..where((row) => row.childId.equals(id)))
          .go();
      return (delete(childProfiles)..where((row) => row.id.equals(id))).go();
    });
  }
}
