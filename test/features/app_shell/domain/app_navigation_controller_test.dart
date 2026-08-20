import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/features/app_shell/domain/app_navigation_controller.dart';

void main() {
  group('AppNavigationController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('defaults to the home section', () {
      expect(container.read(appNavigationControllerProvider), AppSection.home);
    });

    test('selectSection updates the selected section', () {
      final AppNavigationController controller =
          container.read(appNavigationControllerProvider.notifier);

      controller.selectSection(AppSection.learn);
      expect(container.read(appNavigationControllerProvider), AppSection.learn);

      controller.selectSection(AppSection.settings);
      expect(
        container.read(appNavigationControllerProvider),
        AppSection.settings,
      );
    });
  });
}
