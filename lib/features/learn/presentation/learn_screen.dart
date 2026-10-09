import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/generated/app_localizations.dart';
import 'package:tikasathi/core/theme/app_theme.dart';
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

    return Scaffold(
      appBar: BasicAppBar(
        title: l10n.learnTitle,
        isMainTitle: true,
        textGetter: null,
        haveBackButton: false,
        titleKey: const Key('learn-title')
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: _TopicList())
    );
  }
}

const Color _tileBackground = Color(0xFFEFF5FF);
const Color _tileBorder = Color(0xFFCFE0FA);
const Color _tileAccent = Color(0xFF0E64C5);
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

/// The topic tabs, of which at most one is expanded at a time: opening a tab
/// collapses whichever tab was open before.
class _TopicList extends StatefulWidget {
  const _TopicList();

  @override
  State<_TopicList> createState() => _TopicListState();
}

class _TopicListState extends State<_TopicList> {
  final List<ExpansibleController> _controllers = <ExpansibleController>[
    for (final LearnTopic _ in learnTopics) ExpansibleController(),
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
        for (int index = 0; index < learnTopics.length; index++) ...[
          _TopicTab(
            topic: learnTopics[index],
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
    final List<List<String>> tableRows = topic.tableRows(l10n);
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      side: const BorderSide(color: _tileBorder),
      borderRadius: BorderRadius.circular(16),
    );
    return ExpansionTile(
      key: Key('learn-${topic.id}'),
      controller: controller,
      onExpansionChanged: onExpansionChanged,
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
