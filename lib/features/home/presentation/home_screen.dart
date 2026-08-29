import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/theme/app_theme.dart';
import 'package:tikasathi/features/child/presentation/child_profile_screen.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';

import '../domain/home_helpers.dart';
import '../domain/home_models.dart';
import '../domain/home_status_groups_provider.dart';
import 'register_child_dialog.dart';

typedef HomeChildActionCallback = void Function(HomeChildSummary child);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    this.groups,
    this.onAddChildPressed,
    this.onRecordVaccinePressed,
    this.onFindClinicPressed,
    this.onChildPressed,
  });

  final List<HomeStatusGroup>? groups;
  final VoidCallback? onAddChildPressed;
  final HomeChildActionCallback? onRecordVaccinePressed;
  final HomeChildActionCallback? onFindClinicPressed;
  final HomeChildActionCallback? onChildPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppLanguage> languageState =
        ref.watch(languageControllerProvider);

    return languageState.when(
      data: (AppLanguage _) {
        final List<HomeStatusGroup> resolvedGroups;

        if (groups != null) {
          resolvedGroups = groups!;
        } else {
          final AsyncValue<List<HomeStatusGroup>> homeGroupsState =
              ref.watch(homeStatusGroupsProvider);
          resolvedGroups = homeGroupsState.when(
            data: (List<HomeStatusGroup> data) => data,
            loading: () => const <HomeStatusGroup>[],
            error: (Object error, StackTrace stackTrace) =>
                const <HomeStatusGroup>[],
          );
        }

        return _HomeScreenContent(
          groups: resolvedGroups,
          onAddChildPressed: onAddChildPressed,
          onRecordVaccinePressed: onRecordVaccinePressed,
          onFindClinicPressed: onFindClinicPressed,
          onChildPressed: onChildPressed,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) {
        final AppLocalizations localizations = AppLocalizations.of(context)!;
        return Center(
          child: Text(localizations.appLanguageLoadError(error.toString())),
        );
      },
    );
  }

  static void _showPlaceholder(BuildContext context, String action) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final ScaffoldMessengerState scaffoldMessenger =
        ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(localizations.homeActionPlaceholder(action)),
      ),
    );
  }

  static Future<void> _openRegisterChildDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) => const RegisterChildDialog(),
    );
  }
}

String _childSummaryLabel({
  required HomeChildSummary child,
  required AppLocalizations localizations,
}) {
  final String ageText = formatAge(child.dateOfBirth, localizations);
  if (child.nextVaccineCode == null || child.nextVaccineCode!.isEmpty) {
    return ageText;
  }
  return '${child.nextVaccineCode} - $ageText';
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent({
    required this.groups,
    required this.onAddChildPressed,
    required this.onRecordVaccinePressed,
    required this.onFindClinicPressed,
    required this.onChildPressed,
  });

  final List<HomeStatusGroup> groups;
  final VoidCallback? onAddChildPressed;
  final HomeChildActionCallback? onRecordVaccinePressed;
  final HomeChildActionCallback? onFindClinicPressed;
  final HomeChildActionCallback? onChildPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double horizontalPadding = constraints.maxWidth >= 600 ? 24 : 16;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                24,
              ),
              children: <Widget>[
                LayoutBuilder(
                  builder:
                      (BuildContext context, BoxConstraints headerConstraints) {
                    final bool compactHeader = headerConstraints.maxWidth < 340;

                    final Widget title = Text(
                      localizations.homeTitle,
                      key: const Key('home-title'),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF11284F),
                              ),
                    );

                    final Widget addChildButton = OutlinedButton(
                      key: const Key('home-add-child-button'),
                      onPressed: onAddChildPressed ??
                          () => HomeScreen._openRegisterChildDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0E64C5),
                        side: const BorderSide(color: Color(0xFF0E64C5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        minimumSize: const Size(0, 44),
                      ),
                      child: Text(
                        localizations.homeAddChildButton,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    );

                    if (compactHeader) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          title,
                          const SizedBox(height: 8),
                          addChildButton,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(child: title),
                        addChildButton,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                if (groups.isEmpty)
                  _HomeEmptyState(
                    onAddChildPressed: onAddChildPressed ??
                        () => HomeScreen._openRegisterChildDialog(context),
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
                          if (child.childId.isEmpty) {
                            HomeScreen._showPlaceholder(
                              context,
                              localizations.homeActionChildDetails,
                            );
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext childContext) =>
                                  ChildProfileScreen(childId: child.childId),
                            ),
                          );
                        },
                        onRecordVaccinePressed: (HomeChildSummary child) {
                          if (onRecordVaccinePressed != null) {
                            onRecordVaccinePressed!(child);
                            return;
                          }
                          HomeScreen._showPlaceholder(
                              context, localizations.homeActionRecordVaccine);
                        },
                        onFindClinicPressed: (HomeChildSummary child) {
                          if (onFindClinicPressed != null) {
                            onFindClinicPressed!(child);
                            return;
                          }
                          HomeScreen._showPlaceholder(
                            context,
                            localizations.homeActionFindClinic,
                          );
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
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final _GroupStyle style = _GroupStyle.fromGroup(group.group);

    final String groupHeader = switch (group.group) {
      HomeVaccinationGroup.dueToday => localizations.homeSectionDueToday,
      HomeVaccinationGroup.dueSoon => localizations.homeSectionDueSoon,
      HomeVaccinationGroup.upToDate => localizations.homeSectionUpToDate,
    };

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
                Expanded(
                  child: Text(
                    groupHeader,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
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
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints childConstraints) {
        final bool compactActions = childConstraints.maxWidth < 420;

        final List<Widget> actionButtons = <Widget>[
          if (child.canRecordVaccine)
            FilledButton.icon(
              key: Key('record-vaccine-${child.name}'),
              onPressed: onRecordVaccinePressed,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0E64C5),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              icon: const Icon(Icons.edit, size: 18),
              label: Text(localizations.homeActionRecordVaccine),
            ),
          if (child.canFindClinic)
            FilledButton.icon(
              key: Key('find-clinic-${child.name}'),
              onPressed: onFindClinicPressed,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD9ECFF),
                foregroundColor: const Color(0xFF0E64C5),
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              icon: const Icon(Icons.location_on_outlined, size: 18),
              label: Text(localizations.homeActionFindClinic),
            ),
        ];

        final Widget actionGroup = compactActions
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: actionButtons
                    .map(
                      (Widget button) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: button,
                      ),
                    )
                    .toList(),
              )
            : Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: actionButtons,
              );

        return Column(
          children: <Widget>[
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onChildPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              _childSummaryLabel(
                                child: child,
                                localizations: localizations,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
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
            ),
            const SizedBox(height: 8),
            actionGroup,
          ],
        );
      },
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
    final AppLocalizations localizations = AppLocalizations.of(context)!;

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
            localizations.homeEmptyStateTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.homeEmptyStateSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF495D7D),
                ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onAddChildPressed,
            child: Text(localizations.homeActionAddChild),
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
          headerColor: AppTheme.statusUpToDate,
          bodyColor: Colors.white,
          borderColor: AppTheme.statusUpToDate,
          icon: Icons.check_circle_rounded,
        );
    }
  }
}
