import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/features/record_dose/domain/record_dose_controller.dart';

void main() {
  group('RecordDoseController', () {
    const String childId = 'child-1';
    late AppDatabase database;
    late ProviderContainer container;
    late DateTime today;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      final DateTime now = DateTime.now();
      today = DateTime(now.year, now.month, now.day);

      await database.childProfilesDao.insertChildProfile(
        ChildProfilesCompanion.insert(
          id: childId,
          name: 'Aarav',
          dateOfBirth: today.subtract(const Duration(days: 90)),
          sex: 'male',
        ),
      );

      container = ProviderContainer(
        overrides: <Override>[
          appDatabaseProvider.overrideWithValue(database),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    Future<void> insertDue(
      String id,
      String vaccineCode,
      int doseNumber,
      DateTime dueDate,
    ) {
      return database.vaccinationDuesDao.insertVaccinationDue(
        VaccinationDuesCompanion.insert(
          id: id,
          childId: childId,
          vaccineCode: vaccineCode,
          doseNumber: doseNumber,
          dueDate: dueDate,
        ),
      );
    }

    Future<RecordDoseState> readState() =>
        container.read(recordDoseControllerProvider(childId).future);

    RecordDoseController controller() =>
        container.read(recordDoseControllerProvider(childId).notifier);

    test('defaults the administered date to today with nothing selected',
        () async {
      await insertDue('due-1', 'PENTA', 1, today);

      final RecordDoseState state = await readState();

      expect(state.administeredDate, today);
      expect(state.selectedCount, 0);
      expect(state.canSave, isFalse);
      expect(state.showAllUpcoming, isFalse);
    });

    test('separates doses owed today from doses not yet due', () async {
      await insertDue(
          'due-overdue', 'PENTA', 1, today.subtract(const Duration(days: 7)));
      await insertDue('due-today', 'BOPV', 1, today);
      await insertDue(
          'due-later', 'MR', 1, today.add(const Duration(days: 200)));

      final RecordDoseState state = await readState();

      expect(
        state.actionableDues.map((VaccinationDue due) => due.id),
        <String>['due-overdue', 'due-today'],
      );
      expect(
        state.upcomingDues.map((VaccinationDue due) => due.id),
        <String>['due-later'],
      );
      expect(state.visibleDues.length, 2);
      expect(state.isOverdue(state.actionableDues.first), isTrue);
      expect(state.isOverdue(state.actionableDues.last), isFalse);
    });

    test('shows the whole schedule once upcoming doses are revealed', () async {
      await insertDue('due-today', 'BOPV', 1, today);
      await insertDue(
          'due-later', 'MR', 1, today.add(const Duration(days: 200)));
      await readState();

      controller().setShowAllUpcoming(true);

      expect(
          container
              .read(recordDoseControllerProvider(childId))
              .value!
              .visibleDues
              .length,
          2);
    });

    test('drops a ticked upcoming dose when upcoming doses are hidden',
        () async {
      await insertDue('due-today', 'BOPV', 1, today);
      await insertDue(
          'due-later', 'MR', 1, today.add(const Duration(days: 200)));
      await readState();

      controller()
        ..setShowAllUpcoming(true)
        ..toggleDose('due-today')
        ..toggleDose('due-later')
        ..setShowAllUpcoming(false);

      final RecordDoseState state =
          container.read(recordDoseControllerProvider(childId)).value!;
      expect(state.selectedDueIds, <String>{'due-today'});
    });

    test('toggling the same dose twice clears the selection', () async {
      await insertDue('due-today', 'BOPV', 1, today);
      await readState();

      controller()
        ..toggleDose('due-today')
        ..toggleDose('due-today');

      expect(
        container.read(recordDoseControllerProvider(childId)).value!.canSave,
        isFalse,
      );
    });

    test('saving records the ticked doses and settles their dues', () async {
      await insertDue('due-1', 'PENTA', 1, today);
      await insertDue('due-2', 'BOPV', 1, today);
      await insertDue('due-3', 'PCV', 1, today);
      await readState();

      controller()
        ..toggleDose('due-1')
        ..toggleDose('due-2')
        ..setAdministeredDate(today.subtract(const Duration(days: 2)));

      final bool saved = await controller().save();

      expect(saved, isTrue);

      final List<VaccinationRecord> records = await database
          .vaccinationRecordsDao
          .watchVaccinationRecordsForChild(childId)
          .first;
      expect(
        records.map((VaccinationRecord record) => record.vaccineCode).toSet(),
        <String>{'PENTA', 'BOPV'},
      );
      expect(
        records.every((VaccinationRecord record) =>
            record.administeredDate == today.subtract(const Duration(days: 2))),
        isTrue,
      );

      final List<VaccinationDue> remainingDues = await database
          .vaccinationDuesDao
          .watchVaccinationDuesForChild(childId)
          .first;
      expect(
        remainingDues.map((VaccinationDue due) => due.id),
        <String>['due-3'],
      );
    });

    test('saving with nothing ticked does nothing', () async {
      await insertDue('due-1', 'PENTA', 1, today);
      await readState();

      expect(await controller().save(), isFalse);

      final List<VaccinationRecord> records = await database
          .vaccinationRecordsDao
          .watchVaccinationRecordsForChild(childId)
          .first;
      expect(records, isEmpty);
    });
  });
}
