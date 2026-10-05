part of '../app_database.dart';

class ManualVaccinationScheduleOverrides extends Table {
  TextColumn get id => text()();

  TextColumn get childId => text().references(ChildProfiles, #id)();

  TextColumn get vaccineCode => text()();

  IntColumn get doseNumber => integer()();

  DateTimeColumn get dueDate => dateTime().nullable()();

  BoolColumn get isRemoved => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {childId, vaccineCode, doseNumber},
      ];
}
