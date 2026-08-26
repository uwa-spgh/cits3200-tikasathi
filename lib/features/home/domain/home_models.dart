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
    required this.ageLabel,
    required this.vaccineLabel,
    required this.avatarEmoji,
    required this.canRecordVaccine,
    required this.canFindClinic,
  });

  final String name;
  final String childId;
  final String ageLabel;
  final String vaccineLabel;
  final String avatarEmoji;
  final bool canRecordVaccine;
  final bool canFindClinic;
}

@immutable
class HomeStatusGroup {
  const HomeStatusGroup({
    required this.group,
    required this.headerLabel,
    required this.children,
  });

  final HomeVaccinationGroup group;
  final String headerLabel;
  final List<HomeChildSummary> children;
}
