import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/reminders/open_child_from_reminder.dart';

class _PushRecorder extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.childProfilesDao.insertChildProfile(
      ChildProfilesCompanion.insert(
        id: 'child-1',
        name: 'Aarav',
        dateOfBirth: DateTime(2026, 7, 26),
        sex: 'male',
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<(GlobalKey<NavigatorState>, _PushRecorder)> pumpApp(
    WidgetTester tester,
  ) async {
    final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
    final _PushRecorder recorder = _PushRecorder();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        navigatorObservers: <NavigatorObserver>[recorder],
        home: const SizedBox.shrink(),
      ),
    );
    recorder.pushes = 0;
    return (key, recorder);
  }

  testWidgets("opens the child's page", (WidgetTester tester) async {
    final (GlobalKey<NavigatorState> key, _PushRecorder recorder) =
        await pumpApp(tester);

    final bool opened = await tester.runAsync(
          () => openChildFromReminder(
            navigator: key.currentState,
            database: database,
            childId: 'child-1',
          ),
        ) ??
        false;

    expect(opened, isTrue);
    expect(recorder.pushes, 1);
  });

  // A reminder can outlive its child: the caregiver may delete the profile
  // while a notification is still in the tray.
  testWidgets('opens nothing for a deleted child', (WidgetTester tester) async {
    final (GlobalKey<NavigatorState> key, _PushRecorder recorder) =
        await pumpApp(tester);

    final bool opened = await tester.runAsync(
          () => openChildFromReminder(
            navigator: key.currentState,
            database: database,
            childId: 'gone',
          ),
        ) ??
        true;

    expect(opened, isFalse);
    expect(recorder.pushes, 0);
  });

  test('opens nothing before the app has a navigator', () async {
    expect(
      await openChildFromReminder(
        navigator: null,
        database: database,
        childId: 'child-1',
      ),
      isFalse,
    );
  });
}
