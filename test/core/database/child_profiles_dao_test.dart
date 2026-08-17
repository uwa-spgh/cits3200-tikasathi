import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';

void main() {
  group('ChildProfilesDao', () {
    late AppDatabase database;
    late ChildProfilesDao dao;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      dao = database.childProfilesDao;
    });

    tearDown(() async {
      await database.close();
    });

    test('stores a child profile record', () async {
      const id = 'child-1';
      const name = 'Aarav';
      const sex = 'male';
      final dateOfBirth = DateTime(2023, 4, 15);

      await dao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: id,
          name: name,
          dateOfBirth: dateOfBirth,
          sex: sex,
        ),
      );

      final profiles = await dao.getAllChildProfiles();
      expect(profiles, hasLength(1));
      expect(profiles.single.id, id);
      expect(profiles.single.name, name);
      expect(profiles.single.dateOfBirth, dateOfBirth);
      expect(profiles.single.sex, sex);
    });

    test('retrieves multiple child profile records', () async {
      await dao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'child-1',
          name: 'Aarav',
          dateOfBirth: DateTime(2023, 4, 15),
          sex: 'male',
        ),
      );
      await dao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'child-2',
          name: 'Sita',
          dateOfBirth: DateTime(2022, 8, 3),
          sex: 'female',
        ),
      );

      final profiles = await dao.getAllChildProfiles();
      expect(profiles, hasLength(2));
      expect(profiles.map((profile) => profile.id),
          containsAll(['child-1', 'child-2']));
    });
  });
}
