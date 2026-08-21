import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/nip/vaccine_catalogue.dart';

void main() {
  group('VaccinationRecordsDao', () {
    late AppDatabase database;
    late ChildProfilesDao childProfilesDao;
    late VaccinationRecordsDao vaccinationRecordsDao;
    late VaccinationDuesDao vaccinationDuesDao;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      childProfilesDao = database.childProfilesDao;
      vaccinationRecordsDao = database.vaccinationRecordsDao;
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

    Future<List<VaccinationRecord>> recordsFor(String childId) {
      return vaccinationRecordsDao
          .watchVaccinationRecordsForChild(childId)
          .first;
    }

    test('stores a vaccination record for a child', () async {
      const childId = 'child-1';
      const recordId = 'record-1';
      const vaccineCode = 'BCG';
      const doseNumber = 1;
      const facilityName = 'Patan Hospital';
      final administeredDate = DateTime(2023, 4, 16);

      await insertChild(childId);
      await vaccinationRecordsDao.insertVaccinationRecord(
        VaccinationRecordsCompanion.insert(
          id: recordId,
          childId: childId,
          vaccineCode: vaccineCode,
          doseNumber: doseNumber,
          administeredDate: administeredDate,
          facilityName: const Value(facilityName),
        ),
      );

      final records = await recordsFor(childId);

      expect(records, hasLength(1));
      expect(records.single.id, recordId);
      expect(records.single.childId, childId);
      expect(records.single.vaccineCode, vaccineCode);
      expect(records.single.doseNumber, doseNumber);
      expect(records.single.administeredDate, administeredDate);
      expect(records.single.facilityName, facilityName);
    });

    test('retrieves multiple vaccination records for one child', () async {
      const childId = 'child-1';
      await insertChild(childId);
      await vaccinationRecordsDao.insertVaccinationRecord(
        VaccinationRecordsCompanion.insert(
          id: 'record-1',
          childId: childId,
          vaccineCode: 'BCG',
          doseNumber: 1,
          administeredDate: DateTime(2023, 4, 16),
        ),
      );
      await vaccinationRecordsDao.insertVaccinationRecord(
        VaccinationRecordsCompanion.insert(
          id: 'record-2',
          childId: childId,
          vaccineCode: 'BOPV',
          doseNumber: 1,
          administeredDate: DateTime(2023, 6, 11),
        ),
      );

      final records = await recordsFor(childId);

      expect(records, hasLength(2));
      expect(
        records.map((record) => record.id),
        containsAll(['record-1', 'record-2']),
      );
    });

    test("does not return another child's vaccination records", () async {
      await insertChild('child-a');
      await insertChild('child-b');
      await vaccinationRecordsDao.insertVaccinationRecord(
        VaccinationRecordsCompanion.insert(
          id: 'record-a',
          childId: 'child-a',
          vaccineCode: 'BCG',
          doseNumber: 1,
          administeredDate: DateTime(2023, 4, 16),
        ),
      );
      await vaccinationRecordsDao.insertVaccinationRecord(
        VaccinationRecordsCompanion.insert(
          id: 'record-b',
          childId: 'child-b',
          vaccineCode: 'BOPV',
          doseNumber: 1,
          administeredDate: DateTime(2023, 6, 11),
        ),
      );

      final recordsForA = await recordsFor('child-a');

      expect(recordsForA, hasLength(1));
      expect(recordsForA.single.id, 'record-a');
    });

    test('emits again when a vaccination record is added', () async {
      const childId = 'child-1';
      await insertChild(childId);

      final events = <List<VaccinationRecord>>[];
      final subscription = vaccinationRecordsDao
          .watchVaccinationRecordsForChild(childId)
          .listen(events.add);

      await pumpEventQueue();
      expect(events.last, isEmpty);

      await vaccinationRecordsDao.insertVaccinationRecord(
        VaccinationRecordsCompanion.insert(
          id: 'record-1',
          childId: childId,
          vaccineCode: 'BCG',
          doseNumber: 1,
          administeredDate: DateTime(2023, 4, 16),
        ),
      );

      await pumpEventQueue();
      expect(events.last, hasLength(1));
      expect(events.last.single.id, 'record-1');

      await subscription.cancel();
    });

    test('rejects a duplicate child, vaccine, and dose number', () async {
      const childId = 'child-1';
      await insertChild(childId);
      await vaccinationRecordsDao.insertVaccinationRecord(
        VaccinationRecordsCompanion.insert(
          id: 'record-1',
          childId: childId,
          vaccineCode: 'BCG',
          doseNumber: 1,
          administeredDate: DateTime(2023, 4, 16),
        ),
      );

      expect(
        () => vaccinationRecordsDao.insertVaccinationRecord(
          VaccinationRecordsCompanion.insert(
            id: 'record-2',
            childId: childId,
            vaccineCode: 'BCG',
            doseNumber: 1,
            administeredDate: DateTime(2023, 4, 20),
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('rejects a vaccination record without a matching child', () async {
      expect(
        () => vaccinationRecordsDao.insertVaccinationRecord(
          VaccinationRecordsCompanion.insert(
            id: 'record-1',
            childId: 'missing-child',
            vaccineCode: 'BCG',
            doseNumber: 1,
            administeredDate: DateTime(2023, 4, 16),
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('removes the matching vaccination due when a record is stored',
        () async {
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
          vaccineCode: 'BOPV',
          doseNumber: 1,
          dueDate: DateTime(2023, 6, 10),
        ),
      );

      await vaccinationRecordsDao.insertVaccinationRecord(
        VaccinationRecordsCompanion.insert(
          id: 'record-1',
          childId: childId,
          vaccineCode: 'BCG',
          doseNumber: 1,
          administeredDate: DateTime(2023, 4, 16),
        ),
      );

      final dues =
          await vaccinationDuesDao.watchVaccinationDuesForChild(childId).first;
      final records = await recordsFor(childId);

      expect(records, hasLength(1));
      expect(dues, hasLength(1));
      expect(dues.single.id, 'due-2');
    });

    test('stores a vaccination record when no matching due exists', () async {
      const childId = 'child-1';
      await insertChild(childId);

      await vaccinationRecordsDao.insertVaccinationRecord(
        VaccinationRecordsCompanion.insert(
          id: 'record-1',
          childId: childId,
          vaccineCode: 'BCG',
          doseNumber: 1,
          administeredDate: DateTime(2023, 4, 16),
        ),
      );

      final records = await recordsFor(childId);
      expect(records, hasLength(1));
      expect(records.single.id, 'record-1');
    });

    test('leaves dues unchanged when the record insert is rejected', () async {
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

      /// throws bc of no administeredDate
      await expectLater(
        vaccinationRecordsDao.insertVaccinationRecord(
          const VaccinationRecordsCompanion(
            id: Value('record-1'),
            childId: Value(childId),
            vaccineCode: Value('BCG'),
            doseNumber: Value(1),
          ),
        ),
        throwsA(isA<Exception>()),
      );

      final dues =
          await vaccinationDuesDao.watchVaccinationDuesForChild(childId).first;
      expect(dues, hasLength(1));
      expect(dues.single.id, 'due-1');
    });

    test('rejects a vaccination record without an administered date', () async {
      const childId = 'child-1';
      await insertChild(childId);

      expect(
        () => vaccinationRecordsDao.insertVaccinationRecord(
          const VaccinationRecordsCompanion(
            id: Value('record-1'),
            childId: Value(childId),
            vaccineCode: Value('BCG'),
            doseNumber: Value(1),
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    group('NIP', () {
      test('looks up the due age of an existing vaccine dose', () {
        const vaccine = 'PENTA';
        const dose = 2;
        final age = getDoseAge(vaccine, dose);

        expect(age?.duration, DayDuration(weeks: 10).duration);
      });

      test('returns null for a nonexisting vaccine dose', () {
        const vaccine = "BCG";
        const dose = 2;
        final age = getDoseAge(vaccine, dose);

        expect(age, null);

        const vaccineFake = "FAKE";
        const doseFake = 1;
        final ageFake = getDoseAge(vaccineFake, doseFake);

        expect(ageFake, null);
      });

      test('accepts a vaccination record with a valid code and dose', () async {
        // this is identical to a previous test, should it remain?
        const childId = 'child-1';
        await insertChild(childId);

        await vaccinationRecordsDao.insertVaccinationRecord(
          VaccinationRecordsCompanion.insert(
            id: 'record-1',
            childId: childId,
            vaccineCode: 'BCG',
            doseNumber: 1,
            administeredDate: DateTime(2023, 4, 16),
          ),
        );

        final records = await recordsFor(childId);
        expect(records, hasLength(1));
        expect(records.single.id, 'record-1');
      });

      test('rejects a vaccination record with an invalid code', () async {
        const childId = 'child-1';
        await insertChild(childId);

        expect(
            () => vaccinationRecordsDao.insertVaccinationRecord(
                  VaccinationRecordsCompanion.insert(
                    id: 'record-1',
                    childId: childId,
                    vaccineCode: 'BCGFAKE',
                    doseNumber: 1,
                    administeredDate: DateTime(2023, 4, 16),
                  ),
                ),
            throwsA(isA<Exception>()));
      });

      test('rejects a vaccination record with a valid code but invalid dose',
          () async {
        const childId = 'child-1';
        await insertChild(childId);

        expect(
            () => vaccinationRecordsDao.insertVaccinationRecord(
                  VaccinationRecordsCompanion.insert(
                    id: 'record-1',
                    childId: childId,
                    vaccineCode: 'BCG',
                    doseNumber: 2,
                    administeredDate: DateTime(2023, 4, 16),
                  ),
                ),
            throwsA(isA<Exception>()));
      });
    });
  });
}
