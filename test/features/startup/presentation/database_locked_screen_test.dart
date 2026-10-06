import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/startup/presentation/database_locked_app.dart';

void main() {
  group('DatabaseLockedScreen', () {
    Future<void> pump(
      WidgetTester tester, {
      required Future<void> Function() onStartFresh,
      Locale locale = const Locale('en'),
    }) {
      return tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: DatabaseLockedScreen(onStartFresh: onStartFresh),
          ),
        ),
      );
    }

    final Finder button = find.byKey(const Key('database-locked-start-fresh'));

    testWidgets('explains the problem and offers to start fresh',
        (tester) async {
      await pump(tester, onStartFresh: () async {});

      expect(find.text('Your saved data cannot be opened'), findsOneWidget);
      expect(find.textContaining('import it after starting fresh'),
          findsOneWidget);
      expect(find.text('Start fresh'), findsOneWidget);
    });

    testWidgets('can be read aloud', (tester) async {
      await pump(tester, onStartFresh: () async {});

      expect(find.byType(ReadAloudButton), findsOneWidget);
    });

    testWidgets('is available in Nepali', (tester) async {
      await pump(
        tester,
        onStartFresh: () async {},
        locale: const Locale('ne'),
      );

      expect(find.text('नयाँ सुरु गर्नुहोस्'), findsOneWidget);
    });

    testWidgets('starts fresh once, even if tapped twice', (tester) async {
      final Completer<void> erase = Completer<void>();
      int calls = 0;
      await pump(
        tester,
        onStartFresh: () {
          calls++;
          return erase.future;
        },
      );

      await tester.tap(button);
      await tester.pump();
      await tester.tap(button, warnIfMissed: false);
      await tester.pump();

      expect(calls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      erase.complete();
    });

    testWidgets('shows an error and lets the person try again', (tester) async {
      int calls = 0;
      await pump(
        tester,
        onStartFresh: () async {
          calls++;
          if (calls == 1) {
            throw StateError('disk error');
          }
        },
      );

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text('Could not start fresh. Please try again.'),
          findsOneWidget);

      await tester.tap(button);
      // On success the app replaces this screen, so the spinner keeps going.
      await tester.pump();

      expect(calls, 2);
      expect(
          find.text('Could not start fresh. Please try again.'), findsNothing);
    });
  });
}
