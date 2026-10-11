import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/learn/domain/learn_topics.dart';

void main() {
  test('there are ten topics with unique ids', () {
    expect(learnTopics, hasLength(10));
    expect(
      learnTopics.map((LearnTopic topic) => topic.id).toSet(),
      hasLength(10),
    );
  });

  test('only the last topic has a table', () {
    expect(learnTopics.last.table, isNotNull);
    for (final LearnTopic topic in learnTopics.take(9)) {
      expect(topic.table, isNull, reason: topic.id);
    }
  });

  for (final Locale locale in AppLocalizations.supportedLocales) {
    test('every topic has its own content in ${locale.languageCode}', () {
      final AppLocalizations l10n = lookupAppLocalizations(locale);
      for (final LearnTopic topic in learnTopics) {
        expect(topic.title(l10n), isNotEmpty, reason: topic.id);
        expect(
          topic.paragraphs(l10n).isNotEmpty || topic.tableRows(l10n).isNotEmpty,
          isTrue,
          reason: '${topic.id} should have body text or a table',
        );
      }
      expect(
        learnTopics.map((LearnTopic topic) => topic.body(l10n)).toSet(),
        hasLength(learnTopics.length),
        reason: 'each topic should have distinct body text',
      );
    });

    test('the table rows all match the header in ${locale.languageCode}', () {
      final List<List<String>> rows =
          learnTopics.last.tableRows(lookupAppLocalizations(locale));
      expect(rows.length, greaterThan(1));
      for (final List<String> row in rows) {
        expect(row, hasLength(rows.first.length));
        expect(row, everyElement(isNotEmpty));
      }
    });
  }

  test('paragraphs splits the body on blank lines and trims them', () {
    final LearnTopic topic = LearnTopic(
      id: 'test',
      title: (_) => 'Title',
      body: (_) => 'First line\nstill first.\n\n  Second.  \n \n\n\nThird.',
    );

    expect(
      topic.paragraphs(lookupAppLocalizations(const Locale('en'))),
      <String>['First line\nstill first.', 'Second.', 'Third.'],
    );
  });

  test('tableRows splits lines into trimmed cells and skips blank lines', () {
    final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));
    final LearnTopic withTable = LearnTopic(
      id: 'test',
      title: (_) => 'Title',
      body: (_) => 'Body',
      table: (_) => 'A | B\n\n 1|2 \n',
    );
    final LearnTopic withoutTable = LearnTopic(
      id: 'test',
      title: (_) => 'Title',
      body: (_) => 'Body',
    );

    expect(withTable.tableRows(l10n), <List<String>>[
      <String>['A', 'B'],
      <String>['1', '2'],
    ]);
    expect(withoutTable.tableRows(l10n), isEmpty);
  });

  test('boldRuns splits text on ** markers', () {
    expect(boldRuns('plain'), <TextRun>[(text: 'plain', bold: false)]);
    expect(boldRuns('**Myth:** Not true. **Fact:** True.'), <TextRun>[
      (text: 'Myth:', bold: true),
      (text: ' Not true. ', bold: false),
      (text: 'Fact:', bold: true),
      (text: ' True.', bold: false),
    ]);
    expect(boldRuns('a **unclosed'), <TextRun>[
      (text: 'a ', bold: false),
      (text: 'unclosed', bold: true),
    ]);
    expect(boldRuns(''), isEmpty);
  });
}
