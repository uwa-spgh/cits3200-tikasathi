import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/theme/app_theme.dart';
import 'package:tikasathi/features/app_shell/domain/app_navigation_controller.dart';
import 'package:tikasathi/features/app_shell/presentation/app_bottom_navigation_bar.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/home/domain/home_helpers.dart';
import 'package:tikasathi/features/onboarding/presentation/retroactive_vaccine_screen.dart';
import 'package:tikasathi/features/record_dose/presentation/record_dose_screen.dart';

class ChildProfileScreen extends ConsumerWidget {
  const ChildProfileScreen({
    required this.childId,
    super.key,
  });

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final AppSection selectedSection =
        ref.watch(appNavigationControllerProvider);
    final AsyncValue<ChildProfileDetails> childProfileState =
        ref.watch(childProfileProvider(childId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      body: SafeArea(
        child: childProfileState.when(
          data: (ChildProfileDetails details) =>
              _ChildContent(details: details),
          loading: () => _LoadingState(localizations: localizations),
          error: (_, __) => _ErrorState(localizations: localizations),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedSection: selectedSection,
        onDestinationSelected: (AppSection section) {
          ref
              .read(appNavigationControllerProvider.notifier)
              .selectSection(section);
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}

class _ChildContent extends StatelessWidget {
  const _ChildContent({required this.details});

  final ChildProfileDetails details;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final ChildStatus status = _statusFor(details);
    final VaccinationDue? nextDue = details.nextDue;
    final VaccinationDue? followingDue = details.followingDue;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final String bornDateLabel =
        DateFormat('d MMMM y', languageCode).format(details.child.dateOfBirth);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: localizations.childBackTooltip,
                ),
                Expanded(
                  child: Text(
                    localizations.childPageTitleWithName(details.child.name),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF11284F),
                        ),
                  ),
                ),
                ReadAloudButton(
                  tooltip: localizations.childReadAloudTooltip,
                  unavailableMessage: localizations.childReadAloudUnavailable,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ChildHeaderCard(
              name: details.child.name,
              ageLabel: details.ageLabel(localizations),
              sexLabel: childSexLabel(details.child.sex, localizations),
              bornLabel: localizations.childBornOn(bornDateLabel),
              avatarEmoji: details.avatarEmoji,
            ),
            const SizedBox(height: 20),
            _VaccineStatusAndTimelineCard(
              status: status,
              nextDue: nextDue,
              followingDue: followingDue,
              localizations: localizations,
              languageCode: languageCode,
            ),
            const SizedBox(height: 24),
            _FeatureCard(
              key: const Key('child-record-dose-card'),
              icon: Icons.vaccines_rounded,
              title: localizations.childActionRecordDose,
              cardColor: const Color(0xFFFFF6EC),
              borderColor: const Color(0xFFF6DFC4),
              iconBackgroundColor: const Color(0xFFFCEBD8),
              iconColor: const Color(0xFFB2691B),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        RecordDoseScreen(childId: details.child.id),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _FeatureCard(
              key: const Key('child-vaccine-schedule-card'),
              icon: Icons.calendar_month_rounded,
              title: localizations.childVaccineSchedule,
              cardColor: const Color(0xFFEFF5FF),
              borderColor: const Color(0xFFCFE0FA),
              iconBackgroundColor: const Color(0xFFDDEAFF),
              iconColor: const Color(0xFF0E64C5),
              onTap: () => showFeedbackSnackBar(
                context,
                localizations.childScheduleNotImplemented,
              ),
            ),
            const SizedBox(height: 16),
            _FeatureCard(
              key: const Key('child-vaccine-history-card'),
              icon: Icons.assignment_rounded,
              title: localizations.childVaccineRecordsAndHistory,
              cardColor: const Color(0xFFF2FBEF),
              borderColor: const Color(0xFFD2EEC6),
              iconBackgroundColor: const Color(0xFFE0F5D6),
              iconColor: const Color(0xFF2D7A2C),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => RetroactiveVaccineScreen(
                      childId: details.child.id,
                      isOnboardingFlow: false,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  ChildStatus _statusFor(ChildProfileDetails details) {
    if (!details.isSetupComplete) {
      return const ChildStatus.setupIncomplete();
    }
    if (details.hasOverdueDoses) {
      return const ChildStatus.overdue();
    }
    if (details.hasDosesDueToday) {
      return const ChildStatus.dueToday();
    }
    if (details.hasDosesDueSoon) {
      return const ChildStatus.dueSoon();
    }
    return const ChildStatus.upToDate();
  }
}

class _ChildHeaderCard extends StatelessWidget {
  const _ChildHeaderCard({
    required this.name,
    required this.ageLabel,
    required this.sexLabel,
    required this.bornLabel,
    required this.avatarEmoji,
  });

  final String name;
  final String ageLabel;
  final String sexLabel;
  final String bornLabel;
  final String avatarEmoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBE6F1)),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFEAF2FF),
            child: Text(
              avatarEmoji,
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF11284F),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  ageLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF4B5E7B),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  sexLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7A92),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  bornLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7A92),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VaccineStatusAndTimelineCard extends StatelessWidget {
  const _VaccineStatusAndTimelineCard({
    required this.status,
    required this.nextDue,
    required this.followingDue,
    required this.localizations,
    required this.languageCode,
  });

  final ChildStatus status;
  final VaccinationDue? nextDue;
  final VaccinationDue? followingDue;
  final AppLocalizations localizations;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM y', languageCode);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: status.borderColor, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: status.headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(status.icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status.label(localizations),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (nextDue != null) ...<Widget>[
                  Text(
                    localizations.childNextVaccine,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                          letterSpacing: 0.3,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.vaccines_rounded,
                            color: Color(0xFF0E64C5),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                nextDue!.vaccineCode,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF11284F),
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateFormat.format(nextDue!.dueDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        _UrgencyPill(
                          dueDate: nextDue!.dueDate,
                          localizations: localizations,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                  ),
                  Text(
                    localizations.childFollowingVaccine,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (followingDue != null) ...<Widget>[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: Color(0xFF64748B),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  followingDue!.vaccineCode,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF11284F),
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateFormat.format(followingDue!.dueDate),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Later',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF64748B),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...<Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        localizations.childFinalScheduledVaccine,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF64748B),
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                ] else ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      localizations.childNoUpcomingVaccines,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgencyPill extends StatelessWidget {
  const _UrgencyPill({
    required this.dueDate,
    required this.localizations,
  });

  final DateTime dueDate;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final differenceDays = due.difference(today).inDays;

    final Color bgColor;
    final Color textColor;
    final String label;

    if (differenceDays < 0) {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFB91C1C);
      label = 'Overdue';
    } else if (differenceDays == 0) {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFB45309);
      label = 'Today';
    } else if (differenceDays <= 14) {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFB45309);
      label = 'Soon';
    } else {
      bgColor = const Color(0xFFEAF2FF);
      textColor = const Color(0xFF0E64C5);
      label = 'Scheduled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.cardColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color cardColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 24,
                backgroundColor: iconBackgroundColor,
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF11284F),
                      ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF5A6B85)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(localizations.childLoading),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.localizations});

  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error_outline_rounded,
                size: 44, color: Color(0xFFB51D1D)),
            const SizedBox(height: 12),
            Text(
              localizations.childNotFound,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class ChildStatus {
  const ChildStatus._({
    required this.isDue,
    required this.isNeutral,
    required this.key,
    required this.backgroundColor,
    required this.borderColor,
    required this.headerColor,
    required this.iconColor,
    required this.icon,
  });

  const ChildStatus.setupIncomplete()
      : this._(
          isDue: false,
          isNeutral: true,
          key: 'setupIncomplete',
          backgroundColor: const Color(0xFFF1F5F9),
          borderColor: const Color(0xFF94A3B8),
          headerColor: const Color(0xFF64748B),
          iconColor: const Color(0xFF475569),
          icon: Icons.help_outline_rounded,
        );

  const ChildStatus.allCompleted()
      : this._(
          isDue: false,
          isNeutral: false,
          key: 'allCompleted',
          backgroundColor: const Color(0xFFEAF8EF),
          borderColor: AppTheme.statusUpToDate,
          headerColor: AppTheme.statusUpToDate,
          iconColor: AppTheme.statusUpToDateText,
          icon: Icons.check_circle_rounded,
        );

  const ChildStatus.upToDate()
      : this._(
          isDue: false,
          isNeutral: false,
          key: 'upToDate',
          backgroundColor: const Color(0xFFEAF8EF),
          borderColor: AppTheme.statusUpToDate,
          headerColor: AppTheme.statusUpToDate,
          iconColor: AppTheme.statusUpToDateText,
          icon: Icons.check_circle_rounded,
        );

  const ChildStatus.dueToday()
      : this._(
          isDue: true,
          isNeutral: false,
          key: 'dueToday',
          backgroundColor: const Color(0xFFFFF8E6),
          borderColor: const Color(0xFFE08A00),
          headerColor: const Color(0xFFE08A00),
          iconColor: const Color(0xFF9A5B00),
          icon: Icons.notification_important_rounded,
        );

  const ChildStatus.dueSoon()
      : this._(
          isDue: false,
          isNeutral: false,
          key: 'dueSoon',
          backgroundColor: const Color(0xFFFFF9EE),
          borderColor: const Color(0xFFE5A100),
          headerColor: const Color(0xFFE5A100),
          iconColor: const Color(0xFF9A5B00),
          icon: Icons.alarm_rounded,
        );

  const ChildStatus.overdue()
      : this._(
          isDue: true,
          isNeutral: false,
          key: 'overdue',
          backgroundColor: const Color(0xFFF9E0E0),
          borderColor: const Color(0xFFCD2E2E),
          headerColor: const Color(0xFFCD2E2E),
          iconColor: const Color(0xFFB51D1D),
          icon: Icons.warning_amber_rounded,
        );

  final bool isDue;
  final bool isNeutral;
  final String key;
  final Color backgroundColor;
  final Color borderColor;
  final Color headerColor;
  final Color iconColor;
  final IconData icon;

  String label(AppLocalizations localizations) {
    switch (key) {
      case 'setupIncomplete':
        return localizations.childStatusSetupIncomplete;
      case 'allCompleted':
        return localizations.childAllVaccinesCompleted;
      case 'upToDate':
        return localizations.childVaccinationUpToDate;
      case 'dueToday':
        return localizations.childVaccinationDueToday;
      case 'dueSoon':
        return localizations.childVaccinationDueSoon;
      case 'overdue':
        return localizations.childVaccinationOverdue;
      default:
        return localizations.childVaccinationUpToDate;
    }
  }
}
