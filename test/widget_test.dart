import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tikasathi/features/app_shell/presentation/app_bottom_navigation_bar.dart';
import 'package:tikasathi/main.dart';

void main() {
  testWidgets('App boots into shell with bottom navigation',
      (WidgetTester tester) async {
    // Wrap in ProviderScope as required by Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: TikaSathiApp(),
      ),
    );

    expect(find.byType(AppBottomNavigationBar), findsOneWidget);
    expect(find.byKey(const Key('home-title')), findsOneWidget);
  });
}
