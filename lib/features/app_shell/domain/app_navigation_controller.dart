import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_navigation_controller.g.dart';

enum AppSection {
  home,
  learn,
  settings,
}

@Riverpod(keepAlive: true)
class AppNavigationController extends _$AppNavigationController {
  @override
  AppSection build() => AppSection.home;

  void selectSection(AppSection section) {
    state = section;
  }
}
