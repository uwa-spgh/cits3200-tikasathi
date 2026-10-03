part of '../app_database.dart';

/// Every row a local backup saves or restores.
class BackupRows {
  const BackupRows({
    required this.childProfiles,
    required this.vaccinationRecords,
    required this.vaccinationDues,
    required this.reminders,
    required this.healthFacilitators,
  });

  final List<ChildProfile> childProfiles;
  final List<VaccinationRecord> vaccinationRecords;
  final List<VaccinationDue> vaccinationDues;
  final List<Reminder> reminders;
  final List<HealthFacilitator> healthFacilitators;

  static const BackupRows empty = BackupRows(
    childProfiles: [],
    vaccinationRecords: [],
    vaccinationDues: [],
    reminders: [],
    healthFacilitators: [],
  );
}

/// Reads and replaces the tables a local backup covers.
///
/// Rows are inserted directly. The other DAOs' insert methods also reschedule
/// reminders or drop a due when a dose is recorded, which would change a restore.
@DriftAccessor(tables: [
  ChildProfiles,
  VaccinationRecords,
  VaccinationDues,
  Reminders,
  HealthFacilitators,
])
class BackupDao extends DatabaseAccessor<AppDatabase> with _$BackupDaoMixin {
  BackupDao(super.db);

  Future<BackupRows> readAll() async {
    return BackupRows(
      childProfiles: await select(childProfiles).get(),
      vaccinationRecords: await select(vaccinationRecords).get(),
      vaccinationDues: await select(vaccinationDues).get(),
      reminders: await select(reminders).get(),
      healthFacilitators: await select(healthFacilitators).get(),
    );
  }

  /// Deletes every backed-up row, then inserts [rows], in one transaction.
  ///
  /// Deletes run from reminders up to parents so foreign keys hold. Inserts
  /// run the other way. A failure throws and the transaction rolls back.
  Future<void> replaceAll(BackupRows rows) {
    return transaction(() async {
      await delete(reminders).go();
      await delete(vaccinationRecords).go();
      await delete(vaccinationDues).go();
      await delete(childProfiles).go();
      await delete(healthFacilitators).go();

      for (final ChildProfile row in rows.childProfiles) {
        await into(childProfiles).insert(row.toCompanion(false));
      }
      for (final HealthFacilitator row in rows.healthFacilitators) {
        await into(healthFacilitators).insert(row.toCompanion(false));
      }
      for (final VaccinationDue row in rows.vaccinationDues) {
        await into(vaccinationDues).insert(row.toCompanion(false));
      }
      for (final VaccinationRecord row in rows.vaccinationRecords) {
        await into(vaccinationRecords).insert(row.toCompanion(false));
      }
      for (final Reminder row in rows.reminders) {
        await into(reminders).insert(row.toCompanion(false));
      }
    });
  }
}
