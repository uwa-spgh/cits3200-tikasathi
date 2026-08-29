import 'package:flutter/material.dart';

enum HomeVaccinationGroup {
  dueToday,
  dueSoon,
  upToDate,
}

@immutable
class HomeChildSummary {
  const HomeChildSummary({
    required this.name,
    this.childId = '',
    required this.dateOfBirth,
    this.nextVaccineCode,
    required this.avatarEmoji,
    required this.canRecordVaccine,
    required this.canFindClinic,
  });

  final String name;
  final String childId;
  final DateTime dateOfBirth;
  final String? nextVaccineCode;
  final String avatarEmoji;
  final bool canRecordVaccine;
  final bool canFindClinic;
}

@immutable
class HomeStatusGroup {
  const HomeStatusGroup({
    required this.group,
    required this.children,
  });

  final HomeVaccinationGroup group;
  final List<HomeChildSummary> children;
}
