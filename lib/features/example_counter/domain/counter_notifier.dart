import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter_notifier.g.dart';

// 1. Use the @riverpod annotation to generate the provider
@riverpod
class Counter extends _$Counter {
  // 2. The build method initializes the state
  @override
  int build() => 0;

  // 3. Methods to mutate the state
  void increment() {
    state++;
  }
}
