import 'package:tikasathi/core/generated/app_localizations.dart';

typedef LocalizedText = String Function(AppLocalizations l10n);

/// One question-style section on the Learn page, shown as a collapsible tab.
///
/// The words live in the localisation files (`lib/core/l10n/app_*.arb`) under
/// `learnTopic<N>Title` and `learnTopic<N>Body`, so content is replaced by
/// editing those entries in both languages. Separate paragraphs in a body with
/// a blank line.
///
/// A topic may also have a [table], written one row per line with cells
/// separated by `|`. The first line is the header row.
class LearnTopic {
  const LearnTopic({
    required this.id,
    required this.title,
    required this.body,
    this.table,
  });

  /// Stable identifier, used for widget keys.
  final String id;
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

/// The collapsible tabs shown on the Learn page, in order.
final List<LearnTopic> learnTopics = <LearnTopic>[
  LearnTopic(
    id: 'topic-1',
    title: (l10n) => l10n.learnTopic1Title,
    body: (l10n) => l10n.learnTopic1Body,
  ),
  LearnTopic(
    id: 'topic-2',
    title: (l10n) => l10n.learnTopic2Title,
    body: (l10n) => l10n.learnTopic2Body,
  ),
  LearnTopic(
    id: 'topic-3',
    title: (l10n) => l10n.learnTopic3Title,
    body: (l10n) => l10n.learnTopic3Body,
  ),
  LearnTopic(
    id: 'topic-4',
    title: (l10n) => l10n.learnTopic4Title,
    body: (l10n) => l10n.learnTopic4Body,
  ),
  LearnTopic(
    id: 'topic-5',
    title: (l10n) => l10n.learnTopic5Title,
    body: (l10n) => l10n.learnTopic5Body,
  ),
  LearnTopic(
    id: 'topic-6',
    title: (l10n) => l10n.learnTopic6Title,
    body: (l10n) => l10n.learnTopic6Body,
  ),
  LearnTopic(
    id: 'topic-7',
    title: (l10n) => l10n.learnTopic7Title,
    body: (l10n) => l10n.learnTopic7Body,
  ),
  LearnTopic(
    id: 'topic-8',
    title: (l10n) => l10n.learnTopic8Title,
    body: (l10n) => l10n.learnTopic8Body,
  ),
  LearnTopic(
    id: 'topic-9',
    title: (l10n) => l10n.learnTopic9Title,
    body: (l10n) => l10n.learnTopic9Body,
  ),
  LearnTopic(
    id: 'topic-10',
    title: (l10n) => l10n.learnTopic10Title,
    body: (l10n) => l10n.learnTopic10Body,
    table: (l10n) => l10n.learnTopic10Table,
  ),
];
