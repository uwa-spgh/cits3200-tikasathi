import 'package:flutter/material.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/learn/domain/learn_topics.dart';

/// Full page of information for a single Learn topic.
class LearnTopicScreen extends StatelessWidget {
  const LearnTopicScreen({super.key, required this.topic});

  final LearnTopic topic;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          tooltip: l10n.profileBack,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(topic.icon, size: 32, color: const Color(0xFF0E64C5)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.learnTopicTitle(topic.number),
                      key: const Key('learn-topic-title'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              for (final String paragraph in topic.paragraphs) ...[
                Text(
                  paragraph,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.5,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
