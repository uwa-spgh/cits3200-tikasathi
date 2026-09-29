import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/learn/domain/learn_topics.dart';

void main() {
  final List<LearnTopic> allTopics = <LearnTopic>[
    ...featuredLearnTopics,
    ...moreLearnTopics,
  ];

  test('there are four featured and four more topics with unique ids', () {
    expect(featuredLearnTopics, hasLength(4));
    expect(moreLearnTopics, hasLength(4));
    expect(allTopics.map((LearnTopic topic) => topic.id).toSet(), hasLength(8));
  });

  for (final Locale locale in AppLocalizations.supportedLocales) {
    test('every topic has its own content in ${locale.languageCode}', () {
      final AppLocalizations l10n = lookupAppLocalizations(locale);
      for (final LearnTopic topic in allTopics) {
        expect(topic.title(l10n), isNotEmpty, reason: topic.id);
        expect(topic.summary(l10n), isNotEmpty, reason: topic.id);
        expect(topic.paragraphs(l10n), isNotEmpty, reason: topic.id);
      }
      expect(
        allTopics.map((LearnTopic topic) => topic.body(l10n)).toSet(),
        hasLength(allTopics.length),
        reason: 'each topic should have distinct body text',
      );
    });
  }

  test('paragraphs splits the body on blank lines and trims them', () {
    final LearnTopic topic = LearnTopic(
      id: 'test',
      icon: Icons.info_outline,
      title: (_) => 'Title',
      summary: (_) => 'Summary',
      body: (_) => 'First line\nstill first.\n\n  Second.  \n \n\n\nThird.',
    );

    expect(
      topic.paragraphs(lookupAppLocalizations(const Locale('en'))),
      <String>['First line\nstill first.', 'Second.', 'Third.'],
    );
  });
}
