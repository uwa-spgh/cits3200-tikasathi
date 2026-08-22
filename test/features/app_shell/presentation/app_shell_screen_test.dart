import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/features/app_shell/presentation/app_bottom_navigation_bar.dart';
import 'package:tikasathi/features/app_shell/presentation/app_shell_screen.dart';

void main() {
  group('AppShellScreen', () {
    testWidgets('shows home screen by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShellScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomNavigationBar), findsOneWidget);
      expect(find.byKey(const Key('home-title')), findsOneWidget);
      expect(find.text('Learn placeholder'), findsNothing);
      expect(find.text('Settings placeholder'), findsNothing);
      expect(find.byIcon(Icons.record_voice_over), findsOneWidget);
    });

    testWidgets('switches destinations from bottom navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AppShellScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Learn'));
      await tester.pumpAndSettle();
      expect(find.text('Learn placeholder'), findsOneWidget);
      expect(find.byKey(const Key('home-title')), findsNothing);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings placeholder'), findsOneWidget);
      expect(find.text('Learn placeholder'), findsNothing);
    });

    testWidgets('shows read-aloud action feedback when pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
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
