import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tikasathi/core/services/notification_service.dart';

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

class _FakeInitializationSettings extends Fake
    implements InitializationSettings {}

class _FakeTZDateTime extends Fake implements tz.TZDateTime {}

class _FakeNotificationDetails extends Fake implements NotificationDetails {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeInitializationSettings());
    registerFallbackValue(_FakeTZDateTime());
    registerFallbackValue(_FakeNotificationDetails());
    registerFallbackValue(UILocalNotificationDateInterpretation.absoluteTime);
    registerFallbackValue(AndroidScheduleMode.inexact);
  });

  group('NotificationService', () {
    late _MockPlugin plugin;
    late NotificationService service;

    setUp(() async {
      plugin = _MockPlugin();
      service = NotificationService(plugin);
      when(() => plugin.initialize(any())).thenAnswer((_) async => true);
      when(
        () => plugin.zonedSchedule(
          any(),
          any(),
          any(),
          any(),
          any(),
          uiLocalNotificationDateInterpretation:
              any(named: 'uiLocalNotificationDateInterpretation'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      ).thenAnswer((_) async {});
      await service.initialize();
    });

    test('initializes the plugin once', () {
      verify(() => plugin.initialize(any())).called(1);
    });

    test('loads the timezone database', () {
      expect(tz.timeZoneDatabase.locations, isNotEmpty);
    });

    // A zone picked by matching the device's offset once resolved differently
    // on the Android side, putting every reminder three hours early. UTC is the
    // one name both timezone databases agree on.
    test('schedules at the instant asked for, named as UTC', () async {
      final DateTime when = DateTime(2026, 10, 4, 9);

      await service.scheduleReminder(
        notificationId: 5,
        when: when,
        title: 'title',
        body: 'body',
      );

      final tz.TZDateTime scheduled = verify(
        () => plugin.zonedSchedule(
          5,
          any(),
          any(),
          captureAny(),
          any(),
          uiLocalNotificationDateInterpretation:
              any(named: 'uiLocalNotificationDateInterpretation'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      ).captured.single as tz.TZDateTime;

      expect(scheduled.millisecondsSinceEpoch, when.millisecondsSinceEpoch);
      expect(scheduled.location.name, 'UTC');
    });

    // Without the big text style Android cuts the body to one line, even when
    // the caregiver expands the notification.
    test('lets Android show the whole body when expanded', () async {
      const String body = 'For Aarav: BCG (Dose 1) is overdue. Contact your '
          'nearest health facility for catch-up vaccination.';

      await service.scheduleReminder(
        notificationId: 5,
        when: DateTime(2026, 10, 4, 9),
        title: 'title',
        body: body,
      );

      final NotificationDetails details = verify(
        () => plugin.zonedSchedule(
          5,
          any(),
          any(),
          any(),
          captureAny(),
          uiLocalNotificationDateInterpretation:
              any(named: 'uiLocalNotificationDateInterpretation'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      ).captured.single as NotificationDetails;

      final StyleInformation? style = details.android!.styleInformation;
      expect(style, isA<BigTextStyleInformation>());
      expect((style! as BigTextStyleInformation).bigText, body);
    });

    test('schedules one-off notifications at the instant asked for', () async {
      final DateTime when = DateTime.now().add(const Duration(minutes: 2));

      await service.scheduleOneOff(
        notificationId: NotificationService.oneOffIdFloor,
        when: when,
        title: 'title',
        body: 'body',
      );

      final tz.TZDateTime scheduled = verify(
        () => plugin.zonedSchedule(
          NotificationService.oneOffIdFloor,
          any(),
          any(),
          captureAny(),
          any(),
          uiLocalNotificationDateInterpretation:
              any(named: 'uiLocalNotificationDateInterpretation'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      ).captured.single as tz.TZDateTime;

      expect(scheduled.millisecondsSinceEpoch, when.millisecondsSinceEpoch);
      expect(scheduled.location.name, 'UTC');
    });
  });
}
