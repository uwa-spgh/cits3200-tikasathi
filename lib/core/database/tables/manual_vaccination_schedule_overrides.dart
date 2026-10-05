part of '../app_database.dart';

class ManualVaccinationScheduleOverrides extends Table {
  TextColumn get id => text()();

  TextColumn get childId => text().references(ChildProfiles, #id)();

  TextColumn get sourceVaccineCode => text()();

  IntColumn get sourceDoseNumber => integer()();

  TextColumn get vaccineCode => text()();

  IntColumn get doseNumber => integer()();

  DateTimeColumn get dueDate => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {childId, sourceVaccineCode, sourceDoseNumber},
        {childId, vaccineCode, doseNumber},
      ];
}
