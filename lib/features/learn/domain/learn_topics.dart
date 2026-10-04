import 'package:flutter/material.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';

typedef LocalizedText = String Function(AppLocalizations l10n);

/// One piece of educational content on the Learn page, shown either as a large
/// tile that opens a full page or as a collapsible drop-down.
///
/// The words live in the localisation files (`lib/core/l10n/app_*.arb`) under
/// `learnTopic<N>Title` and `learnTopic<N>Body`, so content is replaced by
/// editing those entries in both languages. Separate paragraphs in a body with
/// a blank line. Wrap text in `**double asterisks**` to show it in bold.
///
/// A topic may also have a [table], written one row per line with cells
/// separated by `|`. The first line is the header row.
class LearnTopic {
  const LearnTopic({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
    this.table,
  });

  /// Stable identifier, used for widget keys.
  final String id;
  final IconData icon;
  final LocalizedText title;
  final LocalizedText body;
  final LocalizedText? table;

  /// The body split into paragraphs on blank lines.
  List<String> paragraphs(AppLocalizations l10n) => body(l10n)
      .split(RegExp(r'\n\s*\n'))
      .map((String paragraph) => paragraph.trim())
      .where((String paragraph) => paragraph.isNotEmpty)
      .toList();

  /// The table split into rows of trimmed cells, header row first. Empty when
  /// the topic has no table.
  List<List<String>> tableRows(AppLocalizations l10n) {
    final LocalizedText? table = this.table;
    if (table == null) {
      return const <List<String>>[];
    }
    return table(l10n)
        .split('\n')
        .where((String line) => line.trim().isNotEmpty)
        .map((String line) =>
            line.split('|').map((String cell) => cell.trim()).toList())
        .toList();
  }
}

/// A stretch of text that is either all bold or all plain.
typedef TextRun = ({String text, bool bold});

/// Splits [text] on `**` markers into alternating plain and bold runs,
/// dropping the markers and any empty runs. An unclosed `**` makes the rest of
/// the text bold.
List<TextRun> boldRuns(String text) {
  final List<String> parts = text.split('**');
  return <TextRun>[
    for (int index = 0; index < parts.length; index++)
      if (parts[index].isNotEmpty) (text: parts[index], bold: index.isOdd),
  ];
}

/// The four large tiles in the 2x2 grid at the top of the Learn page. Tapping
/// one opens its full page.
final List<LearnTopic> featuredLearnTopics = <LearnTopic>[
  LearnTopic(
    id: 'topic-1',
    icon: Icons.health_and_safety_outlined,
    title: (l10n) => l10n.learnTopic1Title,
    body: (l10n) => l10n.learnTopic1Body,
  ),
  LearnTopic(
    id: 'topic-5',
    icon: Icons.thermostat_outlined,
    title: (l10n) => l10n.learnTopic5Title,
    body: (l10n) => l10n.learnTopic5Body,
  ),
  LearnTopic(
    id: 'topic-6',
    icon: Icons.fact_check_outlined,
    title: (l10n) => l10n.learnTopic6Title,
    body: (l10n) => l10n.learnTopic6Body,
  ),
  LearnTopic(
    id: 'topic-10',
    icon: Icons.vaccines_outlined,
    title: (l10n) => l10n.learnTopic10Title,
    body: (l10n) => l10n.learnTopic10Body,
    table: (l10n) => l10n.learnTopic10Table,
  ),
];

/// The collapsible drop-downs listed below the grid, in order.
final List<LearnTopic> moreLearnTopics = <LearnTopic>[
  LearnTopic(
    id: 'topic-2',
    icon: Icons.calendar_month_outlined,
    title: (l10n) => l10n.learnTopic2Title,
    body: (l10n) => l10n.learnTopic2Body,
  ),
  LearnTopic(
    id: 'topic-3',
    icon: Icons.event_busy_outlined,
    title: (l10n) => l10n.learnTopic3Title,
    body: (l10n) => l10n.learnTopic3Body,
  ),
  LearnTopic(
    id: 'topic-4',
    icon: Icons.verified_user_outlined,
    title: (l10n) => l10n.learnTopic4Title,
    body: (l10n) => l10n.learnTopic4Body,
  ),
  LearnTopic(
    id: 'topic-7',
    icon: Icons.badge_outlined,
    title: (l10n) => l10n.learnTopic7Title,
    body: (l10n) => l10n.learnTopic7Body,
  ),
  LearnTopic(
    id: 'topic-8',
    icon: Icons.location_on_outlined,
    title: (l10n) => l10n.learnTopic8Title,
    body: (l10n) => l10n.learnTopic8Body,
  ),
  LearnTopic(
    id: 'topic-9',
    icon: Icons.checklist,
    title: (l10n) => l10n.learnTopic9Title,
    body: (l10n) => l10n.learnTopic9Body,
  ),
];

/// Every Learn topic: the featured tiles followed by the drop-downs.
List<LearnTopic> get allLearnTopics => <LearnTopic>[
      ...featuredLearnTopics,
      ...moreLearnTopics,
    ];
