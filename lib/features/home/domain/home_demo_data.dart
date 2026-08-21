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
    required this.ageLabel,
    required this.vaccineLabel,
    required this.avatarEmoji,
    required this.canRecordVaccine,
    required this.canFindClinic,
  });

  final String name;
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

const List<HomeStatusGroup> homeDemoGroups = <HomeStatusGroup>[
  HomeStatusGroup(
    group: HomeVaccinationGroup.dueToday,
    headerLabel: 'Vaccine due TODAY',
    children: <HomeChildSummary>[
      HomeChildSummary(
        name: 'Maya',
        ageLabel: '9 months old',
        vaccineLabel: 'Rotavirus',
        avatarEmoji: '👶',
        canRecordVaccine: true,
        canFindClinic: true,
      ),
    ],
  ),
  HomeStatusGroup(
    group: HomeVaccinationGroup.dueSoon,
    headerLabel: 'Due in 2 weeks',
    children: <HomeChildSummary>[
      HomeChildSummary(
        name: 'Oscar',
        ageLabel: '14 months old',
        vaccineLabel: 'TCV',
        avatarEmoji: '🧒',
        canRecordVaccine: false,
        canFindClinic: true,
      ),
    ],
  ),
  HomeStatusGroup(
    group: HomeVaccinationGroup.upToDate,
    headerLabel: 'All up to date',
    children: <HomeChildSummary>[
      HomeChildSummary(
        name: 'Sofia',
        ageLabel: '4 years old',
        vaccineLabel: 'DPT',
        avatarEmoji: '👧',
        canRecordVaccine: false,
        canFindClinic: false,
      ),
    ],
  ),
];
