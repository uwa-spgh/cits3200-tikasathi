import 'package:flutter/material.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';

typedef LocalizedText = String Function(AppLocalizations l10n);

/// One piece of educational content shown on the Learn page.
///
/// The words live in the localisation files (`lib/core/l10n/app_*.arb`) under
/// `learnTopic<N>Title`, `learnTopic<N>Summary` and `learnTopic<N>Body`, so
/// content is replaced by editing those entries in both languages. Separate
/// paragraphs in a body with a blank line.
class LearnTopic {
  const LearnTopic({
    required this.id,
    required this.icon,
    required this.title,
    required this.summary,
    required this.body,
  });

  /// Stable identifier, used for widget keys.
  final String id;
  final IconData icon;
  final LocalizedText title;
  final LocalizedText summary;
  final LocalizedText body;

  /// The body split into paragraphs on blank lines.
  List<String> paragraphs(AppLocalizations l10n) => body(l10n)
      .split(RegExp(r'\n\s*\n'))
      .map((String paragraph) => paragraph.trim())
      .where((String paragraph) => paragraph.isNotEmpty)
      .toList();
}

/// The four large tiles shown in the 2x2 grid at the top of the Learn page.
final List<LearnTopic> featuredLearnTopics = <LearnTopic>[
  LearnTopic(
    id: 'topic-1',
    icon: Icons.vaccines_outlined,
    title: (l10n) => l10n.learnTopic1Title,
    summary: (l10n) => l10n.learnTopic1Summary,
    body: (l10n) => l10n.learnTopic1Body,
  ),
  LearnTopic(
    id: 'topic-2',
    icon: Icons.calendar_month_outlined,
    title: (l10n) => l10n.learnTopic2Title,
    summary: (l10n) => l10n.learnTopic2Summary,
    body: (l10n) => l10n.learnTopic2Body,
  ),
  LearnTopic(
    id: 'topic-3',
    icon: Icons.health_and_safety_outlined,
    title: (l10n) => l10n.learnTopic3Title,
    summary: (l10n) => l10n.learnTopic3Summary,
    body: (l10n) => l10n.learnTopic3Body,
  ),
  LearnTopic(
    id: 'topic-4',
    icon: Icons.local_hospital_outlined,
    title: (l10n) => l10n.learnTopic4Title,
    summary: (l10n) => l10n.learnTopic4Summary,
    body: (l10n) => l10n.learnTopic4Body,
  ),
];

/// The four shorter full-width tiles listed below the grid.
final List<LearnTopic> moreLearnTopics = <LearnTopic>[
  LearnTopic(
    id: 'topic-5',
    icon: Icons.help_outline,
    title: (l10n) => l10n.learnTopic5Title,
    summary: (l10n) => l10n.learnTopic5Summary,
    body: (l10n) => l10n.learnTopic5Body,
  ),
  LearnTopic(
    id: 'topic-6',
    icon: Icons.child_care_outlined,
    title: (l10n) => l10n.learnTopic6Title,
    summary: (l10n) => l10n.learnTopic6Summary,
    body: (l10n) => l10n.learnTopic6Body,
  ),
  LearnTopic(
    id: 'topic-7',
    icon: Icons.medical_information_outlined,
    title: (l10n) => l10n.learnTopic7Title,
    summary: (l10n) => l10n.learnTopic7Summary,
    body: (l10n) => l10n.learnTopic7Body,
  ),
  LearnTopic(
    id: 'topic-8',
    icon: Icons.info_outline,
    title: (l10n) => l10n.learnTopic8Title,
    summary: (l10n) => l10n.learnTopic8Summary,
    body: (l10n) => l10n.learnTopic8Body,
  ),
];
