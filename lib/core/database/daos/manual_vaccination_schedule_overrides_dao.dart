part of '../app_database.dart';

@DriftAccessor(
  tables: [
    ManualVaccinationScheduleOverrides,
    VaccinationDues,
    VaccinationRecords,
  ],
)
class ManualVaccinationScheduleOverridesDao
    extends DatabaseAccessor<AppDatabase>
    with _$ManualVaccinationScheduleOverridesDaoMixin {
  ManualVaccinationScheduleOverridesDao(super.db);

  Future<List<ManualVaccinationScheduleOverride>> forChild(String childId) {
    return (select(manualVaccinationScheduleOverrides)
          ..where((row) => row.childId.equals(childId)))
        .get();
  }

  Future<ManualVaccinationScheduleOverride?> forSource(
    String childId,
    String vaccineCode,
    int doseNumber,
  ) {
    return (select(manualVaccinationScheduleOverrides)
          ..where(
            (row) =>
                row.childId.equals(childId) &
                row.sourceVaccineCode.equals(vaccineCode) &
                row.sourceDoseNumber.equals(doseNumber),
          ))
        .getSingleOrNull();
  }

  Future<ManualVaccinationScheduleOverride?> forTarget(
    String childId,
    String vaccineCode,
    int doseNumber,
  ) {
    return (select(manualVaccinationScheduleOverrides)
          ..where(
            (row) =>
                row.childId.equals(childId) &
                row.vaccineCode.equals(vaccineCode) &
                row.doseNumber.equals(doseNumber),
          ))
        .getSingleOrNull();
  }

  Future<void> saveOverride({
    required String childId,
    required String sourceVaccineCode,
    required int sourceDoseNumber,
    required String vaccineCode,
    required int doseNumber,
    required DateTime dueDate,
  }) async {
    if (!doesDoseExist(vaccineCode, doseNumber)) {
      throw StateError('invalid vaccine or dose');
    }

    final existingSource = await forSource(
      childId,
      sourceVaccineCode,
      sourceDoseNumber,
    );
    final existingTarget = await forTarget(childId, vaccineCode, doseNumber);
    if (existingTarget != null && existingTarget.id != existingSource?.id) {
      throw StateError('vaccine dose is already scheduled');
    }

    final companion = ManualVaccinationScheduleOverridesCompanion(
      childId: Value(childId),
      sourceVaccineCode: Value(sourceVaccineCode),
      sourceDoseNumber: Value(sourceDoseNumber),
      vaccineCode: Value(vaccineCode),
      doseNumber: Value(doseNumber),
      dueDate: Value(dueDate),
    );
    if (existingSource == null) {
      await into(manualVaccinationScheduleOverrides).insert(
        companion.copyWith(id: Value(const Uuid().v4())),
      );
    } else {
      await (update(manualVaccinationScheduleOverrides)
            ..where((row) => row.id.equals(existingSource.id)))
          .write(companion);
    }
  }

  Future<void> deleteAllForChild(String childId) {
    return (delete(manualVaccinationScheduleOverrides)
          ..where((row) => row.childId.equals(childId)))
        .go();
  }
}
