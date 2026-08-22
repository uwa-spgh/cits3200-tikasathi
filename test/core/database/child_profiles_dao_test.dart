import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';

void main() {
  group('ChildProfilesDao', () {
    late AppDatabase database;
    late ChildProfilesDao dao;
    late VaccinationDuesDao vaccinationDuesDao;
    late VaccinationRecordsDao vaccinationRecordsDao;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      dao = database.childProfilesDao;
      vaccinationDuesDao = database.vaccinationDuesDao;
      vaccinationRecordsDao = database.vaccinationRecordsDao;
    });

    tearDown(() async {
      await database.close();
    });

    Future<List<ChildProfile>> allProfiles() {
      return dao.streamAllChildProfiles().first;
    }

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

      final profiles = await allProfiles();
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

      final profiles = await allProfiles();
      expect(profiles, hasLength(2));
      expect(profiles.map((profile) => profile.id),
          containsAll(['child-1', 'child-2']));
    });

    test('emits again when a child profile is added', () async {
      final events = <List<ChildProfile>>[];
      final subscription = dao.streamAllChildProfiles().listen(events.add);

      await pumpEventQueue();
      expect(events.last, isEmpty);

      await dao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'child-1',
          name: 'Aarav',
          dateOfBirth: DateTime(2023, 4, 15),
          sex: 'male',
        ),
      );

      await pumpEventQueue();
      expect(events.last, hasLength(1));
      expect(events.last.single.id, 'child-1');

      await subscription.cancel();
    });

    test('updates only the matching child profile', () async {
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

      await dao.updateChildProfile(
        id: 'child-1',
        name: 'Aarav Sharma',
        dateOfBirth: DateTime(2023, 5, 1),
        sex: 'female',
      );

      final profiles = await allProfiles();
      expect(profiles, hasLength(2));

      final updated =
          profiles.singleWhere((profile) => profile.id == 'child-1');
      expect(updated.name, 'Aarav Sharma');
      expect(updated.dateOfBirth, DateTime(2023, 5, 1));
      expect(updated.sex, 'female');

      final unchanged =
          profiles.singleWhere((profile) => profile.id == 'child-2');
      expect(unchanged.name, 'Sita');
      expect(unchanged.dateOfBirth, DateTime(2022, 8, 3));
      expect(unchanged.sex, 'female');
    });

    test('emits again when a child profile is updated', () async {
      await dao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'child-1',
          name: 'Aarav',
          dateOfBirth: DateTime(2023, 4, 15),
          sex: 'male',
        ),
      );

      final events = <List<ChildProfile>>[];
      final subscription = dao.streamAllChildProfiles().listen(events.add);

      await pumpEventQueue();
      expect(events.last.single.name, 'Aarav');

      await dao.updateChildProfile(
        id: 'child-1',
        name: 'Aarav Sharma',
        dateOfBirth: DateTime(2023, 4, 15),
        sex: 'male',
      );

      await pumpEventQueue();
      expect(events.last.single.name, 'Aarav Sharma');

      await subscription.cancel();
    });

    test('deletes a missing child without throwing', () async {
      await expectLater(dao.deleteChildProfile('missing-child'), completes);
    });

    test("deletes the child and that child's dues and records", () async {
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
      // Manual until insertChildProfile also writes the child's needed vaccinations.
      await vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'due-1',
          childId: 'child-1',
          vaccineCode: 'BCG',
          doseNumber: 1,
          dueDate: DateTime(2023, 4, 15),
        ),
      );
      await vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'due-2',
          childId: 'child-2',
          vaccineCode: 'BOPV',
          doseNumber: 1,
          dueDate: DateTime(2022, 10, 3),
        ),
      );
      await vaccinationRecordsDao.insertVaccinationRecord(
        VaccinationRecordsCompanion.insert(
          id: 'record-1',
          childId: 'child-1',
          vaccineCode: 'PENTA',
          doseNumber: 1,
          administeredDate: DateTime(2023, 4, 16),
        ),
      );
      await vaccinationRecordsDao.insertVaccinationRecord(
        VaccinationRecordsCompanion.insert(
          id: 'record-2',
          childId: 'child-2',
          vaccineCode: 'BCG',
          doseNumber: 1,
          administeredDate: DateTime(2022, 8, 4),
        ),
      );

      await dao.deleteChildProfile('child-1');

      final profiles = await allProfiles();
      expect(profiles, hasLength(1));
      expect(profiles.single.id, 'child-2');

      expect(
        await vaccinationDuesDao.watchVaccinationDuesForChild('child-1').first,
        isEmpty,
      );
      expect(
        await vaccinationRecordsDao
            .watchVaccinationRecordsForChild('child-1')
            .first,
        isEmpty,
      );
      expect(
        await vaccinationDuesDao.watchVaccinationDuesForChild('child-2').first,
        hasLength(1),
      );
      expect(
        await vaccinationRecordsDao
            .watchVaccinationRecordsForChild('child-2')
            .first,
        hasLength(1),
      );
    });

    test('emits again when a child profile is deleted', () async {
      await dao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'child-1',
          name: 'Aarav',
          dateOfBirth: DateTime(2023, 4, 15),
          sex: 'male',
        ),
      );

      final events = <List<ChildProfile>>[];
      final subscription = dao.streamAllChildProfiles().listen(events.add);

      await pumpEventQueue();
      expect(events.last, hasLength(1));

      await dao.deleteChildProfile('child-1');

      await pumpEventQueue();
      expect(events.last, isEmpty);

      await subscription.cancel();
    });
  });
}
