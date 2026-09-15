import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/home/domain/home_status_groups_provider.dart';

part 'record_dose_controller.g.dart';

/// The state of the "log a dose" screen for a single child.
///
/// [dues] holds every outstanding dose for the child, which is the child's
/// whole remaining schedule — not only the doses owed today. The screen shows
/// [visibleDues] so a caregiver sees the short, actionable list first and can
/// reveal the rest with [showAllUpcoming].
@immutable
class RecordDoseState {
  const RecordDoseState({
    required this.child,
    required this.dues,
    required this.administeredDate,
    required this.today,
    this.selectedDueIds = const <String>{},
    this.showAllUpcoming = false,
  });

  final ChildProfile child;

  /// Every outstanding dose for the child, soonest due first.
  final List<VaccinationDue> dues;

  /// The date written to every [VaccinationRecord] saved in this session.
  /// A clinic visit happens on one day, so the whole batch shares a date.
  final DateTime administeredDate;

  final DateTime today;
  final Set<String> selectedDueIds;
  final bool showAllUpcoming;

  /// Doses owed today or overdue, soonest first.
  List<VaccinationDue> get actionableDues => _sortedDues
      .where(
          (VaccinationDue due) => !_dateOnly(due.dueDate).isAfter(_todayOnly))
      .toList();

  /// Doses not yet owed, soonest first.
  List<VaccinationDue> get upcomingDues => _sortedDues
      .where((VaccinationDue due) => _dateOnly(due.dueDate).isAfter(_todayOnly))
      .toList();

  List<VaccinationDue> get visibleDues =>
      showAllUpcoming ? _sortedDues : actionableDues;

  int get selectedCount => selectedDueIds.length;

  bool get canSave => selectedDueIds.isNotEmpty;

  bool isSelected(String dueId) => selectedDueIds.contains(dueId);

  /// True when the dose was scheduled before today and has not been given.
  bool isOverdue(VaccinationDue due) =>
      _dateOnly(due.dueDate).isBefore(_todayOnly);

  /// True when [date] falls on the day the screen was opened.
  bool isToday(DateTime date) => _dateOnly(date) == _todayOnly;

  List<VaccinationDue> get _sortedDues => List<VaccinationDue>.from(dues)
    ..sort(
        (VaccinationDue a, VaccinationDue b) => a.dueDate.compareTo(b.dueDate));

  DateTime get _todayOnly => _dateOnly(today);

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  RecordDoseState copyWith({
    List<VaccinationDue>? dues,
    DateTime? administeredDate,
    Set<String>? selectedDueIds,
    bool? showAllUpcoming,
  }) {
    return RecordDoseState(
      child: child,
      dues: dues ?? this.dues,
      administeredDate: administeredDate ?? this.administeredDate,
      today: today,
      selectedDueIds: selectedDueIds ?? this.selectedDueIds,
      showAllUpcoming: showAllUpcoming ?? this.showAllUpcoming,
    );
  }
}

/// Drives the screen where a caregiver logs doses a child has just been given.
///
/// Saving is delegated to [VaccinationRecordsDao.insertVaccinationRecord],
/// which also clears the settled due and any reminders scheduled for it.
@riverpod
class RecordDoseController extends _$RecordDoseController {
  @override
  Future<RecordDoseState> build(String childId) async {
    final AppDatabase database = ref.watch(appDatabaseProvider);
    final ChildProfile? child =
        await database.childProfilesDao.getChildProfileById(childId);

    if (child == null) {
      throw StateError('Child profile not found');
    }

    final List<VaccinationDue> dues = await database.vaccinationDuesDao
        .getVaccinationDuesForChild(childId)
      ..sort((VaccinationDue a, VaccinationDue b) =>
          a.dueDate.compareTo(b.dueDate));
    final DateTime now = DateTime.now();

    return RecordDoseState(
      child: child,
      dues: dues,
      administeredDate: DateTime(now.year, now.month, now.day),
      today: now,
    );
  }

  void toggleDose(String dueId) {
    _update((RecordDoseState current) {
      final Set<String> selected = Set<String>.from(current.selectedDueIds);
      if (!selected.remove(dueId)) {
        selected.add(dueId);
      }
      return current.copyWith(selectedDueIds: selected);
    });
  }

  void setAdministeredDate(DateTime date) {
    _update((RecordDoseState current) => current.copyWith(
          administeredDate: DateTime(date.year, date.month, date.day),
        ));
  }

  void setShowAllUpcoming(bool showAll) {
    _update((RecordDoseState current) {
      if (showAll) {
        return current.copyWith(showAllUpcoming: true);
      }

      // Hiding upcoming doses must not silently keep a hidden dose ticked.
      final Set<String> visibleIds =
          current.actionableDues.map((VaccinationDue due) => due.id).toSet();
      return current.copyWith(
        showAllUpcoming: false,
        selectedDueIds: current.selectedDueIds.intersection(visibleIds),
      );
    });
  }

  /// Writes a [VaccinationRecord] for every ticked dose.
  ///
  /// The whole batch is one transaction: a clinic visit either lands in full or
  /// not at all. A partial write would leave records the caregiver cannot
  /// reconcile, and retrying would fail forever on the unique key over
  /// (child, vaccine, dose).
  ///
  /// Returns false and leaves the error on [state] if the batch fails, keeping
  /// the previous data so the screen stays usable.
  Future<bool> save() async {
    final RecordDoseState? current = state.valueOrNull;
    if (current == null || !current.canSave) {
      return false;
    }

    final List<VaccinationDue> selected = current.dues
        .where((VaccinationDue due) => current.isSelected(due.id))
        .toList();

    state = const AsyncLoading<RecordDoseState>().copyWithPrevious(state);
    try {
      final AppDatabase database = ref.read(appDatabaseProvider);
      await database.transaction(() async {
        for (final VaccinationDue due in selected) {
          await database.vaccinationRecordsDao.insertVaccinationRecord(
            VaccinationRecordsCompanion.insert(
              id: const Uuid().v4(),
              childId: current.child.id,
              vaccineCode: due.vaccineCode,
              doseNumber: due.doseNumber,
              administeredDate: current.administeredDate,
            ),
          );
        }
      });

      ref.invalidate(homeStatusGroupsProvider);
      ref.invalidate(childProfileProvider(current.child.id));
      state = AsyncData<RecordDoseState>(
        current.copyWith(selectedDueIds: const <String>{}),
      );
      return true;
    } catch (error, stackTrace) {
      // Carry the loaded data onto the error so the screen keeps its ticks and
      // its way back out; the failure is reported by the caller's snackbar.
      // Stated explicitly rather than leaning on Riverpod retaining the value
      // for us, so the screen's `skipError` does not depend on a detail that
      // is easy to miss here.
      state = AsyncError<RecordDoseState>(error, stackTrace)
          .copyWithPrevious(state);
      return false;
    }
  }

  void _update(RecordDoseState Function(RecordDoseState current) transform) {
    final RecordDoseState? current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData<RecordDoseState>(transform(current));
  }
}
