import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/learn/domain/learn_topics.dart';
import 'package:tikasathi/features/learn/presentation/learn_screen.dart';
import 'package:tikasathi/features/learn/presentation/learn_topic_content.dart';
import 'package:tikasathi/features/learn/presentation/learn_topic_screen.dart';
import 'package:tikasathi/features/settings/data/settings_providers.dart';

import '../../../helpers/fake_settings_repository.dart';

// Expected text is read from the localisation files, so these tests keep
// passing when the Learn content is edited.
final AppLocalizations _en = lookupAppLocalizations(const Locale('en'));
final AppLocalizations _ne = lookupAppLocalizations(const Locale('ne'));

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

/// A topic's paragraphs as they appear on screen, without `**` markers.
List<String> _shown(LearnTopic topic, AppLocalizations l10n) => <String>[
      for (final String paragraph in topic.paragraphs(l10n))
        boldRuns(paragraph).map((TextRun run) => run.text).join(),
    ];

final Finder _pageScrollable = find.byType(Scrollable).first;

Future<void> _toggle(WidgetTester tester, LearnTopic topic) async {
  final Finder tab = find.byKey(Key('learn-${topic.id}'));
  await tester.scrollUntilVisible(tab, 100, scrollable: _pageScrollable);
  await tester.tap(
    find.descendant(of: tab, matching: find.text(topic.title(_en))),
  );
  await tester.pumpAndSettle();
}

Future<void> _openTile(WidgetTester tester, LearnTopic topic) async {
  final Finder tile = find.byKey(Key('learn-${topic.id}'));
  await tester.scrollUntilVisible(tile, 100, scrollable: _pageScrollable);
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

/// Every [TextSpan] rendered inside [finder].
List<TextSpan> _spansIn(WidgetTester tester, Finder finder) {
  final List<TextSpan> spans = <TextSpan>[];
  for (final RichText text in tester.widgetList<RichText>(
    find.descendant(of: finder, matching: find.byType(RichText)),
  )) {
    text.text.visitChildren((InlineSpan span) {
      if (span is TextSpan) {
        spans.add(span);
      }
      return true;
    });
  }
  return spans;
}

void main() {
  group('LearnScreen', () {
    testWidgets('shows four tiles and six collapsed drop-downs with icons',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('learn-title')), findsOneWidget);
      expect(find.byType(ReadAloudButton), findsOneWidget);
      expect(find.byType(ExpansionTile), findsNWidgets(6));
      for (final LearnTopic topic in allLearnTopics) {
        final Finder entry = find.byKey(Key('learn-${topic.id}'));
        await tester.scrollUntilVisible(
          entry,
          100,
          scrollable: _pageScrollable,
        );
        expect(
          find.descendant(of: entry, matching: find.text(topic.title(_en))),
          findsOneWidget,
        );
        expect(
          find.descendant(of: entry, matching: find.byIcon(topic.icon)),
          findsOneWidget,
        );
        for (final String paragraph in _shown(topic, _en)) {
          expect(find.text(paragraph), findsNothing);
        }
      }
      for (final LearnTopic topic in featuredLearnTopics) {
        expect(
          find.ancestor(
            of: find.byKey(Key('learn-${topic.id}')),
            matching: find.byType(ExpansionTile),
          ),
          findsNothing,
          reason: '${topic.id} should be a tile, not a drop-down',
        );
      }
      expect(find.byType(Table), findsNothing);
    });

    testWidgets('tapping a tile opens its full page and back returns',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final LearnTopic topic = featuredLearnTopics[1];
      await _openTile(tester, topic);

      expect(find.byType(LearnTopicScreen), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('learn-topic-title'))).data,
        topic.title(_en),
      );
      for (final String paragraph in _shown(topic, _en)) {
        expect(find.text(paragraph), findsOneWidget);
      }
      expect(
        find.descendant(
          of: find.byType(LearnTopicScreen),
          matching: find.byType(ReadAloudButton),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(LearnTopicScreen),
          matching: find.byIcon(topic.icon),
        ),
        findsNothing,
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(LearnTopicScreen), findsNothing);
      expect(find.byKey(const Key('learn-title')), findsOneWidget);
    });

    testWidgets('tapping a drop-down expands and collapses its content',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final LearnTopic topic = moreLearnTopics[2];
      final LearnTopic neighbour = moreLearnTopics[1];

      await _toggle(tester, topic);
      for (final String paragraph in _shown(topic, _en)) {
        expect(find.text(paragraph), findsOneWidget);
      }
      expect(find.text(_shown(neighbour, _en).first), findsNothing);

      await _toggle(tester, topic);
      expect(find.text(_shown(topic, _en).first), findsNothing);
    });

    testWidgets('opening a drop-down closes the one that was open',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final LearnTopic first = moreLearnTopics[0];
      final LearnTopic second = moreLearnTopics[1];

      await _toggle(tester, first);
      expect(find.text(_shown(first, _en).first), findsOneWidget);

      await _toggle(tester, second);
      expect(find.text(_shown(second, _en).first), findsOneWidget);
      expect(find.text(_shown(first, _en).first), findsNothing);
    });

    testWidgets('the vaccine tile page shows its table',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final LearnTopic topic = featuredLearnTopics.last;
      final List<List<String>> rows = topic.tableRows(_en);
      await _openTile(tester, topic);

      final Finder table = find.byKey(const Key('learn-topic-table'));
      await tester.scrollUntilVisible(
        table,
        100,
        scrollable: find
            .descendant(
              of: find.byType(LearnTopicScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(table, findsOneWidget);
      expect(
        find.descendant(of: table, matching: find.text(rows.first.first)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: table, matching: find.text(rows.last.last)),
        findsOneWidget,
      );
    });

    testWidgets('shows topic content in Nepali when Nepali is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app(locale: const Locale('ne')));
      await tester.pumpAndSettle();

      final LearnTopic topic = featuredLearnTopics.first;
      expect(find.text(topic.title(_ne)), findsOneWidget);
      expect(find.text(topic.title(_en)), findsNothing);

      await tester.tap(find.byKey(Key('learn-${topic.id}')));
      await tester.pumpAndSettle();

      expect(find.text(_shown(topic, _ne).first), findsOneWidget);
      expect(find.text(_shown(topic, _en).first), findsNothing);
    });

    for (final Locale locale in AppLocalizations.supportedLocales) {
      testWidgets(
          'colours myth labels red and fact labels green in '
          '${locale.languageCode}', (WidgetTester tester) async {
        final AppLocalizations l10n = lookupAppLocalizations(locale);
        await tester.pumpWidget(_app(locale: locale));
        await tester.pumpAndSettle();

        final LearnTopic topic = featuredLearnTopics.firstWhere(
          (LearnTopic topic) => topic.id == 'topic-6',
        );
        await _openTile(tester, topic);

        final List<TextSpan> spans =
            _spansIn(tester, find.byType(LearnTopicScreen));
        Iterable<Color?> coloursOf(String label) => spans
            .where((TextSpan span) => span.text == label)
            .map((TextSpan span) => span.style?.color);

        expect(coloursOf(l10n.learnMythLabel), isNotEmpty);
        expect(coloursOf(l10n.learnMythLabel), everyElement(mythColor));
        expect(coloursOf(l10n.learnFactLabel), isNotEmpty);
        expect(coloursOf(l10n.learnFactLabel), everyElement(factColor));
      });
    }

    for (final Locale locale in AppLocalizations.supportedLocales) {
      testWidgets(
          'tiles fit a small phone with large text in ${locale.languageCode}',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(_app(locale: locale));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
