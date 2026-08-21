import 'home_models.dart';

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
