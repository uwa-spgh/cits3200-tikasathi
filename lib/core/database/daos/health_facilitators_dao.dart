part of '../app_database.dart';

@DriftAccessor(tables: [HealthFacilitators])
class HealthFacilitatorsDao extends DatabaseAccessor<AppDatabase>
    with _$HealthFacilitatorsDaoMixin {
  HealthFacilitatorsDao(super.db);

  static const String localFacilitatorId = 'local';

  Stream<HealthFacilitator?> watchLocalFacilitator() {
    return (select(healthFacilitators)
          ..where((row) => row.id.equals(localFacilitatorId)))
        .watchSingleOrNull();
  }

  Future<HealthFacilitator?> getLocalFacilitator() {
    return (select(healthFacilitators)
          ..where((row) => row.id.equals(localFacilitatorId)))
        .getSingleOrNull();
  }

  Future<void> saveLocalFacilitator({
    required String name,
    required String address,
    required String phone,
  }) async {
    await into(healthFacilitators).insertOnConflictUpdate(
      HealthFacilitatorsCompanion.insert(
        id: localFacilitatorId,
        name: Value(name),
        address: Value(address),
        phone: Value(phone),
      ),
    );
  }
}
