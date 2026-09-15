import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';

void main() {
  group('HealthFacilitatorsDao', () {
    late AppDatabase database;
    late HealthFacilitatorsDao dao;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      dao = database.healthFacilitatorsDao;
    });

    tearDown(() => database.close());

    test('saves and retrieves the local facilitator', () async {
      await dao.saveLocalFacilitator(
        name: 'Maya',
        address: 'Ward 4',
        phone: '9800000000',
      );

      final facilitator = await dao.getLocalFacilitator();
      expect(facilitator?.name, 'Maya');
      expect(facilitator?.address, 'Ward 4');
      expect(facilitator?.phone, '9800000000');
    });

    test('saving again updates the existing facilitator', () async {
      await dao.saveLocalFacilitator(
        name: 'Maya',
        address: 'Ward 4',
        phone: '9800000000',
      );
      await dao.saveLocalFacilitator(
        name: 'Sita',
        address: 'Ward 7',
        phone: '9811111111',
      );

      expect(await dao.getLocalFacilitator(), isNotNull);
      expect(await database.select(database.healthFacilitators).get(),
          hasLength(1));
      expect((await dao.getLocalFacilitator())?.name, 'Sita');
    });
  });
}
