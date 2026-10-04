import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/learn/domain/learn_topics.dart';
import 'package:tikasathi/features/learn/presentation/learn_screen.dart';
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

void main() {
  group('LearnScreen', () {
    testWidgets('shows ten collapsed tabs', (WidgetTester tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('learn-title')), findsOneWidget);
      expect(find.byType(ReadAloudButton), findsOneWidget);
      for (final LearnTopic topic in learnTopics) {
        final Finder tab = find.byKey(Key('learn-${topic.id}'));
        await tester.scrollUntilVisible(tab, 100, scrollable: _pageScrollable);
        expect(
          find.descendant(of: tab, matching: find.text(topic.title(_en))),
          findsOneWidget,
        );
        for (final String paragraph in _shown(topic, _en)) {
          expect(find.text(paragraph), findsNothing);
        }
      }
      expect(find.byType(Table), findsNothing);
    });

    testWidgets('tapping a tab expands and collapses its content',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final LearnTopic topic = learnTopics[5];
      final LearnTopic neighbour = learnTopics[4];

      await _toggle(tester, topic);
      for (final String paragraph in _shown(topic, _en)) {
        expect(find.text(paragraph), findsOneWidget);
      }
      expect(find.text(_shown(neighbour, _en).first), findsNothing);

      await _toggle(tester, topic);
      expect(find.text(_shown(topic, _en).first), findsNothing);
    });

    testWidgets('opening a tab closes the tab that was open',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final LearnTopic first = learnTopics[0];
      final LearnTopic second = learnTopics[1];

      await _toggle(tester, first);
      expect(find.text(_shown(first, _en).first), findsOneWidget);

      await _toggle(tester, second);
      expect(find.text(_shown(second, _en).first), findsOneWidget);
      expect(find.text(_shown(first, _en).first), findsNothing);
    });

    testWidgets('the last tab shows its table when expanded',
        (WidgetTester tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final LearnTopic topic = learnTopics.last;
      final List<List<String>> rows = topic.tableRows(_en);

      await _toggle(tester, topic);
      final Finder table = find.byKey(const Key('learn-topic-table'));
      await tester.scrollUntilVisible(table, 100, scrollable: _pageScrollable);
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

      final LearnTopic topic = learnTopics.first;
      await tester.tap(find.text(topic.title(_ne)));
      await tester.pumpAndSettle();

      expect(find.text(_shown(topic, _ne).first), findsOneWidget);
      expect(find.text(topic.title(_en)), findsNothing);
      expect(find.text(_shown(topic, _en).first), findsNothing);
    });

    for (final Locale locale in AppLocalizations.supportedLocales) {
      testWidgets(
          'colours myth labels red and fact labels green in '
          '${locale.languageCode}', (WidgetTester tester) async {
        final AppLocalizations l10n = lookupAppLocalizations(locale);
        await tester.pumpWidget(_app(locale: locale));
        await tester.pumpAndSettle();

        final LearnTopic topic = learnTopics[5];
        final Finder tab = find.byKey(Key('learn-${topic.id}'));
        await tester.scrollUntilVisible(tab, 100, scrollable: _pageScrollable);
        await tester.tap(
          find.descendant(of: tab, matching: find.text(topic.title(l10n))),
        );
        await tester.pumpAndSettle();

        final List<TextSpan> spans = <TextSpan>[];
        for (final RichText text in tester.widgetList<RichText>(
          find.descendant(of: tab, matching: find.byType(RichText)),
        )) {
          text.text.visitChildren((InlineSpan span) {
            if (span is TextSpan) {
              spans.add(span);
            }
            return true;
          });
        }
        Iterable<Color?> coloursOf(String label) => spans
            .where((TextSpan span) => span.text == label)
            .map((TextSpan span) => span.style?.color);

        expect(coloursOf(l10n.learnMythLabel), isNotEmpty);
        expect(coloursOf(l10n.learnMythLabel), everyElement(mythColor));
        expect(coloursOf(l10n.learnFactLabel), isNotEmpty);
        expect(coloursOf(l10n.learnFactLabel), everyElement(factColor));
      });
    }
  });
}
