part of '../app_database.dart';

class VaccinationRecords extends Table {
  TextColumn get id => text()();

  TextColumn get childId => text().references(ChildProfiles, #id)();

  TextColumn get vaccineCode => text()();

  IntColumn get doseNumber => integer()();

  DateTimeColumn get administeredDate => dateTime()();

  TextColumn get facilityName => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {childId, vaccineCode, doseNumber},
      ];
}
