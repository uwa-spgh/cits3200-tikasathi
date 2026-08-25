import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/providers/language_provider.dart';

class LearnPlaceholderScreen extends ConsumerWidget {
  const LearnPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNp = ref.watch(languageProvider) == 'np';

    return Center(
      child: Text(isNp ? 'सिक्नुहोस् (Placeholder)' : 'Learn placeholder'),
    );
  }
}
