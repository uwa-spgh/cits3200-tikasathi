import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

part 'notification_service.g.dart';

/// Sets up the device notification plugin and the timezone database it needs.
///
/// Scheduling reminders is not handled here: reminder rows are planned by
/// `planReminders` and persisted by `RemindersDao`, and handing them to the
/// device comes later.
class NotificationService {
  NotificationService(this._plugin);

  static const String reminderChannelId = 'vaccination_reminders';

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(_resolveLocalLocation());

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission prompts are deliberately left off: asking for them is its
        // own piece of work, and iOS only offers the prompt once per install.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  /// Registers a reminder with the device for [when].
  ///
  /// Inexact so no exact-alarm permission is needed: a vaccination reminder
  /// does not have to land on the minute.
  Future<void> scheduleReminder({
    required int notificationId,
    required DateTime when,
    required String title,
    required String body,
  }) {
    return _plugin.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          reminderChannelId,
          'Vaccination reminders',
          channelDescription:
              'Reminders for upcoming and missed vaccination doses.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(int notificationId) {
    return _plugin.cancel(notificationId);
  }

  /// The notification ids the device currently holds a schedule for.
  ///
  /// Read from the device rather than tracked in memory, so it stays right
  /// across app restarts.
  Future<Set<int>> registeredNotificationIds() async {
    final List<PendingNotificationRequest> pending =
        await _plugin.pendingNotificationRequests();
    return pending.map((request) => request.id).toSet();
  }

  /// The timezone database entry matching the device's current UTC offset.
  ///
  /// Offsets are shared by several zones, so this can pick a different name
  /// than the device reports. Reminders fire at a wall-clock hour, so any zone
  /// with the same offset and DST behaviour schedules them identically.
  tz.Location _resolveLocalLocation() {
    final int offsetMillis = DateTime.now().timeZoneOffset.inMilliseconds;
    for (final tz.Location location in tz.timeZoneDatabase.locations.values) {
      if (location.currentTimeZone.offset == offsetMillis) {
        return location;
      }
    }
    return tz.UTC;
  }
}

@Riverpod(keepAlive: true)
FlutterLocalNotificationsPlugin localNotificationsPlugin(
  LocalNotificationsPluginRef ref,
) {
  return FlutterLocalNotificationsPlugin();
}

@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  return NotificationService(ref.watch(localNotificationsPluginProvider));
}
