import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/theme/app_theme.dart';
import 'package:tikasathi/features/app_shell/domain/app_navigation_controller.dart';
import 'package:tikasathi/features/app_shell/presentation/app_bottom_navigation_bar.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';

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
    final nextDue = details.nextDue;
    final String bornDateLabel =
        DateFormat('d MMMM y', Localizations.localeOf(context).languageCode)
            .format(details.child.dateOfBirth);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
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
              ageLabel: details.ageLabel,
              bornLabel: localizations.childBornOn(bornDateLabel),
              avatarEmoji: details.avatarEmoji,
            ),
            const SizedBox(height: 20),
            _StatusCard(
              title: status.label(localizations),
              vaccineCode: nextDue?.vaccineCode,
              dueDateLabel: nextDue == null
                  ? localizations.childNoDueVaccines
                  : DateFormat(
                          'd MMM', Localizations.localeOf(context).languageCode)
                      .format(nextDue.dueDate),
              isDue: status.isDue,
            ),
            const SizedBox(height: 20),
            _NextVaccineCard(
              title: localizations.childNextVaccine,
              vaccineLabel:
                  nextDue?.vaccineCode ?? localizations.childNoUpcomingVaccines,
              dateLabel: nextDue == null
                  ? null
                  : DateFormat(
                          'd MMM', Localizations.localeOf(context).languageCode)
                      .format(nextDue.dueDate),
            ),
            const SizedBox(height: 30),
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
            const SizedBox(height: 20),
            _FeatureCard(
              key: const Key('child-vaccine-history-card'),
              icon: Icons.assignment_rounded,
              title: localizations.childVaccineHistory,
              cardColor: const Color(0xFFF2FBEF),
              borderColor: const Color(0xFFD2EEC6),
              iconBackgroundColor: const Color(0xFFE0F5D6),
              iconColor: const Color(0xFF2D7A2C),
              onTap: () => showFeedbackSnackBar(
                context,
                localizations.childHistoryNotImplemented,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ChildStatus _statusFor(ChildProfileDetails details) {
    if (details.isUpToDate) {
      return const ChildStatus.upToDate();
    }
    return details.isDueToday
        ? const ChildStatus.dueToday()
        : const ChildStatus.dueSoon();
  }
}

class _ChildHeaderCard extends StatelessWidget {
  const _ChildHeaderCard({
    required this.name,
    required this.ageLabel,
    required this.bornLabel,
    required this.avatarEmoji,
  });

  final String name;
  final String ageLabel;
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.vaccineCode,
    required this.dueDateLabel,
    required this.isDue,
  });

  final String title;
  final String? vaccineCode;
  final String dueDateLabel;
  final bool isDue;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isDue ? const Color(0xFFF9E0E0) : const Color(0xFFEAF8EF);
    final Color borderColor =
        isDue ? const Color(0xFFCD2E2E) : AppTheme.statusUpToDate;
    final Color headerColor =
        isDue ? const Color(0xFFCD2E2E) : AppTheme.statusUpToDate;
    final Color textColor =
        isDue ? const Color(0xFFB51D1D) : AppTheme.statusUpToDateText;
    final IconData icon =
        isDue ? Icons.warning_amber_rounded : Icons.check_circle_rounded;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
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
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Column(
              children: <Widget>[
                Text(
                  dueDateLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF11284F),
                      ),
                ),
                if (vaccineCode != null) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    vaccineCode!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textColor,
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

class _NextVaccineCard extends StatelessWidget {
  const _NextVaccineCard({
    required this.title,
    required this.vaccineLabel,
    required this.dateLabel,
  });

  final String title;
  final String vaccineLabel;
  final String? dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB949), width: 2),
      ),
      child: Row(
        children: <Widget>[
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFFFF4DE),
            child: Icon(Icons.calendar_month, color: Color(0xFFC97700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF11284F),
                      ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      vaccineLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF11284F),
                          ),
                    ),
                    if (dateLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4DE),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          dateLabel!,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFC97700),
                                  ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
  const ChildStatus._({required this.isDue, required this.key});

  const ChildStatus.upToDate() : this._(isDue: false, key: 'upToDate');
  const ChildStatus.dueToday() : this._(isDue: true, key: 'dueToday');
  const ChildStatus.dueSoon() : this._(isDue: true, key: 'dueSoon');

  final bool isDue;
  final String key;

  String label(AppLocalizations localizations) {
    switch (key) {
      case 'upToDate':
        return localizations.childVaccinationUpToDate;
      case 'dueToday':
        return localizations.childVaccinationDueToday;
      case 'dueSoon':
        return localizations.childVaccinationDueSoon;
      default:
        return localizations.childVaccinationUpToDate;
    }
  }
}
