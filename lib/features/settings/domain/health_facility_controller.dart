import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';

part 'health_facility_controller.g.dart';

typedef HealthFacility = HealthFacilitator;

@Riverpod(keepAlive: true)
Stream<HealthFacility?> healthFacility(HealthFacilityRef ref) {
  return ref
      .watch(appDatabaseProvider)
      .healthFacilitatorsDao
      .watchLocalFacilitator();
}

@riverpod
class HealthFacilityController extends _$HealthFacilityController {
  @override
  Future<void> build() async {}

  Future<bool> save({
    required String name,
    required String address,
    required String phone,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(appDatabaseProvider)
          .healthFacilitatorsDao
          .saveLocalFacilitator(
            name: name,
            address: address,
            phone: phone,
          );
      state = const AsyncData<void>(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError<void>(error, stackTrace);
      return false;
    }
  }
}
