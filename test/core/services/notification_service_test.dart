import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tikasathi/core/services/notification_service.dart';

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

class _FakeInitializationSettings extends Fake
    implements InitializationSettings {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeInitializationSettings());
  });

  group('NotificationService.initialize', () {
    late _MockPlugin plugin;

    setUp(() {
      plugin = _MockPlugin();
      when(() => plugin.initialize(any())).thenAnswer((_) async => true);
    });

    test('initializes the plugin once', () async {
      await NotificationService(plugin).initialize();

      verify(() => plugin.initialize(any())).called(1);
    });

    test('loads the timezone database and picks the local zone', () async {
      await NotificationService(plugin).initialize();

      expect(tz.local.name, isNotEmpty);
      expect(
        tz.TZDateTime.now(tz.local).timeZoneOffset,
        DateTime.now().timeZoneOffset,
      );
    });
  });
}
