import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';

void main() {
  group('VaccinationDuesDao', () {
    late AppDatabase database;
    late ChildProfilesDao childProfilesDao;
    late VaccinationDuesDao vaccinationDuesDao;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      childProfilesDao = database.childProfilesDao;
      vaccinationDuesDao = database.vaccinationDuesDao;
    });

    tearDown(() async {
      await database.close();
    });

    Future<void> insertChild(String id) {
      return childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: id,
          name: 'Aarav',
          dateOfBirth: DateTime(2023, 4, 15),
          sex: 'male',
        ),
      );
    }

    Future<List<VaccinationDue>> duesFor(String childId) {
      return vaccinationDuesDao.watchVaccinationDuesForChild(childId).first;
    }

    test('stores a vaccination due for a child', () async {
      const childId = 'child-1';
      const dueId = 'due-1';
      const vaccineCode = 'BCG';
      const doseNumber = 1;
      final dueDate = DateTime(2023, 4, 15);

      await insertChild(childId);
      await vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: dueId,
          childId: childId,
          vaccineCode: vaccineCode,
          doseNumber: doseNumber,
          dueDate: dueDate,
        ),
      );

      final dues = await duesFor(childId);

      expect(dues, hasLength(1));
      expect(dues.single.id, dueId);
      expect(dues.single.childId, childId);
      expect(dues.single.vaccineCode, vaccineCode);
      expect(dues.single.doseNumber, doseNumber);
      expect(dues.single.dueDate, dueDate);
    });

    test('retrieves multiple vaccination dues for one child', () async {
      const childId = 'child-1';
      await insertChild(childId);
      await vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'due-1',
          childId: childId,
          vaccineCode: 'BCG',
          doseNumber: 1,
          dueDate: DateTime(2023, 4, 15),
        ),
      );
      await vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'due-2',
          childId: childId,
          vaccineCode: 'OPV',
          doseNumber: 1,
          dueDate: DateTime(2023, 6, 10),
        ),
      );

      final dues = await duesFor(childId);

      expect(dues, hasLength(2));
      expect(
        dues.map((due) => due.id),
        containsAll(['due-1', 'due-2']),
      );
    });

    test("does not return another child's vaccination dues", () async {
      await insertChild('child-a');
      await insertChild('child-b');
      await vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'due-a',
          childId: 'child-a',
          vaccineCode: 'BCG',
          doseNumber: 1,
          dueDate: DateTime(2023, 4, 15),
        ),
      );
      await vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'due-b',
          childId: 'child-b',
          vaccineCode: 'OPV',
          doseNumber: 1,
          dueDate: DateTime(2023, 6, 10),
        ),
      );

      final duesForA = await duesFor('child-a');

      expect(duesForA, hasLength(1));
      expect(duesForA.single.id, 'due-a');
    });

    test('emits again when a vaccination due is added', () async {
      const childId = 'child-1';
      await insertChild(childId);

      final events = <List<VaccinationDue>>[];
      final subscription = vaccinationDuesDao
          .watchVaccinationDuesForChild(childId)
          .listen(events.add);

      await pumpEventQueue();
      expect(events.last, isEmpty);

      await vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'due-1',
          childId: childId,
          vaccineCode: 'BCG',
          doseNumber: 1,
          dueDate: DateTime(2023, 4, 15),
        ),
      );

      await pumpEventQueue();
      expect(events.last, hasLength(1));
      expect(events.last.single.id, 'due-1');

      await subscription.cancel();
    });

    test('rejects a duplicate child, vaccine, and dose number', () async {
      const childId = 'child-1';
      await insertChild(childId);
      await vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'due-1',
          childId: childId,
          vaccineCode: 'BCG',
          doseNumber: 1,
          dueDate: DateTime(2023, 4, 15),
        ),
      );

      expect(
        () => vaccinationDuesDao.insertVaccinationDue(
          VaccinationDuesCompanion.insert(
            id: 'due-2',
            childId: childId,
            vaccineCode: 'BCG',
            doseNumber: 1,
            dueDate: DateTime(2023, 5, 1),
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('rejects a vaccination due without a matching child', () async {
      expect(
        () => vaccinationDuesDao.insertVaccinationDue(
          VaccinationDuesCompanion.insert(
            id: 'due-1',
            childId: 'missing-child',
            vaccineCode: 'BCG',
            doseNumber: 1,
            dueDate: DateTime(2023, 4, 15),
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    group('NIP', () {
      test('accepts a vaccination due with valid code and dose', () async {
        const childId = 'child-1';
        await insertChild(childId);
        await vaccinationDuesDao.insertVaccinationDue(
          VaccinationDuesCompanion.insert(
            id: 'due-1',
            childId: childId,
            vaccineCode: 'BCG',
            doseNumber: 1,
            dueDate: DateTime(2023, 4, 15),
          ),
        );

        final dues = await duesFor(childId);
        expect(dues, hasLength(1));
        expect(dues.single.childId, childId);
      });

      test('rejects a vaccination due with invalid code', () async {
        const childId = 'child-1';
        await insertChild(childId);
        expect(
          () => vaccinationDuesDao.insertVaccinationDue(
            VaccinationDuesCompanion.insert(
              id: 'due-1',
              childId: childId,
              vaccineCode: 'BCGFAKE',
              doseNumber: 1,
              dueDate: DateTime(2023, 4, 15),
            ),
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('rejects a vaccination due with valid code but invalid dose', () async {
        const childId = 'child-1';
        await insertChild(childId);
        expect(
          () => vaccinationDuesDao.insertVaccinationDue(
            VaccinationDuesCompanion.insert(
              id: 'due-1',
              childId: childId,
              vaccineCode: 'BCG',
              doseNumber: 2,
              dueDate: DateTime(2023, 4, 15),
            ),
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
