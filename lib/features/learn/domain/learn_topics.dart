import 'package:flutter/material.dart';

/// One piece of educational content shown on the Learn page.
///
/// The body text is sample lorem ipsum until real content is written, so it is
/// the same in every language. Titles come from localisation via [number].
class LearnTopic {
  const LearnTopic({
    required this.number,
    required this.icon,
    required this.summary,
    required this.paragraphs,
  });

  final int number;
  final IconData icon;
  final String summary;
  final List<String> paragraphs;
}

const List<String> _sampleParagraphs = <String>[
  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod '
      'tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim '
      'veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea '
      'commodo consequat.',
  'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum '
      'dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non '
      'proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
  'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium '
      'doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo '
      'inventore veritatis et quasi architecto beatae vitae dicta sunt '
      'explicabo.',
  'Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut '
      'fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem '
      'sequi nesciunt.',
];

LearnTopic _sampleTopic(int number, IconData icon) => LearnTopic(
      number: number,
      icon: icon,
      summary: 'Lorem ipsum dolor sit amet $number.',
      paragraphs: <String>[
        for (final String paragraph in _sampleParagraphs)
          '[$number] $paragraph',
      ],
    );

/// The four large tiles shown in the 2x2 grid at the top of the Learn page.
final List<LearnTopic> featuredLearnTopics = <LearnTopic>[
  _sampleTopic(1, Icons.vaccines_outlined),
  _sampleTopic(2, Icons.calendar_month_outlined),
  _sampleTopic(3, Icons.health_and_safety_outlined),
  _sampleTopic(4, Icons.local_hospital_outlined),
];

/// The four shorter full-width tiles listed below the grid.
final List<LearnTopic> moreLearnTopics = <LearnTopic>[
  _sampleTopic(5, Icons.help_outline),
  _sampleTopic(6, Icons.child_care_outlined),
  _sampleTopic(7, Icons.medical_information_outlined),
  _sampleTopic(8, Icons.info_outline),
];
