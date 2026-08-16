part of '../app_database.dart';

class ChildProfiles extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  DateTimeColumn get dateOfBirth => dateTime()();

  TextColumn get sex => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
