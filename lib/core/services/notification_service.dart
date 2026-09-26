import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

part 'notification_service.g.dart';

/// Wraps the device notification plugin: setup, permission, and the calls that
/// register or raise a notification.
///
/// Which reminders belong on the device is decided by `ReminderScheduler`.
class NotificationService {
  NotificationService(this._plugin);

  static const String reminderChannelId = 'vaccination_reminders';

  /// Ids at or above this belong to one-off notifications rather than reminder
  /// rows, so reminder reconciliation leaves them alone.
  static const int oneOffIdFloor = 900000;

  static const NotificationDetails _reminderDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      reminderChannelId,
      'Vaccination reminders',
      channelDescription:
          'Reminders for upcoming and missed vaccination doses.',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(_resolveLocalLocation());

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Asked for separately in [requestPermission] so the prompt is a
        // deliberate step whose answer we can read, not a side effect of setup.
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
      _reminderDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(int notificationId) {
    return _plugin.cancel(notificationId);
  }

  /// Asks for permission to post notifications.
  ///
  /// Android 13 and newer drop every notification until this is granted, and
  /// iOS shows its prompt only once per install.
  Future<bool> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    final IOSFlutterLocalNotificationsPlugin? ios =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return false;
  }

  /// Schedules a one-off notification that no reminder row owns.
  ///
  /// Uses plain inexact scheduling rather than the allow-while-idle mode
  /// reminders use: that mode is throttled to about one firing every nine
  /// minutes, which a short check would never survive.
  Future<void> scheduleOneOff({
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
      _reminderDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  /// Raises a notification straight away, to check the device lets them through.
  Future<void> showNotificationNow({
    required int notificationId,
    required String title,
    required String body,
  }) {
    return _plugin.show(notificationId, title, body, _reminderDetails);
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
