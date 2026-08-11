import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tikasathi/features/example_counter/domain/counter_notifier.dart';

void main() {
  group('Counter Notifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is 0', () {
      final count = container.read(counterProvider);
      expect(count, 0);
    });

    test('increment increases state by 1', () {
      container.read(counterProvider.notifier).increment();
      expect(container.read(counterProvider), 1);
    });

    test('multiple increments accumulate correctly', () {
      final notifier = container.read(counterProvider.notifier);
      notifier.increment();
      notifier.increment();
      notifier.increment();
      expect(container.read(counterProvider), 3);
    });
  });
}
