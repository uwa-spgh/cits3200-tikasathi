import 'home_models.dart';

final List<HomeStatusGroup> homeDemoGroups = <HomeStatusGroup>[
  HomeStatusGroup(
    group: HomeVaccinationGroup.dueToday,
    children: <HomeChildSummary>[
      HomeChildSummary(
        name: 'Maya',
        childId: 'maya',
        dateOfBirth: DateTime(2024, 1, 15),
        nextVaccineCode: 'Rotavirus',
        avatarEmoji: '👶',
        canRecordVaccine: true,
        canFindClinic: true,
      ),
    ],
  ),
  HomeStatusGroup(
    group: HomeVaccinationGroup.dueSoon,
    children: <HomeChildSummary>[
      HomeChildSummary(
        name: 'Oscar',
        childId: 'oscar',
        dateOfBirth: DateTime(2023, 7, 5),
        nextVaccineCode: 'TCV',
        avatarEmoji: '🧒',
        canRecordVaccine: false,
        canFindClinic: true,
      ),
    ],
  ),
  HomeStatusGroup(
    group: HomeVaccinationGroup.upToDate,
    children: <HomeChildSummary>[
      HomeChildSummary(
        name: 'Sofia',
        childId: 'sofia',
        dateOfBirth: DateTime(2021, 4, 10),
        nextVaccineCode: 'DPT',
        avatarEmoji: '👧',
        canRecordVaccine: false,
        canFindClinic: false,
      ),
    ],
  ),
];
