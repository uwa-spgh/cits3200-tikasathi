part of '../app_database.dart';

@DriftAccessor(tables: [VaccinationRecords, VaccinationDues])
class VaccinationRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$VaccinationRecordsDaoMixin {
  VaccinationRecordsDao(super.db);

  /// Stores a given dose and drops that dose from [VaccinationDues] if present.
  /// allows recording a vaccinedose thats not in Due w/o any errors
  Future<int> insertVaccinationRecord(
    VaccinationRecordsCompanion vaccinationRecord,
  ) {
    return transaction(() async {
      final rowId = await into(vaccinationRecords).insert(vaccinationRecord);
      await (delete(vaccinationDues)
            ..where(
              (row) =>
                  row.childId.equals(vaccinationRecord.childId.value) &
                  row.vaccineCode.equals(vaccinationRecord.vaccineCode.value) &
                  row.doseNumber.equals(vaccinationRecord.doseNumber.value),
            ))
          .go();
      return rowId;
    });
  }

  Stream<List<VaccinationRecord>> watchVaccinationRecordsForChild(
    String childId,
  ) {
    return (select(vaccinationRecords)
          ..where((row) => row.childId.equals(childId)))
        .watch();
  }
}
