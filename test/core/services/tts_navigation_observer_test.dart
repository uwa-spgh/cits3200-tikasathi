import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikasathi/core/services/tts_navigation_observer.dart';

void main() {
  test('stops speech for pushed, popped, and replaced routes', () {
    int stopCalls = 0;
    final TtsNavigationObserver observer = TtsNavigationObserver(
      stopSpeech: () async {
        stopCalls++;
      },
    );

    final MaterialPageRoute<void> firstRoute = MaterialPageRoute<void>(
      builder: (_) => const SizedBox(),
    );
    final MaterialPageRoute<void> secondRoute = MaterialPageRoute<void>(
      builder: (_) => const SizedBox(),
    );

    observer.didPush(firstRoute, null);
    observer.didPush(secondRoute, firstRoute);
    observer.didPop(secondRoute, firstRoute);
    observer.didReplace(newRoute: firstRoute, oldRoute: secondRoute);

    expect(stopCalls, 4);
  });
}
