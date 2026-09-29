import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/learn/presentation/learn_screen.dart';
import 'package:tikasathi/features/learn/presentation/learn_topic_screen.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';

import '../../../helpers/fake_settings_repository.dart';

Widget _app({Locale locale = const Locale('en')}) => ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWith(
          (ref) => FakeSettingsRepository(),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: LearnScreen()),
      ),
    );

// The grid is itself a Scrollable, so target the page's outer one.
final Finder _pageScrollable = find.byType(Scrollable).first;

void main() {
  group('LearnScreen', () {
    testWidgets('shows four grid tiles and four full-width tiles',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('learn-title')), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(ReadAloudButton), findsOneWidget);
      for (int number = 1; number <= 8; number++) {
        final Finder tile = find.byKey(Key('learn-topic-$number'));
        await tester.scrollUntilVisible(tile, 100, scrollable: _pageScrollable);
        expect(tile, findsOneWidget);
        expect(find.text('Topic $number'), findsOneWidget);
      }
    });

    testWidgets('tapping a tile opens its full page and back returns',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final Finder tile = find.byKey(const Key('learn-topic-6'));
      await tester.scrollUntilVisible(tile, 100, scrollable: _pageScrollable);
      await tester.tap(tile);
      await tester.pumpAndSettle();

      expect(find.byType(LearnTopicScreen), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('learn-topic-title'))).data,
        'Topic 6',
      );
      expect(find.textContaining('placeholder content for topic 6'),
          findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LearnTopicScreen),
          matching: find.byType(ReadAloudButton),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(LearnTopicScreen), findsNothing);
      expect(find.byKey(const Key('learn-title')), findsOneWidget);
    });

    testWidgets('shows topic content in Nepali when Nepali is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app(locale: const Locale('ne')));
      await tester.pumpAndSettle();

      expect(find.text('विषय १'), findsOneWidget);

      await tester.tap(find.byKey(const Key('learn-topic-1')));
      await tester.pumpAndSettle();

      expect(find.textContaining('विषय १ को लागि अस्थायी सामग्री'),
          findsOneWidget);
      expect(find.textContaining('placeholder'), findsNothing);
    });
  });
}
