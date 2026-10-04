import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/app_shell/presentation/read_aloud_button.dart';
import 'package:tikasathi/features/learn/domain/learn_topics.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';

/// Learn tab: an FAQ-style list of collapsible tabs. Tapping a tab's title
/// expands it to show that topic's information.
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
          for (final LearnTopic topic in learnTopics) ...[
            _TopicTab(topic: topic),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

const Color _tileBackground = Color(0xFFEFF5FF);
const Color _tileBorder = Color(0xFFCFE0FA);
const Color _tileAccent = Color(0xFF0E64C5);
const Color _bodyText = Color(0xFF334155);

class _TopicTab extends StatelessWidget {
  const _TopicTab({required this.topic});

  final LearnTopic topic;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<List<String>> tableRows = topic.tableRows(l10n);
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      side: const BorderSide(color: _tileBorder),
      borderRadius: BorderRadius.circular(16),
    );
    return ExpansionTile(
      key: Key('learn-${topic.id}'),
      shape: shape,
      collapsedShape: shape,
      backgroundColor: _tileBackground,
      collapsedBackgroundColor: _tileBackground,
      iconColor: _tileAccent,
      collapsedIconColor: _tileAccent,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      title: Text(
        topic.title(l10n),
        style: const TextStyle(
          color: _tileAccent,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      children: [
        for (final String paragraph in topic.paragraphs(l10n))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text.rich(
              TextSpan(
                children: [
                  for (final TextRun run in boldRuns(paragraph))
                    TextSpan(
                      text: run.text,
                      style: run.bold
                          ? const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            )
                          : null,
                    ),
                ],
              ),
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: _bodyText,
              ),
            ),
          ),
        if (tableRows.isNotEmpty) _TopicTable(rows: tableRows),
      ],
    );
  }
}

/// A bordered table whose first row is styled as the header.
class _TopicTable extends StatelessWidget {
  const _TopicTable({required this.rows});

  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final int columnCount = rows.first.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Table(
        key: const Key('learn-topic-table'),
        border: TableBorder.all(
          color: _tileBorder,
          borderRadius: BorderRadius.circular(8),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          for (int index = 0; index < rows.length; index++)
            TableRow(
              decoration: BoxDecoration(
                color: index == 0 ? _tileAccent : Colors.white,
              ),
              children: [
                for (int column = 0; column < columnCount; column++)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      column < rows[index].length ? rows[index][column] : '',
                      style: TextStyle(
                        fontSize: 14,
                        color: index == 0 ? Colors.white : _bodyText,
                        fontWeight:
                            index == 0 ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
