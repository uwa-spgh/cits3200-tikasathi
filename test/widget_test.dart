import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tikasathi/main.dart';

void main() {
  testWidgets('App renders the TikaSathi title', (WidgetTester tester) async {
    // Wrap in ProviderScope as required by Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: TikaSathiApp(),
      ),
    );

    // Verify the app boots and renders its initial text
    expect(find.text('TikaSathi Initialized'), findsOneWidget);
  });
}
