part of '../app_database.dart';

@DriftAccessor(tables: [Reminders, VaccinationDues])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  /// Replaces the reminders for the due identified by [dueId] with the ones
  /// [planReminders] derives from that due's date.
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

  /// Replaces every reminder the child has with ones derived from the child's
  /// current dues.
  ///
  /// Planning the whole child at once keeps the notification ids in one run
  /// rather than restarting the sequence per due.
  Future<List<Reminder>> scheduleRemindersForChild(
    String childId, {
    DateTime? from,
  }) {
    return transaction(() async {
      final dues = await (select(vaccinationDues)
            ..where((row) => row.childId.equals(childId)))
          .get();

      await (delete(reminders)..where((row) => row.childId.equals(childId)))
          .go();

      int notificationId = await _nextNotificationId();
      final rows = <RemindersCompanion>[
        for (final due in dues)
          for (final planned in planReminders(due.dueDate, from: from))
            RemindersCompanion.insert(
              id: const Uuid().v4(),
              childId: childId,
              dueId: due.id,
              kind: planned.kind,
              scheduledFor: planned.scheduledFor,
              notificationId: notificationId++,
            ),
      ];
      await batch((batch) => batch.insertAll(reminders, rows));

      return _remindersForChild(childId);
    });
  }

  /// Adds a single reminder for [dueId] at [scheduledFor].
  ///
  /// Lets a reminder be raised through the normal pipeline without waiting for
  /// a due date to come round, which is otherwise impossible to observe.
  Future<Reminder> insertReminderAt({
    required String dueId,
    required DateTime scheduledFor,
    ReminderKind kind = ReminderKind.sameDay,
  }) {
    return transaction(() async {
      final due = await (select(vaccinationDues)
            ..where((row) => row.id.equals(dueId)))
          .getSingleOrNull();
      if (due == null) {
        throw Exception('no vaccination due with id $dueId');
      }

      final String id = const Uuid().v4();
      await into(reminders).insert(
        RemindersCompanion.insert(
          id: id,
          childId: due.childId,
          dueId: due.id,
          kind: kind,
          scheduledFor: scheduledFor,
          notificationId: await _nextNotificationId(),
        ),
      );

      return (select(reminders)..where((row) => row.id.equals(id))).getSingle();
    });
  }

  /// drops the reminders for a due (e.g. once the dose has been recorded)
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

  /// The soonest [limit] reminders still waiting to be handed to the device.
  ///
  /// iOS keeps at most 64 pending local notifications, so only a window of the
  /// table is ever registered with the device.
  Stream<List<Reminder>> watchPendingReminders({required int limit}) {
    return (select(reminders)
          ..where((row) => row.deliveredAt.isNull())
          ..orderBy([(row) => OrderingTerm.asc(row.scheduledFor)])
          ..limit(limit))
        .watch();
  }

  /// Reminders not yet handed to the device, soonest first.
  ///
  /// [limit] is the window the device can hold. Later rows stay in the table.
  Future<List<Reminder>> getPendingReminders({int? limit}) {
    final query = select(reminders)
      ..where((row) => row.deliveredAt.isNull())
      ..orderBy([(row) => OrderingTerm.asc(row.scheduledFor)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  /// Pending reminders that were due at or before [instant], soonest first.

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

  /// Marks a batch as delivered in one statement.
  ///
  /// A dose missed for a while leaves many reminders behind, so they are
  /// settled together rather than one round trip each.
  Future<int> markRemindersDelivered(
    List<String> ids, {
    DateTime? deliveredAt,
  }) {
    if (ids.isEmpty) {
      return Future<int>.value(0);
    }
    return (update(reminders)..where((row) => row.id.isIn(ids))).write(
      RemindersCompanion(
        deliveredAt: Value(deliveredAt ?? DateTime.now()),
      ),
    );
  }

  Future<int> markReminderDelivered(String id, {DateTime? deliveredAt}) {
    return (update(reminders)..where((row) => row.id.equals(id))).write(
      RemindersCompanion(
        deliveredAt: Value(deliveredAt ?? DateTime.now()),
      ),
    );
  }

  Future<List<Reminder>> _remindersForChild(String childId) {
    return (select(reminders)
          ..where((row) => row.childId.equals(childId))
          ..orderBy([(row) => OrderingTerm.asc(row.scheduledFor)]))
        .get();
  }

  Future<List<Reminder>> _remindersForDue(String dueId) {
    return (select(reminders)
          ..where((row) => row.dueId.equals(dueId))
          ..orderBy([(row) => OrderingTerm.asc(row.scheduledFor)]))
        .get();
  }

  /// Notification ids are handed to the device, so they must be unique across
  /// the whole table rather than per child or per due.
  ///
  /// max+1 is safe here because the app opens a single connection to the
  /// SQLite file (see `_openConnection` in app_database.dart), so drift
  /// serializes every statement onto it — there is no concurrent writer to
  /// race against. The `notificationId` unique key is a backstop if that
  /// ever stops being true.
  Future<int> _nextNotificationId() async {
    final highest = reminders.notificationId.max();
    final row =
        await (selectOnly(reminders)..addColumns([highest])).getSingle();
    return (row.read(highest) ?? 0) + 1;
  }
}
