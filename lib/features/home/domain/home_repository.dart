import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/features/home/domain/home_helpers.dart';
import 'package:tikasathi/features/home/domain/home_models.dart';

class HomeRepository {
  const HomeRepository(this._database);

  final AppDatabase _database;

  Future<List<HomeStatusGroup>> loadHomeStatusGroups({DateTime? now}) async {
    final DateTime currentTime = now ?? DateTime.now();
    final profiles =
        await _database.childProfilesDao.streamAllChildProfiles().first;

    if (profiles.isEmpty) {
      return const <HomeStatusGroup>[];
    }

    final Map<HomeVaccinationGroup, List<HomeChildSummary>> groupedChildren = {
      HomeVaccinationGroup.dueToday: <HomeChildSummary>[],
      HomeVaccinationGroup.dueSoon: <HomeChildSummary>[],
      HomeVaccinationGroup.upToDate: <HomeChildSummary>[],
    };

    for (final profile in profiles) {
      final dueRows = await _database.vaccinationDuesDao
          .watchVaccinationDuesForChild(profile.id)
          .first;

      final List<VaccinationDue> outstandingDues = dueRows;

      final status = _describeStatus(outstandingDues, currentTime);
      final vaccineLabel = _nextVaccineLabel(outstandingDues, currentTime);
      final child = HomeChildSummary(
        name: profile.name,
        ageLabel: formatAge(profile.dateOfBirth),
        vaccineLabel: vaccineLabel,
        avatarEmoji: getChildAvatar(
          sex: _sexFromString(profile.sex),
          dateOfBirth: profile.dateOfBirth,
        ),
        canRecordVaccine: status != HomeVaccinationGroup.upToDate,
        canFindClinic: status != HomeVaccinationGroup.upToDate,
      );

      groupedChildren[status]!.add(child);
    }

    final statusGroups = <HomeStatusGroup>[];
    for (final group in <HomeVaccinationGroup>[
      HomeVaccinationGroup.dueToday,
      HomeVaccinationGroup.dueSoon,
      HomeVaccinationGroup.upToDate,
    ]) {
      final children = groupedChildren[group]!;
      if (children.isEmpty) {
        continue;
      }

      statusGroups.add(
        HomeStatusGroup(
          group: group,
          headerLabel: _groupHeaderLabel(group),
          children: children,
        ),
      );
    }

    return statusGroups;
  }

  HomeVaccinationGroup _describeStatus(
    List<VaccinationDue> dueRows,
    DateTime now,
  ) {
    if (dueRows.isEmpty) {
      return HomeVaccinationGroup.upToDate;
    }

    final nowDate = DateTime(now.year, now.month, now.day);

    // Any due date on or before today counts as due TODAY (covers overdue)
    final hasDueToday = dueRows.any((VaccinationDue due) {
      final dueDate = DateTime(
        due.dueDate.year,
        due.dueDate.month,
        due.dueDate.day,
      );
      return !dueDate.isAfter(nowDate); // dueDate <= nowDate
    });

    if (hasDueToday) {
      return HomeVaccinationGroup.dueToday;
    }

    // Due soon: strictly after today and within the next 14 calendar days
    final hasDueSoon = dueRows.any((VaccinationDue due) {
      final dueDate = DateTime(
        due.dueDate.year,
        due.dueDate.month,
        due.dueDate.day,
      );
      final difference = dueDate.difference(nowDate).inDays;
      return difference > 0 && difference <= 14;
    });

    if (hasDueSoon) {
      return HomeVaccinationGroup.dueSoon;
    }

    return HomeVaccinationGroup.upToDate;
  }

  String _nextVaccineLabel(List<VaccinationDue> dueRows, DateTime now) {
    if (dueRows.isEmpty) {
      return 'Up to date';
    }

    final sortedDues = List<VaccinationDue>.from(dueRows)
      ..sort((VaccinationDue a, VaccinationDue b) =>
          a.dueDate.compareTo(b.dueDate));
    final nextDue = sortedDues.first;
    return nextDue.vaccineCode;
  }

  String _groupHeaderLabel(HomeVaccinationGroup group) {
    switch (group) {
      case HomeVaccinationGroup.dueToday:
        return 'Vaccine due TODAY';
      case HomeVaccinationGroup.dueSoon:
        return 'Due in 2 weeks';
      case HomeVaccinationGroup.upToDate:
        return 'All up to date';
    }
  }

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
