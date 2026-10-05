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

  Future<ManualVaccinationScheduleOverride?> forVaccineDose(
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

  Future<void> saveDateOverride({
    required String childId,
    required String vaccineCode,
    required int doseNumber,
    required DateTime dueDate,
  }) async {
    if (!doesDoseExist(vaccineCode, doseNumber)) {
      throw StateError('invalid vaccine or dose');
    }

    final existing = await forVaccineDose(childId, vaccineCode, doseNumber);
    final companion = ManualVaccinationScheduleOverridesCompanion(
      childId: Value(childId),
      vaccineCode: Value(vaccineCode),
      doseNumber: Value(doseNumber),
      dueDate: Value(dueDate),
      isRemoved: const Value(false),
    );
    if (existing == null) {
      await into(manualVaccinationScheduleOverrides).insert(
        companion.copyWith(id: Value(const Uuid().v4())),
      );
    } else {
      await (update(manualVaccinationScheduleOverrides)
            ..where((row) => row.id.equals(existing.id)))
          .write(companion);
    }
  }

  Future<void> removeDose({
    required String childId,
    required String vaccineCode,
    required int doseNumber,
  }) async {
    if (!doesDoseExist(vaccineCode, doseNumber)) {
      throw StateError('invalid vaccine or dose');
    }

    final existing = await forVaccineDose(childId, vaccineCode, doseNumber);
    final companion = ManualVaccinationScheduleOverridesCompanion(
      childId: Value(childId),
      vaccineCode: Value(vaccineCode),
      doseNumber: Value(doseNumber),
      dueDate: const Value(null),
      isRemoved: const Value(true),
    );
    if (existing == null) {
      await into(manualVaccinationScheduleOverrides).insert(
        companion.copyWith(id: Value(const Uuid().v4())),
      );
    } else {
      await (update(manualVaccinationScheduleOverrides)
            ..where((row) => row.id.equals(existing.id)))
          .write(companion);
    }
  }

  Future<void> deleteAllForChild(String childId) {
    return (delete(manualVaccinationScheduleOverrides)
          ..where((row) => row.childId.equals(childId)))
        .go();
  }
}
