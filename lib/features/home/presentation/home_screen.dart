import 'package:flutter/material.dart';

import '../domain/home_demo_data.dart';

typedef HomeChildActionCallback = void Function(HomeChildSummary child);

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.groups = homeDemoGroups,
    this.onAddChildPressed,
    this.onRecordVaccinePressed,
    this.onFindClinicPressed,
    this.onChildPressed,
  });
 
  final List<HomeStatusGroup> groups;
  final VoidCallback? onAddChildPressed;
  final HomeChildActionCallback? onRecordVaccinePressed;
  final HomeChildActionCallback? onFindClinicPressed;
  final HomeChildActionCallback? onChildPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double horizontalPadding = constraints.maxWidth >= 600 ? 24 : 16;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                  horizontalPadding, 16, horizontalPadding, 24),
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Your children',
                        key: const Key('home-title'),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF11284F),
                            ),
                      ),
                    ),
                    OutlinedButton(
                      key: const Key('home-add-child-button'),
                      onPressed: onAddChildPressed ??
                          () => _showPlaceholder(context, 'Add child'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0E64C5),
                        side: const BorderSide(color: Color(0xFF0E64C5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        minimumSize: const Size(112, 44),
                      ),
                      child: const Text(
                        '+ Add child',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (groups.isEmpty)
                  _HomeEmptyState(
                    onAddChildPressed: onAddChildPressed ??
                        () => _showPlaceholder(context, 'Add child'),
                  )
                else
                  ...groups.map(
                    (HomeStatusGroup group) => Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: _StatusGroupCard(
                        group: group,
                        onChildPressed: (HomeChildSummary child) {
                          if (onChildPressed != null) {
                            onChildPressed!(child);
                            return;
                          }
                          _showPlaceholder(context, 'Child details');
                        },
                        onRecordVaccinePressed: (HomeChildSummary child) {
                          if (onRecordVaccinePressed != null) {
                            onRecordVaccinePressed!(child);
                            return;
                          }
                          _showPlaceholder(context, 'Record vaccine');
                        },
                        onFindClinicPressed: (HomeChildSummary child) {
                          if (onFindClinicPressed != null) {
                            onFindClinicPressed!(child);
                            return;
                          }
                          _showPlaceholder(context, 'Find clinic');
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlaceholder(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action is not available yet.'),
      ),
    );
  }
}

class _StatusGroupCard extends StatelessWidget {
  const _StatusGroupCard({
    required this.group,
    required this.onChildPressed,
    required this.onRecordVaccinePressed,
    required this.onFindClinicPressed,
  });

  final HomeStatusGroup group;
  final HomeChildActionCallback onChildPressed;
  final HomeChildActionCallback onRecordVaccinePressed;
  final HomeChildActionCallback onFindClinicPressed;

  @override
  Widget build(BuildContext context) {
    final _GroupStyle style = _GroupStyle.fromGroup(group.group);

    return Container(
      key: Key('home-group-${group.group.name}'),
      decoration: BoxDecoration(
        color: style.bodyColor,
        border: Border.all(color: style.borderColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: style.headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(style.icon, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  group.headerLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: group.children
                  .map(
                    (HomeChildSummary child) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _HomeChildCard(
                        child: child,
                        onChildPressed: () => onChildPressed(child),
                        onRecordVaccinePressed: () =>
                            onRecordVaccinePressed(child),
                        onFindClinicPressed: () => onFindClinicPressed(child),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeChildCard extends StatelessWidget {
  const _HomeChildCard({
    required this.child,
    required this.onChildPressed,
    required this.onRecordVaccinePressed,
    required this.onFindClinicPressed,
  });

  final HomeChildSummary child;
  final VoidCallback onChildPressed;
  final VoidCallback onRecordVaccinePressed;
  final VoidCallback onFindClinicPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onChildPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFEAF2FF),
                  child: Text(
                    child.avatarEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        child.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '${child.vaccineLabel} - ${child.ageLabel}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF495D7D),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 34,
                  color: Color(0xFF465A7A),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: <Widget>[
            if (child.canRecordVaccine)
              FilledButton.icon(
                key: Key('record-vaccine-${child.name}'),
                onPressed: onRecordVaccinePressed,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0E64C5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(160, 44),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 18),
                ),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Record vaccine'),
              ),
            if (child.canFindClinic)
              FilledButton.icon(
                key: Key('find-clinic-${child.name}'),
                onPressed: onFindClinicPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD9ECFF),
                  foregroundColor: const Color(0xFF0E64C5),
                  minimumSize: const Size(160, 44),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 18),
                ),
                icon: const Icon(Icons.location_on_outlined, size: 18),
                label: const Text('Find clinic'),
              ),
          ],
        ),
      ],
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState({
    required this.onAddChildPressed,
  });

  final VoidCallback onAddChildPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home-empty-state'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD2E1F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'No children added yet.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first child to see upcoming vaccines here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF495D7D),
                ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onAddChildPressed,
            child: const Text('Add child'),
          ),
        ],
      ),
    );
  }
}

@immutable
class _GroupStyle {
  const _GroupStyle({
    required this.headerColor,
    required this.bodyColor,
    required this.borderColor,
    required this.icon,
  });

  final Color headerColor;
  final Color bodyColor;
  final Color borderColor;
  final IconData icon;

  static _GroupStyle fromGroup(HomeVaccinationGroup group) {
    switch (group) {
      case HomeVaccinationGroup.dueToday:
        return const _GroupStyle(
          headerColor: Color(0xFFC9292B),
          bodyColor: Color(0xFFFFDCDD),
          borderColor: Color(0xFFC9292B),
          icon: Icons.warning_rounded,
        );
      case HomeVaccinationGroup.dueSoon:
        return const _GroupStyle(
          headerColor: Color(0xFFF5B544),
          bodyColor: Colors.white,
          borderColor: Color(0xFFF5B544),
          icon: Icons.event_note_rounded,
        );
      case HomeVaccinationGroup.upToDate:
        return const _GroupStyle(
          headerColor: Color(0xFF6EA773),
          bodyColor: Colors.white,
          borderColor: Color(0xFF6EA773),
          icon: Icons.check_circle_rounded,
        );
    }
  }
}
