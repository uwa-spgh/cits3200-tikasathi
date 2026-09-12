import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/record_dose/domain/record_dose_controller.dart';
import 'package:tikasathi/features/record_dose/presentation/record_dose_screen.dart';

/// Serves a fixed [RecordDoseState] so the screen can be exercised without a
/// database. The controller's own behaviour is covered by its unit tests.
class _StubRecordDoseController extends RecordDoseController {
  _StubRecordDoseController(this._initialState);

  final RecordDoseState _initialState;
  int saveCount = 0;

  @override
  Future<RecordDoseState> build(String childId) async => _initialState;

  @override
  Future<bool> save() async {
    saveCount += 1;
    return true;
  }
}

void main() {
  group('RecordDoseScreen', () {
    const String childId = 'child-1';
    late DateTime today;
    late ChildProfile child;

    setUp(() {
      final DateTime now = DateTime.now();
      today = DateTime(now.year, now.month, now.day);
      child = ChildProfile(
        id: childId,
        name: 'Aarav',
        dateOfBirth: today.subtract(const Duration(days: 90)),
        sex: 'male',
        isSetupComplete: true,
      );
    });

    VaccinationDue due(
      String id,
      String vaccineCode,
      int doseNumber,
      DateTime dueDate,
    ) {
      return VaccinationDue(
        id: id,
        childId: childId,
        vaccineCode: vaccineCode,
        doseNumber: doseNumber,
        dueDate: dueDate,
      );
    }

    Future<_StubRecordDoseController> pumpScreen(
      WidgetTester tester,
      List<VaccinationDue> dues,
    ) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final _StubRecordDoseController controller = _StubRecordDoseController(
        RecordDoseState(
          child: child,
          dues: dues,
          administeredDate: today,
          today: today,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            recordDoseControllerProvider(childId)
                .overrideWith(() => controller),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: RecordDoseScreen(childId: childId),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return controller;
    }

    testWidgets('lists doses owed now and hides the rest of the schedule',
        (WidgetTester tester) async {
      await pumpScreen(tester, <VaccinationDue>[
        due('due-today', 'BOPV', 1, today),
        due('due-later', 'MR', 1, today.add(const Duration(days: 200))),
      ]);

      expect(find.text('BOPV'), findsOneWidget);
      expect(find.text('MR'), findsNothing);
      expect(find.byKey(const Key('record-dose-show-all')), findsOneWidget);
    });

    testWidgets('reveals upcoming doses when the toggle is switched on',
        (WidgetTester tester) async {
      await pumpScreen(tester, <VaccinationDue>[
        due('due-today', 'BOPV', 1, today),
        due('due-later', 'MR', 1, today.add(const Duration(days: 200))),
      ]);

      await tester.tap(find.byKey(const Key('record-dose-show-all')));
      await tester.pumpAndSettle();

      expect(find.text('MR'), findsOneWidget);
    });

    testWidgets('marks a dose whose due date has passed as overdue',
        (WidgetTester tester) async {
      await pumpScreen(tester, <VaccinationDue>[
        due('due-overdue', 'BOPV', 1, today.subtract(const Duration(days: 7))),
      ]);

      expect(find.textContaining('Overdue since'), findsOneWidget);
    });

    testWidgets(
        'save button counts the ticked doses and stays disabled '
        'while nothing is selected', (WidgetTester tester) async {
      await pumpScreen(tester, <VaccinationDue>[
        due('due-1', 'BOPV', 1, today),
        due('due-2', 'PENTA', 1, today),
      ]);

      expect(find.text('Tick a vaccine first'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('record-dose-save')))
            .onPressed,
        isNull,
      );

      await tester.tap(find.byKey(const Key('record-dose-item-BOPV-1')));
      await tester.pumpAndSettle();
      expect(find.text('Save 1 dose'), findsOneWidget);

      await tester.tap(find.byKey(const Key('record-dose-item-PENTA-1')));
      await tester.pumpAndSettle();
      expect(find.text('Save 2 doses'), findsOneWidget);
    });

    testWidgets('tapping save asks the controller to record the doses',
        (WidgetTester tester) async {
      final _StubRecordDoseController controller =
          await pumpScreen(tester, <VaccinationDue>[
        due('due-1', 'BOPV', 1, today),
      ]);

      await tester.tap(find.byKey(const Key('record-dose-item-BOPV-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('record-dose-save')));
      await tester.pump();

      expect(controller.saveCount, 1);
    });

    testWidgets('numbers the two steps and offers to change the date',
        (WidgetTester tester) async {
      await pumpScreen(tester, <VaccinationDue>[
        due('due-1', 'BOPV', 1, today),
      ]);

      expect(find.text('Step 1 \u2014 Check the date'), findsOneWidget);
      expect(
          find.text('Step 2 \u2014 Tick each vaccine given'), findsOneWidget);
      expect(find.text('Tap to change'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('badges a ticked dose in words, not only in colour',
        (WidgetTester tester) async {
      await pumpScreen(tester, <VaccinationDue>[
        due('due-1', 'BOPV', 1, today),
      ]);

      expect(find.text('Ticked'), findsNothing);

      await tester.tap(find.byKey(const Key('record-dose-item-BOPV-1')));
      await tester.pumpAndSettle();

      expect(find.text('Ticked'), findsOneWidget);
    });

    testWidgets('names the show-more action instead of using a bare switch',
        (WidgetTester tester) async {
      await pumpScreen(tester, <VaccinationDue>[
        due('due-today', 'BOPV', 1, today),
        due('due-later', 'MR', 1, today.add(const Duration(days: 200))),
      ]);

      expect(find.text('Show more vaccines'), findsOneWidget);

      await tester.tap(find.byKey(const Key('record-dose-show-all')));
      await tester.pumpAndSettle();

      expect(find.text('Show fewer vaccines'), findsOneWidget);
    });

    testWidgets('shows an empty state when nothing is due',
        (WidgetTester tester) async {
      await pumpScreen(tester, <VaccinationDue>[
        due('due-later', 'MR', 1, today.add(const Duration(days: 200))),
      ]);

      expect(find.text('Aarav has no doses due right now.'), findsOneWidget);
    });
  });
}
