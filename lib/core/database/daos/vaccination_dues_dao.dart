part of '../app_database.dart';

@DriftAccessor(
    tables: [VaccinationDues, ChildProfiles, VaccinationRecords, Reminders])
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
    final generatedDues = await _generateDuesForChild(
      childId,
      today: today,
      generateDues: generateDues,
    );

    await _insertGeneratedDues(childId, generatedDues);
  }

  Future<List<GeneratedDue>> _generateDuesForChild(
    String childId, {
    DateTime? today,
    GenerateDues generateDues = generate,
  }) async {
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

    return generateDues(
      childSexFromString(child.sex) == ChildSex.female,
      child.dateOfBirth,
      today ?? DateTime.now(),
      records,
    );
  }

  Future<void> _insertGeneratedDues(
    String childId,
    List<GeneratedDue> generatedDues,
  ) async {
    await transaction(
      () => _insertGeneratedDuesInTransaction(childId, generatedDues),
    );
  }

  Future<void> _insertGeneratedDuesInTransaction(
    String childId,
    List<GeneratedDue> generatedDues,
  ) async {
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

    // Dues carry the dates reminders are derived from, so every path that
    // writes dues has to replan them or the child ends up with none.
    await attachedDatabase.remindersDao.scheduleRemindersForChild(childId);
  }

  /// Replaces the child's dues with a freshly generated set.
  ///
  /// The regenerated dues get new ids, so the old dues' reminders cannot carry
  /// over. They are dropped first — reminders reference the due, so deleting a
  /// due out from under them trips the foreign key.
  Future<void> recalculateDuesForChild(String childId) async {
    final generatedDues = await _generateDuesForChild(childId);
    final overrides = await attachedDatabase
        .manualVaccinationScheduleOverridesDao
        .forChild(childId);
    final records = await (select(vaccinationRecords)
          ..where((row) => row.childId.equals(childId)))
        .get();
    final administeredKeys = records
        .map((record) => '${record.vaccineCode}:${record.doseNumber}')
        .toSet();

    for (final override in overrides) {
      if (!doesDoseExist(override.vaccineCode, override.doseNumber)) {
        throw StateError('invalid manual vaccine schedule override');
      }
      if (!override.isRemoved && override.dueDate == null) {
        throw StateError('manual date is required for an active override');
      }
    }

    final overrideKeys = overrides
        .map((override) => '${override.vaccineCode}:${override.doseNumber}')
        .toSet();

    final Map<String, GeneratedDue> merged = <String, GeneratedDue>{};
    for (final generated in generatedDues) {
      final key = '${generated.vaccineCode}:${generated.doseNumber}';
      if (overrideKeys.contains(key) || administeredKeys.contains(key)) {
        continue;
      }
      merged[key] = generated;
    }
    for (final override in overrides) {
      final key = '${override.vaccineCode}:${override.doseNumber}';
      if (override.isRemoved || administeredKeys.contains(key)) {
        continue;
      }
      merged[key] = (
        vaccineCode: override.vaccineCode,
        doseNumber: override.doseNumber,
        dueDate: override.dueDate!,
      );
    }

    await transaction(() async {
      await (delete(reminders)..where((row) => row.childId.equals(childId)))
          .go();
      await (delete(vaccinationDues)
            ..where((row) => row.childId.equals(childId)))
          .go();
      await _insertGeneratedDuesInTransaction(childId, merged.values.toList());
    });
  }

  Stream<List<VaccinationDue>> watchVaccinationDuesForChild(String childId) {
    return (select(vaccinationDues)
          ..where((row) => row.childId.equals(childId)))
        .watch();
  }

  /// Reads the outstanding dues once, for callers that hold their own state
  /// rather than rebuilding from a live query.
  Future<List<VaccinationDue>> getVaccinationDuesForChild(String childId) {
    return (select(vaccinationDues)
          ..where((row) => row.childId.equals(childId)))
        .get();
  }
}
