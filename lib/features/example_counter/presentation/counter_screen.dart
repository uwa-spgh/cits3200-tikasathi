import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/counter_notifier.dart';

// 1. Extend ConsumerWidget instead of StatelessWidget to access Riverpod
class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Use ref.watch() to listen to state changes and rebuild the UI automatically
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Example Feature')),
      body: Center(
        child: Text(
          'Count: $count',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // 3. Use ref.read() inside callbacks like onPressed to access the notifier without rebuilding
        onPressed: () => ref.read(counterProvider.notifier).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
