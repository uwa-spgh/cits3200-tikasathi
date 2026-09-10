part of '../app_database.dart';

@DriftAccessor(tables: [VaccinationRecords, VaccinationDues, Reminders])
class VaccinationRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$VaccinationRecordsDaoMixin {
  VaccinationRecordsDao(super.db);

  /// Stores a given dose and drops that dose from [VaccinationDues] if present,
  /// along with any reminders that were scheduled for it.
  /// allows recording a vaccinedose thats not in Due w/o any errors
  Future<int> insertVaccinationRecord(
    VaccinationRecordsCompanion vaccinationRecord,
  ) {
    if (!doesDoseExist(vaccinationRecord.vaccineCode.value,
        vaccinationRecord.doseNumber.value)) {
      throw Exception('invalid vaccine or dose');
    }
    return transaction(() async {
      final rowId = await into(vaccinationRecords).insert(vaccinationRecord);
      final settled = await (select(vaccinationDues)
            ..where(
              (row) =>
                  row.childId.equals(vaccinationRecord.childId.value) &
                  row.vaccineCode.equals(vaccinationRecord.vaccineCode.value) &
                  row.doseNumber.equals(vaccinationRecord.doseNumber.value),
            ))
          .get();
      if (settled.isNotEmpty) {
        final dueIds = settled.map((due) => due.id).toList();
        // Reminders reference the due, so they have to go first.
        await (delete(reminders)..where((row) => row.dueId.isIn(dueIds))).go();
        await (delete(vaccinationDues)..where((row) => row.id.isIn(dueIds)))
            .go();
      }
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
