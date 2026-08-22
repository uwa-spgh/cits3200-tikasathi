part of '../app_database.dart';

@DriftAccessor(tables: [VaccinationDues, ChildProfiles, VaccinationRecords])
class VaccinationDuesDao extends DatabaseAccessor<AppDatabase>
    with _$VaccinationDuesDaoMixin {
  VaccinationDuesDao(super.db);

  Future<int> insertVaccinationDue(VaccinationDuesCompanion vaccinationDue) {
    if (!doesDoseExist(
        vaccinationDue.vaccineCode.value, vaccinationDue.doseNumber.value)) {
      throw Exception('invalid vaccine or dose');
    }
    return into(vaccinationDues).insert(vaccinationDue);
  }

  /// Persists [generateDues] output as Due rows for an existing child + their records
  /// [UnimplementedError] until genereate algo is finished issue #12.
  Future<void> insertDuesForChild(
    String childId, {
    DateTime? today,
    GenerateDues generateDues = generate,
  }) async {
    // 1: Get child info
    final child = await (select(childProfiles)
          ..where((row) => row.id.equals(childId)))
        .getSingleOrNull();
    if (child == null) {
      throw Exception('child not found');
    }

    final recordRows = await (select(vaccinationRecords)
          ..where((row) => row.childId.equals(childId)))
        .get();
    final records = [
      for (final row in recordRows)
        (
          vaccineCode: row.vaccineCode,
          doseNumber: row.doseNumber,
          administeredDate: row.administeredDate,
        ),
    ];

    // 2. get child generated VaccinationDue
    final generatedDues = generateDues(
      child.dateOfBirth,
      today ?? DateTime.now(),
      records,
    );

    // 3. insert child's generatedDues
    await transaction(() async {
      for (final generatedDue in generatedDues) {
        await insertVaccinationDue(
          VaccinationDuesCompanion.insert(
            id: const Uuid().v4(),
            childId: childId,
            vaccineCode: generatedDue.vaccineCode,
            doseNumber: generatedDue.doseNumber,
            dueDate: generatedDue.dueDate,
          ),
        );
      }
    });
  }

  Stream<List<VaccinationDue>> watchVaccinationDuesForChild(String childId) {
    return (select(vaccinationDues)
          ..where((row) => row.childId.equals(childId)))
        .watch();
  }
}
