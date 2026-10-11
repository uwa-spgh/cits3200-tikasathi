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

  /// When the reminder was settled: raised to the caregiver, or retired so it
  /// never is. Null while still pending.
  DateTimeColumn get deliveredAt => dateTime().nullable()();

  /// When the reminder was last queued with the device's notification system.
  /// Null when the device is not holding it.
  ///
  /// The device drops a reminder from its queue once it has shown it, so a
  /// reminder that was queued and has since left the queue has already been
  /// seen, and the catch-up on launch must not raise it a second time.
  DateTimeColumn get registeredAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {notificationId},
        {dueId, kind, scheduledFor},
      ];
}
