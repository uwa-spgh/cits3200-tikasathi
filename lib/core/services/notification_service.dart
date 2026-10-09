import 'dart:async';

import 'package:flutter/foundation.dart';
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

  /// Android shows only the first line of a body unless it is given the big
  /// text style, which cut reminders off mid-sentence when expanded.
  static NotificationDetails _reminderDetails(String body) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        reminderChannelId,
        'Vaccination reminders',
        channelDescription:
            'Reminders for upcoming and missed vaccination doses.',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(body),
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  final FlutterLocalNotificationsPlugin _plugin;

  final StreamController<String> _openedChildIds =
      StreamController<String>.broadcast();

  /// The child a reminder was about, each time the caregiver taps one while
  /// the app is running or in the background.
  ///
  /// A tap that starts the app from closed arrives through
  /// [childIdThatLaunchedApp] instead.
  Stream<String> get openedChildIds => _openedChildIds.stream;

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    await _plugin.initialize(
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? childId = response.payload;
        if (childId != null && childId.isNotEmpty) {
          _openedChildIds.add(childId);
        }
      },
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Asked for separately in [requestPermission] so the prompt is a
        // deliberate step whose answer we can read, not a side effect of setup.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        linux: LinuxInitializationSettings(
          defaultActionName: 'Open notification',
        ),
      ),
    );
  }

  /// Registers a reminder with the device for [when].
  ///
  /// Inexact so no exact-alarm permission is needed: a vaccination reminder
  /// does not have to land on the minute.
  ///
  /// [childId] is carried with the notification so tapping it can open that
  /// child's page.
  Future<void> scheduleReminder({
    required int notificationId,
    required DateTime when,
    required String title,
    required String body,
    String? childId,
  }) {
    return _plugin.zonedSchedule(
      notificationId,
      title,
      body,
      _asDeviceInstant(when),
      _reminderDetails(body),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: childId,
    );
  }

  /// The child whose reminder was tapped to start the app from closed, or
  /// null when the app was opened some other way.
  Future<String?> childIdThatLaunchedApp() async {
    final NotificationAppLaunchDetails? details =
        defaultTargetPlatform != TargetPlatform.linux
            ? await _plugin.getNotificationAppLaunchDetails()
            : null;
    if (details == null || !details.didNotificationLaunchApp) {
      return null;
    }
    final String? childId = details.notificationResponse?.payload;
    return childId == null || childId.isEmpty ? null : childId;
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
      _asDeviceInstant(when),
      _reminderDetails(body),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  }

  /// Raises a notification straight away.
  ///
  /// [childId] is carried with the notification so tapping it can open that
  /// child's page.
  Future<void> showNotificationNow({
    required int notificationId,
    required String title,
    required String body,
    String? childId,
  }) {
    return _plugin.show(
      notificationId,
      title,
      body,
      _reminderDetails(body),
      payload: childId,
    );
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

  /// The instant [when] refers to, expressed in UTC.
  ///
  /// The plugin hands Android a wall-clock time plus a zone *name*, which
  /// Android resolves against its own timezone database. Naming a zone picked
  /// by matching the device's offset put reminders three hours out, because the
  /// two databases disagreed about that zone. UTC is the one name both agree
  /// on, and the instant is what we want to preserve anyway.
  tz.TZDateTime _asDeviceInstant(DateTime when) {
    return tz.TZDateTime.from(when, tz.UTC);
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
