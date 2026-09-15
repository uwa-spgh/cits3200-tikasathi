part of '../app_database.dart';

/// Device reminders raised for a vaccination due.
///
/// Reminders are persisted rather than left to the operating system alone, so
/// they survive restarts and can be re-registered after a reboot or a device
/// clock change.
class Reminders extends Table {
  TextColumn get id => text()();

  TextColumn get childId => text().references(ChildProfiles, #id)();

  TextColumn get dueId => text().references(VaccinationDues, #id)();

  /// Which reminder rule produced this row. See [ReminderKind].
  TextColumn get kind => textEnum<ReminderKind>()();

  DateTimeColumn get scheduledFor => dateTime()();

  /// The id this reminder is registered under with the device's notification
  /// system. Unique so a reminder can be cancelled without ambiguity.
  IntColumn get notificationId => integer()();

  /// When the reminder was handed to the device. Null while still pending.
  DateTimeColumn get deliveredAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {notificationId},
        {dueId, kind, scheduledFor},
      ];
}
