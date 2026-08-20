part of '../app_database.dart';

@DriftAccessor(tables: [ChildProfiles])
class ChildProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$ChildProfilesDaoMixin {
  ChildProfilesDao(super.db);

  Future<int> insertChildProfile(ChildProfilesCompanion childProfile) {
    return into(childProfiles).insert(childProfile);
  }

  Future<List<ChildProfile>> getAllChildProfiles() {
    return select(childProfiles).get();
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
}
