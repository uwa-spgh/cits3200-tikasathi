part of '../app_database.dart';

@DriftAccessor(tables: [VaccinationRecords])
class VaccinationRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$VaccinationRecordsDaoMixin {
  VaccinationRecordsDao(super.db);

  Future<int> insertVaccinationRecord(
    VaccinationRecordsCompanion vaccinationRecord,
  ) {
    return into(vaccinationRecords).insert(vaccinationRecord);
  }

  Stream<List<VaccinationRecord>> watchVaccinationRecordsForChild(
    String childId,
  ) {
    return (select(vaccinationRecords)
          ..where((row) => row.childId.equals(childId)))
        .watch();
  }
}
