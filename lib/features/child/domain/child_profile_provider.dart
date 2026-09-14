import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/home/domain/home_helpers.dart';

part 'child_profile_provider.g.dart';

@immutable
class ChildProfileDetails {
  const ChildProfileDetails({
    required this.child,
    required this.dueVaccines,
    required this.records,
    required this.now,
  });

  final ChildProfile child;
  final List<VaccinationDue> dueVaccines;
  final List<VaccinationRecord> records;
  final DateTime now;

  bool get isSetupComplete => child.isSetupComplete;

  bool get allDosesCompleted => dueVaccines.isEmpty;

  DateTime get _today => DateTime(now.year, now.month, now.day);

  bool get hasOverdueDoses => dueVaccines.any((due) {
        final dueDate =
            DateTime(due.dueDate.year, due.dueDate.month, due.dueDate.day);
        return dueDate.isBefore(_today);
      });

  bool get hasDosesDueToday => dueVaccines.any((due) {
        final dueDate =
            DateTime(due.dueDate.year, due.dueDate.month, due.dueDate.day);
        return dueDate.isAtSameMomentAs(_today);
      });

  bool get hasDosesDueSoon => dueVaccines.any((due) {
        final dueDate =
            DateTime(due.dueDate.year, due.dueDate.month, due.dueDate.day);
        final diff = dueDate.difference(_today).inDays;
        return diff > 0 && diff <= 14;
      });

  /// The child is Up To Date if they have no overdue doses and no doses due today.
  bool get isUpToDate =>
      dueVaccines.isEmpty ||
      (isSetupComplete && !hasOverdueDoses && !hasDosesDueToday);

  List<VaccinationDue> get orderedDueVaccines =>
      List<VaccinationDue>.from(dueVaccines)
        ..sort((VaccinationDue a, VaccinationDue b) =>
            a.dueDate.compareTo(b.dueDate));

  bool get isDueToday => hasDosesDueToday;

  VaccinationDue? get nextDue =>
      dueVaccines.isEmpty ? null : orderedDueVaccines.first;

  VaccinationDue? get followingDue =>
      orderedDueVaccines.length > 1 ? orderedDueVaccines[1] : null;

  String ageLabel(AppLocalizations localizations) =>
      formatAge(child.dateOfBirth, localizations);

  String get avatarEmoji => getChildAvatar(
        sex: childSexFromString(child.sex),
        dateOfBirth: child.dateOfBirth,
      );
}

@riverpod
Future<ChildProfileDetails> childProfile(
  ChildProfileRef ref,
  String childId,
) async {
  final AppDatabase database = ref.watch(appDatabaseProvider);
  final ChildProfile? profile =
      await database.childProfilesDao.getChildProfileById(childId);

  if (profile == null) {
    throw StateError('Child profile not found');
  }

  final List<VaccinationDue> dueVaccines = await database.vaccinationDuesDao
      .watchVaccinationDuesForChild(childId)
      .first;
  final List<VaccinationRecord> records = await database.vaccinationRecordsDao
      .watchVaccinationRecordsForChild(childId)
      .first;

  return ChildProfileDetails(
    child: profile,
    dueVaccines: dueVaccines,
    records: records,
    now: DateTime.now(),
  );
}
