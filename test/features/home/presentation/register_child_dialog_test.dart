import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/features/home/presentation/register_child_dialog.dart';

class _RegisterChildDialogHost extends StatefulWidget {
  const _RegisterChildDialogHost();

  @override
  State<_RegisterChildDialogHost> createState() =>
      _RegisterChildDialogHostState();
}

class _RegisterChildDialogHostState extends State<_RegisterChildDialogHost> {
  bool _opened = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_opened) {
      return;
    }
    _opened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog<void>(
        context: context,
        builder: (BuildContext _) => const RegisterChildDialog(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}

void main() {
  group('RegisterChildDialog', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    testWidgets('saves child and persists to database',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final expectedDateOfBirth = DateTime(now.year - 1, now.month, now.day);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            appDatabaseProvider.overrideWith((ref) => database),
          ],
          child: const MaterialApp(
            home: _RegisterChildDialogHost(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RegisterChildDialog), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'Kiran');

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Male').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pump();
      for (var i = 0;
          i < 20 && find.byType(RegisterChildDialog).evaluate().isNotEmpty;
          i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.byType(RegisterChildDialog), findsNothing);

      final profiles = await database.childProfilesDao.getAllChildProfiles();
      expect(profiles, hasLength(1));
      final child = profiles.single;
      expect(child.name, 'Kiran');
      expect(child.sex, 'male');
      expect(child.dateOfBirth, expectedDateOfBirth);
    });
  });
}
