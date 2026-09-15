part of '../app_database.dart';

/// The single app-level health facilitator saved by the user.
class HealthFacilitators extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().nullable()();

  TextColumn get address => text().nullable()();

  TextColumn get phone => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
