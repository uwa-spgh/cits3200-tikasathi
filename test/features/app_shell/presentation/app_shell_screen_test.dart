import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/features/app_shell/presentation/app_bottom_navigation_bar.dart';
import 'package:tikasathi/features/app_shell/presentation/app_shell_screen.dart';
import 'package:drift/native.dart';
import 'package:tikasathi/core/database/app_database.dart';
import 'package:tikasathi/core/database/app_database_provider.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';

import '../../../helpers/fake_settings_repository.dart';

void main() {
  group('AppShellScreen', () {
    testWidgets('shows home screen by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) {
              final db = AppDatabase.forTesting(NativeDatabase.memory());
              ref.onDispose(db.close);
              return db;
            }),
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
          ],
          child: const MaterialApp(
            home: AppShellScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomNavigationBar), findsOneWidget);
      expect(find.byKey(const Key('home-title')), findsOneWidget);
      expect(find.text('सिक्नुहोस् (Placeholder)'), findsNothing);
      expect(find.text('भाषा चयन गर्नुहोस्'), findsNothing);
      expect(find.byIcon(Icons.record_voice_over), findsOneWidget);
    });

    testWidgets('switches destinations from bottom navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) {
              final db = AppDatabase.forTesting(NativeDatabase.memory());
              ref.onDispose(db.close);
              return db;
            }),
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
          ],
          child: const MaterialApp(
            home: AppShellScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();
      expect(find.text('सिक्नुहोस् (Placeholder)'), findsOneWidget);
      expect(find.byKey(const Key('home-title')), findsNothing);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('भाषा चयन गर्नुहोस्'), findsOneWidget);
      expect(find.text('सिक्नुहोस् (Placeholder)'), findsNothing);
    });

    testWidgets('shows read-aloud action feedback when pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) {
              final db = AppDatabase.forTesting(NativeDatabase.memory());
              ref.onDispose(db.close);
              return db;
            }),
            settingsRepositoryProvider.overrideWith(
              (ref) => FakeSettingsRepository(),
            ),
          ],
          child: const MaterialApp(
            home: AppShellScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Read aloud'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.record_voice_over));
      await tester.pump();

      expect(find.text('Read aloud is not available yet.'), findsOneWidget);
    });
  });
}
