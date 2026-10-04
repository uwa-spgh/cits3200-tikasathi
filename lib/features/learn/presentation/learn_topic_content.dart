import 'package:flutter/material.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/features/learn/domain/learn_topics.dart';

const Color learnTileBackground = Color(0xFFEFF5FF);
const Color learnTileBorder = Color(0xFFCFE0FA);
const Color learnAccent = Color(0xFF0E64C5);
const Color _bodyText = Color(0xFF334155);
const Color _boldText = Color(0xFF0F172A);

/// Colours for the "Myth:" and "Fact:" labels, public for tests.
const Color mythColor = Color(0xFFB51D1D);
const Color factColor = Color(0xFF166534);

/// Bold text matching the localised "Myth:" or "Fact:" label is coloured red
/// or green; any other bold text uses the heading colour.
Color _boldColor(AppLocalizations l10n, String text) {
  final String label = text.trim();
  if (label == l10n.learnMythLabel) {
    return mythColor;
  }
  if (label == l10n.learnFactLabel) {
    return factColor;
  }
  return _boldText;
}

/// A topic's paragraphs followed by its table, if it has one. Shared by the
/// drop-downs and the full topic page so both render content the same way.
class LearnTopicContent extends StatelessWidget {
  const LearnTopicContent({super.key, required this.topic});

  final LearnTopic topic;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<List<String>> tableRows = topic.tableRows(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          ? TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _boldColor(l10n, run.text),
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
          color: learnTileBorder,
          borderRadius: BorderRadius.circular(8),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          for (int index = 0; index < rows.length; index++)
            TableRow(
              decoration: BoxDecoration(
                color: index == 0 ? learnAccent : Colors.white,
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
