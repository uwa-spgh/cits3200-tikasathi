part of '../app_database.dart';

@DriftAccessor(tables: [VaccinationDues])
class VaccinationDuesDao extends DatabaseAccessor<AppDatabase>
    with _$VaccinationDuesDaoMixin {
  VaccinationDuesDao(super.db);

  Future<int> insertVaccinationDue(VaccinationDuesCompanion vaccinationDue) {
    return into(vaccinationDues).insert(vaccinationDue);
  }

  Stream<List<VaccinationDue>> watchVaccinationDuesForChild(String childId) {
    return (select(vaccinationDues)
          ..where((row) => row.childId.equals(childId)))
        .watch();
  }
}
