import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/services/tts_controller.dart';
import 'package:tikasathi/features/home/presentation/home_screen.dart';
import 'package:tikasathi/features/learn/presentation/learn_screen.dart';
import 'package:tikasathi/features/settings/presentation/settings_screen.dart';

import '../domain/app_navigation_controller.dart';
import 'app_bottom_navigation_bar.dart';

class AppShellScreen extends ConsumerStatefulWidget {
  const AppShellScreen({super.key});

  @override
  ConsumerState<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends ConsumerState<AppShellScreen> {
  final Map<AppSection, ScrollController> _scrollControllers =
      <AppSection, ScrollController>{
    for (final AppSection section in AppSection.values)
      section: ScrollController(),
  };

  @override
  void dispose() {
    for (final ScrollController controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectSection(AppSection section) {
    final AppSection selectedSection =
        ref.read(appNavigationControllerProvider);
    if (selectedSection == section) {
      final ScrollController controller = _scrollControllers[section]!;
      if (controller.hasClients) {
        controller.jumpTo(0);
      }
    } else {
      ref.read(appNavigationControllerProvider.notifier).selectSection(section);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppSection selectedSection =
        ref.watch(appNavigationControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      body: SafeArea(
        child: IndexedStack(
          index: selectedSection.index,
          children: <Widget>[
            for (final AppSection section in AppSection.values)
              PrimaryScrollController(
                controller: _scrollControllers[section]!,
                child: switch (section) {
                  AppSection.home => const HomeScreen(),
                  AppSection.learn => const LearnScreen(),
                  AppSection.settings => const SettingsScreen(),
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedSection: selectedSection,
        onDestinationSelected: (AppSection section) {
          ref.read(ttsControllerProvider.notifier).stop();
          _selectSection(section);
        },
      ),
    );
  }
}
