import 'package:flutter/material.dart';

typedef TtsNavigationStop = Future<void> Function();

class TtsNavigationObserver extends NavigatorObserver {
  TtsNavigationObserver({required this.stopSpeech});

  final TtsNavigationStop stopSpeech;

  @override
  void didPush(Route<void> route, Route<void>? previousRoute) {
    stopSpeech();
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<void> route, Route<void>? previousRoute) {
    stopSpeech();
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<void>? newRoute, Route<void>? oldRoute}) {
    stopSpeech();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
