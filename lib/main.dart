import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(
    // ProviderScope is mandatory for Riverpod
    const ProviderScope(
      child: TikaSathiApp(),
    ),
  );
}

class TikaSathiApp extends ConsumerWidget {
  const TikaSathiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'TikaSathi',
      theme: AppTheme.light,
      home: const Scaffold(
        body: Center(
          child: Text('TikaSathi Initialized'),
        ),
      ),
    );
  }
}
