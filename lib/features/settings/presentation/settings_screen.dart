import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/core/services/notification_service.dart';
import 'package:tikasathi/core/services/secure_storage_service.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/health_facility_controller.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';
import 'package:tikasathi/features/settings/presentation/health_facility_card.dart';
import 'package:tikasathi/features/child/domain/child_profile_provider.dart';
import 'package:tikasathi/features/home/domain/home_helpers.dart';
import 'package:tikasathi/features/home/domain/home_status_groups_provider.dart';
import 'package:tikasathi/features/settings/presentation/caregiver_edit_screen.dart';
import 'package:tikasathi/features/settings/presentation/child_edit_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final AsyncValue<AppLanguage> languageState =
        ref.watch(languageControllerProvider);
    final AsyncValue<HealthFacility?> facilitatorState =
        ref.watch(healthFacilityProvider);

    return languageState.when(
      data: (AppLanguage language) => facilitatorState.when(
        data: (facilitator) => _buildContent(
          context,
          ref,
          isNp: language == AppLanguage.nepali,
          facilitator: facilitator,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
            child: Text(localizations.appLanguageLoadError(error.toString()))),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
          child: Text(localizations.appLanguageLoadError(error.toString()))),
    );
  }

  /// Shows one notification now and schedules a second shortly after, then
  /// reports what the reminders table holds and what the device has registered.
  ///
  /// Ids sit well above the reminder sequence so a test cannot collide with a
  /// real reminder.
  Future<void> _testNotifications(
    BuildContext context,
    WidgetRef ref, {
    required bool isNp,
  }) async {
    const int immediateId = NotificationService.oneOffIdFloor;
    const int scheduledId = NotificationService.oneOffIdFloor + 1;
    const Duration delay = Duration(seconds: 30);

    final NotificationService notifications =
        ref.read(notificationServiceProvider);
    final AppDatabase database = ref.read(appDatabaseProvider);

    await notifications.showNotificationNow(
      notificationId: immediateId,
      title: isNp ? 'परीक्षण सूचना' : 'Test notification',
      body: isNp
          ? 'सूचना प्रणाली काम गरिरहेको छ।'
          : 'Notifications are working on this device.',
    );
    await notifications.scheduleOneOff(
      notificationId: scheduledId,
      when: DateTime.now().add(delay),
      title: isNp ? 'निर्धारित परीक्षण' : 'Scheduled test',
      body: isNp
          ? 'यो सूचना ३० सेकेन्ड अगाडि निर्धारित गरिएको थियो।'
          : 'This one was scheduled 30 seconds earlier.',
    );

    final int pending =
        (await database.remindersDao.getPendingReminders()).length;
    final int registered =
        (await notifications.registeredNotificationIds()).length;

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isNp
            ? 'सूचना पठाइयो। ३० सेकेन्डमा अर्को आउँछ। '
                'पेन्डिङ रिमाइन्डर: $pending, दर्ता भएका: $registered'
            : 'Sent one now, another in 30s. '
                'Pending reminders: $pending, registered with device: $registered'),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Future<void> _saveLanguage(
    BuildContext context,
    WidgetRef ref, {
    required AppLanguage language,
  }) async {
    final bool saved = await ref
        .read(languageControllerProvider.notifier)
        .setLanguage(language);
    if (!saved && context.mounted) {
      final AppLocalizations localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.settingsLanguageSaveError),
        ),
      );
    }
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref, {
    required bool isNp,
    required HealthFacility? facilitator,
  }) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      localizations.settingsTitle,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  ReadAloudButton(
                    tooltip: localizations.childReadAloudTooltip,
                    unavailableMessage: localizations.childReadAloudUnavailable,
                  ),
                ],
              ),
              const SizedBox(height: 0),
              Text(
                localizations.settingsLanguageTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 14),
              _LanguageButton(
                title: localizations.settingsNepali,
                flag: '🇳🇵',
                isSelected: isNp,
                onTap: () => _saveLanguage(
                  context,
                  ref,
                  language: AppLanguage.nepali,
                ),
              ),
              const SizedBox(height: 14),
              _LanguageButton(
                title: localizations.settingsEnglish,
                flag: '🇬🇧',
                isSelected: !isNp,
                onTap: () => _saveLanguage(
                  context,
                  ref,
                  language: AppLanguage.english,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.manageProfilesTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 6),
              _ProfileAction(
                icon: Icons.person_outline,
                title: localizations.editCaregiverAction,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CaregiverEditScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _ProfileAction(
                icon: Icons.child_care_outlined,
                title: localizations.editChildAction,
                onTap: () => _chooseChild(context, ref, delete: false),
              ),
              const SizedBox(height: 8),
              _ProfileAction(
                icon: Icons.delete_outline,
                title: localizations.deleteChildAction,
                onTap: () => _chooseChild(context, ref, delete: true),
              ),
              const SizedBox(height: 18),
              HealthFacilityCard(
                key: const Key('health-facilitator-action'),
                facility: facilitator,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _testNotifications(context, ref, isNp: isNp),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isNp
                    ? 'DEBUG: सूचना परीक्षण गर्नुहोस्'
                    : 'DEBUG: Test Notifications'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Debug: Clear secure storage
                  await ref.read(secureStorageServiceProvider).clearAll();

                  // Debug: Clear database tables
                  final db = ref.read(appDatabaseProvider);
                  await db.delete(db.reminders).go();
                  await db.delete(db.vaccinationRecords).go();
                  await db.delete(db.vaccinationDues).go();
                  await db.delete(db.childProfiles).go();
                  await db.delete(db.healthFacilitators).go();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isNp
                            ? 'सबै डाटा मेटाइयो (डिबग)। सुरुदेखि हेर्न एप रिस्टार्ट गर्नुहोस्।'
                            : 'All data cleared (Debug). Restart the app to see the onboarding screen again.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isNp
                    ? 'DEBUG: सबै डाटा मेटाउनुहोस्'
                    : 'DEBUG: Clear All Storage'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseChild(
    BuildContext context,
    WidgetRef ref, {
    required bool delete,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final children = await ref
        .read(appDatabaseProvider)
        .childProfilesDao
        .getAllChildProfiles();
    if (!context.mounted) return;
    if (children.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.noChildrenMessage)));
      return;
    }
    final selected = children.length == 1
        ? children.single
        : await showDialog<ChildProfile>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.fromLTRB(28, 28, 28, 8),
              contentPadding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
              actionsPadding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
              title: Text(l10n.selectChildTitle),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: children.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final child = children[index];
                    return ListTile(
                      leading: Text(
                        getChildAvatar(
                          sex: childSexFromString(child.sex),
                          dateOfBirth: child.dateOfBirth,
                        ),
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(child.name),
                      subtitle: Text(childSexLabel(child.sex, l10n)),
                      onTap: () => Navigator.of(dialogContext).pop(child),
                    );
                  },
                ),
              ),
              actions: [
                FilledButton(
                  autofocus: true,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F52BA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.profileCancel),
                ),
              ],
            ),
          );
    if (selected == null || !context.mounted) return;
    if (!delete) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChildEditScreen(childId: selected.id),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        contentPadding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
        actionsPadding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
        title: Text(
          l10n.deleteChildTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: l10n.deleteChildProfileName(selected.name),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: '\n\n'),
              TextSpan(
                text: l10n.deleteChildMessageFirst,
                style: const TextStyle(fontSize: 18),
              ),
              const TextSpan(text: '\n\n'),
              TextSpan(
                text: l10n.deleteChildMessageUndo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  autofocus: true,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F52BA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.profileCancel),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.deleteChildConfirm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(appDatabaseProvider)
          .childProfilesDao
          .deleteChildProfile(selected.id);
      if (!context.mounted) return;
      ref.invalidate(homeStatusGroupsProvider);
      ref.invalidate(childProfileProvider(selected.id));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.deleteChildSuccess)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.deleteChildError)));
    }
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF5FF),
          border: Border.all(color: const Color(0xFFCFE0FA)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0E64C5)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0E64C5),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF0E64C5)),
          ],
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String title;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.title,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE2F0FE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF0F52BA) : const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF0F52BA)
                    : const Color(0xFF334155),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0F52BA)),
          ],
        ),
      ),
    );
  }
}
