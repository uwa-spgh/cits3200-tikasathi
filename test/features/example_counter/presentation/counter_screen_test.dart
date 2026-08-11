import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tikasathi/features/example_counter/presentation/counter_screen.dart';

void main() {
  group('CounterScreen Widget', () {
    testWidgets('displays initial count of 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CounterScreen(),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);
    });

    testWidgets('tapping FAB increments the counter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CounterScreen(),
          ),
        ),
      );

      // Tap the floating action button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
      expect(find.text('Count: 0'), findsNothing);
    });
  });
}
