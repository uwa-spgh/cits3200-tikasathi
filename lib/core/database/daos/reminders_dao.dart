part of '../app_database.dart';

@DriftAccessor(tables: [Reminders, VaccinationDues])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  /// Replaces the reminders for the due identified by [dueId] with the ones
  /// [planReminders] derives from that due's date.
  ///
  /// Safe to call again for a due that already has reminders, which is what
  /// rescheduling after a reboot or a device clock change relies on. Reminders
  /// already in the past as at [from] are not scheduled.
  Future<List<Reminder>> scheduleRemindersForDue(
    String dueId, {
    DateTime? from,
  }) {
    return transaction(() async {
      final due = await (select(vaccinationDues)
            ..where((row) => row.id.equals(dueId)))
          .getSingleOrNull();
      if (due == null) {
        throw Exception('no vaccination due with id $dueId');
      }

      await (delete(reminders)..where((row) => row.dueId.equals(dueId))).go();

      int notificationId = await _nextNotificationId();
      final rows = <RemindersCompanion>[
        for (final planned in planReminders(due.dueDate, from: from))
          RemindersCompanion.insert(
            id: const Uuid().v4(),
            childId: due.childId,
            dueId: due.id,
            kind: planned.kind,
            scheduledFor: planned.scheduledFor,
            notificationId: notificationId++,
          ),
      ];
      await batch((batch) => batch.insertAll(reminders, rows));

      return _remindersForDue(dueId);
    });
  }

  /// Drops the reminders for a due, e.g. once the dose has been recorded.
  Future<int> deleteRemindersForDue(String dueId) {
    return (delete(reminders)..where((row) => row.dueId.equals(dueId))).go();
  }

  Future<int> deleteRemindersForChild(String childId) {
    return (delete(reminders)..where((row) => row.childId.equals(childId)))
        .go();
  }

  Stream<List<Reminder>> watchRemindersForChild(String childId) {
    return (select(reminders)
          ..where((row) => row.childId.equals(childId))
          ..orderBy([(row) => OrderingTerm.asc(row.scheduledFor)]))
        .watch();
  }

  /// Reminders not yet handed to the device, soonest first.
  ///
  /// Use this on startup to re-register reminders with the operating system.
  Future<List<Reminder>> getPendingReminders() {
    return (select(reminders)
          ..where((row) => row.deliveredAt.isNull())
          ..orderBy([(row) => OrderingTerm.asc(row.scheduledFor)]))
        .get();
  }

  /// Pending reminders that were due at or before [instant], soonest first.
  ///
  /// Covers reminders the device never raised, for instance because it was off
  /// or its clock moved forward past the scheduled time.
  Future<List<Reminder>> getPendingRemindersDueBy(DateTime instant) {
    return (select(reminders)
          ..where(
            (row) =>
                row.deliveredAt.isNull() &
                row.scheduledFor.isSmallerOrEqualValue(instant),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.scheduledFor)]))
        .get();
  }

  Future<int> markReminderDelivered(String id, {DateTime? deliveredAt}) {
    return (update(reminders)..where((row) => row.id.equals(id))).write(
      RemindersCompanion(
        deliveredAt: Value(deliveredAt ?? DateTime.now()),
      ),
    );
  }

  Future<List<Reminder>> _remindersForDue(String dueId) {
    return (select(reminders)
          ..where((row) => row.dueId.equals(dueId))
          ..orderBy([(row) => OrderingTerm.asc(row.scheduledFor)]))
        .get();
  }

  /// Notification ids are handed to the device, so they must be unique across
  /// the whole table rather than per child or per due.
  Future<int> _nextNotificationId() async {
    final highest = reminders.notificationId.max();
    final row =
        await (selectOnly(reminders)..addColumns([highest])).getSingle();
    return (row.read(highest) ?? 0) + 1;
  }
}
