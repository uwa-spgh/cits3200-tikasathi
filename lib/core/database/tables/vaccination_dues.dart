part of '../app_database.dart';

class VaccinationDues extends Table {
  TextColumn get id => text()();

  TextColumn get childId => text().references(ChildProfiles, #id)();

  TextColumn get vaccineCode => text()();

  IntColumn get doseNumber => integer()();

  DateTimeColumn get dueDate => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {childId, vaccineCode, doseNumber},
      ];
}
