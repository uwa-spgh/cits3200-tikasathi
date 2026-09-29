import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/learn/domain/learn_topics.dart';
import 'package:tikasathi/features/learn/presentation/learn_topic_screen.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';

/// Learn tab: a 2x2 grid of featured topics followed by shorter full-width
/// topics. Tapping any tile opens its full page of information.
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
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (final LearnTopic topic in featuredLearnTopics)
                _FeaturedTile(
                  topic: topic,
                  onTap: () => _openTopic(context, topic),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final LearnTopic topic in moreLearnTopics) ...[
            _WideTile(
              topic: topic,
              onTap: () => _openTopic(context, topic),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  void _openTopic(BuildContext context, LearnTopic topic) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LearnTopicScreen(topic: topic),
      ),
    );
  }
}

const Color _tileBackground = Color(0xFFEFF5FF);
const Color _tileBorder = Color(0xFFCFE0FA);
const Color _tileAccent = Color(0xFF0E64C5);

BoxDecoration _tileDecoration() => BoxDecoration(
      color: _tileBackground,
      border: Border.all(color: _tileBorder),
      borderRadius: BorderRadius.circular(16),
    );

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
        padding: const EdgeInsets.all(16),
        decoration: _tileDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(topic.icon, size: 36, color: _tileAccent),
            const Spacer(),
            Text(
              topic.title(l10n),
              style: const TextStyle(
                color: _tileAccent,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              topic.summary(l10n),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideTile extends StatelessWidget {
  const _WideTile({required this.topic, required this.onTap});

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: _tileDecoration(),
        child: Row(
          children: [
            Icon(topic.icon, color: _tileAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                topic.title(l10n),
                style: const TextStyle(
                  color: _tileAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: _tileAccent),
          ],
        ),
      ),
    );
  }
}
