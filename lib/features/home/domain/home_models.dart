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
    this.sex,
    required this.avatarEmoji,
    required this.canRecordDose,
  });

  final String name;
  final String childId;
  final DateTime dateOfBirth;
  final String? nextVaccineCode;
  final String? sex;
  final String avatarEmoji;
  final bool canRecordDose;
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
