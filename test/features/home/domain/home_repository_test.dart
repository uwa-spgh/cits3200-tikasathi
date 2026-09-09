import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/features/home/domain/home_models.dart';
import 'package:tikasathi/features/home/domain/home_repository.dart';

void main() {
  group('HomeRepository _describeStatus via loadHomeStatusGroups', () {
    final now = DateTime(2026, 8, 22); // fixed date for deterministic tests

    late AppDatabase database;
    late HomeRepository repository;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = HomeRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('no dues => upToDate', () async {
      // insert a child with no dues
      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'c1',
          name: 'Test',
          dateOfBirth: DateTime(2025, 1, 1),
          sex: 'female',
        ),
      );

      final groups = await repository.loadHomeStatusGroups(now: now);
      expect(groups.length, 1);
      expect(groups.single.group, HomeVaccinationGroup.upToDate);
    });

    test('preserves persisted male sex and avatar in the Home summary',
        () async {
      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'male-child',
          name: 'Nima',
          dateOfBirth: DateTime(2020, 1, 1),
          sex: 'male',
        ),
      );

      final groups = await repository.loadHomeStatusGroups(now: now);
      final child = groups.single.children.single;

      expect(child.sex, 'male');
      expect(child.avatarEmoji, '👦');
    });

    test('preserves persisted female sex and avatar in the Home summary',
        () async {
      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'female-child',
          name: 'Maya',
          dateOfBirth: DateTime(2020, 1, 1),
          sex: 'female',
        ),
      );

      final groups = await repository.loadHomeStatusGroups(now: now);
      final child = groups.single.children.single;

      expect(child.sex, 'female');
      expect(child.avatarEmoji, '👧');
    });

    test('keeps the infant avatar for a persisted male child', () async {
      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'infant-child',
          name: 'Asha',
          dateOfBirth: DateTime(2026, 7, 1),
          sex: 'male',
        ),
      );

      final groups = await repository.loadHomeStatusGroups(now: now);

      expect(groups.single.children.single.avatarEmoji, '👶');
    });

    test('uses the neutral avatar for an unknown persisted sex', () async {
      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'unknown-child',
          name: 'Ravi',
          dateOfBirth: DateTime(2020, 1, 1),
          sex: 'unknown',
        ),
      );

      final groups = await repository.loadHomeStatusGroups(now: now);

      expect(groups.single.children.single.sex, 'unknown');
      expect(groups.single.children.single.avatarEmoji, '🧒');
    });

    test('overdue due date is classified as dueToday (not upToDate)', () async {
      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'c1',
          name: 'Test',
          dateOfBirth: DateTime(2025, 1, 1),
          sex: 'female',
        ),
      );

      await database.vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'd1',
          childId: 'c1',
          vaccineCode: 'BCG',
          doseNumber: 1,
          dueDate: DateTime(2026, 8, 20),
        ),
      );

      final groups = await repository.loadHomeStatusGroups(now: now);
      expect(groups.length, 1);
      expect(groups.single.group, HomeVaccinationGroup.dueToday);
    });

    test('due today => dueToday', () async {
      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'c1',
          name: 'Test',
          dateOfBirth: DateTime(2025, 1, 1),
          sex: 'female',
        ),
      );

      await database.vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'd2',
          childId: 'c1',
          vaccineCode: 'BOPV',
          doseNumber: 1,
          dueDate: DateTime(2026, 8, 22),
        ),
      );

      final groups = await repository.loadHomeStatusGroups(now: now);
      expect(groups.length, 1);
      expect(groups.single.group, HomeVaccinationGroup.dueToday);
    });

    test('due within 14 days after today => dueSoon', () async {
      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'c1',
          name: 'Test',
          dateOfBirth: DateTime(2025, 1, 1),
          sex: 'female',
        ),
      );

      await database.vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'd3',
          childId: 'c1',
          vaccineCode: 'PENTA',
          doseNumber: 1,
          dueDate: DateTime(2026, 8, 30),
        ),
      );

      final groups = await repository.loadHomeStatusGroups(now: now);
      expect(groups.length, 1);
      expect(groups.single.group, HomeVaccinationGroup.dueSoon);
    });

    test('due after 14 days => upToDate', () async {
      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: 'c1',
          name: 'Test',
          dateOfBirth: DateTime(2025, 1, 1),
          sex: 'female',
        ),
      );

      await database.vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: 'd4',
          childId: 'c1',
          vaccineCode: 'MR',
          doseNumber: 1,
          dueDate: DateTime(2026, 9, 10),
        ),
      );

      final groups = await repository.loadHomeStatusGroups(now: now);
      expect(groups.length, 1);
      expect(groups.single.group, HomeVaccinationGroup.upToDate);
    });
  });
}
