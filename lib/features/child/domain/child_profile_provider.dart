import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
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

  bool get isUpToDate => dueVaccines.isEmpty;

  bool get isDueToday {
    if (dueVaccines.isEmpty) {
      return false;
    }

    final nextDue = (List<VaccinationDue>.from(dueVaccines)
          ..sort((VaccinationDue a, VaccinationDue b) =>
              a.dueDate.compareTo(b.dueDate)))
        .first;
    final nextDueDate = DateTime(
      nextDue.dueDate.year,
      nextDue.dueDate.month,
      nextDue.dueDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    return !nextDueDate.isAfter(today);
  }

  VaccinationDue? get nextDue => dueVaccines.isEmpty
      ? null
      : (List<VaccinationDue>.from(dueVaccines)
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate)))
          .first;

  String get ageLabel => formatAge(child.dateOfBirth);

  String get avatarEmoji => getChildAvatar(
        sex: _sexFromString(child.sex),
        dateOfBirth: child.dateOfBirth,
      );

  ChildSex _sexFromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return ChildSex.male;
      case 'female':
        return ChildSex.female;
      default:
        return ChildSex.female;
    }
  }
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
