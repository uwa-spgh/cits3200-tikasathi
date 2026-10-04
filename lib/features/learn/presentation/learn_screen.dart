import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/learn/domain/learn_topics.dart';
import 'package:tikasathi/features/learn/presentation/learn_topic_content.dart';
import 'package:tikasathi/features/learn/presentation/learn_topic_screen.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';

/// Learn tab: a 2x2 grid of featured topics, each opening a full page, followed
/// by FAQ-style drop-downs that expand in place.
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppLanguage> languageState =
        ref.watch(languageControllerProvider);

    return languageState.when(
      data: (_) => _buildContent(context),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) {
        final AppLocalizations localizations = AppLocalizations.of(context)!;
        return Center(
          child: Text(localizations.appLanguageLoadError(error.toString())),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.learnTitle,
                  key: const Key('learn-title'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              ReadAloudButton(
                tooltip: l10n.childReadAloudTooltip,
                unavailableMessage: l10n.childReadAloudUnavailable,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Rows of two tiles; IntrinsicHeight keeps both tiles in a row the
          // same height when one title wraps onto more lines.
          for (int index = 0;
              index < featuredLearnTopics.length;
              index += 2) ...[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _featuredTile(context, featuredLearnTopics[index]),
                  const SizedBox(width: 12),
                  if (index + 1 < featuredLearnTopics.length)
                    _featuredTile(context, featuredLearnTopics[index + 1])
                  else
                    const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const _TopicList(),
        ],
      ),
    );
  }

  Widget _featuredTile(BuildContext context, LearnTopic topic) => Expanded(
        child: _FeaturedTile(
          topic: topic,
          onTap: () => _openTopic(context, topic),
        ),
      );

  void _openTopic(BuildContext context, LearnTopic topic) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LearnTopicScreen(topic: topic),
      ),
    );
  }
}

/// A large tile in the featured grid: an icon above the topic's title.
class _FeaturedTile extends StatelessWidget {
  const _FeaturedTile({required this.topic, required this.onTap});

  final LearnTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return InkWell(
      key: Key('learn-${topic.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: learnTileBackground,
          border: Border.all(color: learnTileBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 140),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(topic.icon, size: 36, color: learnAccent),
                const SizedBox(height: 12),
                Text(
                  topic.title(l10n),
                  style: const TextStyle(
                    color: learnAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The drop-downs, of which at most one is expanded at a time: opening one
/// collapses whichever was open before.
class _TopicList extends StatefulWidget {
  const _TopicList();

  @override
  State<_TopicList> createState() => _TopicListState();
}

class _TopicListState extends State<_TopicList> {
  final List<ExpansibleController> _controllers = <ExpansibleController>[
    for (final LearnTopic _ in moreLearnTopics) ExpansibleController(),
  ];

  @override
  void dispose() {
    for (final ExpansibleController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onExpansionChanged(int index, bool expanded) {
    if (!expanded) {
      return;
    }
    for (int other = 0; other < _controllers.length; other++) {
      if (other != index && _controllers[other].isExpanded) {
        _controllers[other].collapse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int index = 0; index < moreLearnTopics.length; index++) ...[
          _TopicTab(
            topic: moreLearnTopics[index],
            controller: _controllers[index],
            onExpansionChanged: (bool expanded) =>
                _onExpansionChanged(index, expanded),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TopicTab extends StatelessWidget {
  const _TopicTab({
    required this.topic,
    required this.controller,
    required this.onExpansionChanged,
  });

  final LearnTopic topic;
  final ExpansibleController controller;
  final ValueChanged<bool> onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      side: const BorderSide(color: learnTileBorder),
      borderRadius: BorderRadius.circular(16),
    );
    return ExpansionTile(
      key: Key('learn-${topic.id}'),
      controller: controller,
      onExpansionChanged: onExpansionChanged,
      shape: shape,
      collapsedShape: shape,
      backgroundColor: learnTileBackground,
      collapsedBackgroundColor: learnTileBackground,
      iconColor: learnAccent,
      collapsedIconColor: learnAccent,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      leading: Icon(topic.icon, color: learnAccent),
      title: Text(
        topic.title(l10n),
        style: const TextStyle(
          color: learnAccent,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      children: [LearnTopicContent(topic: topic)],
    );
  }
}
