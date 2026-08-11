import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1), // Blue primary color
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('TikaSathi Initialized'),
        ),
      ),
    );
  }
}
