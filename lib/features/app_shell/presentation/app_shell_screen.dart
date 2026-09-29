import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/core/services/tts_controller.dart';
import 'package:tikasathi/features/home/presentation/home_screen.dart';
import 'package:tikasathi/features/learn/presentation/learn_screen.dart';
import 'package:tikasathi/features/settings/presentation/settings_screen.dart';

import '../domain/app_navigation_controller.dart';
import 'app_bottom_navigation_bar.dart';

class AppShellScreen extends ConsumerWidget {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSection selectedSection =
        ref.watch(appNavigationControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      body: SafeArea(
        child: IndexedStack(
          index: selectedSection.index,
          children: const <Widget>[
            HomeScreen(),
            LearnScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedSection: selectedSection,
        onDestinationSelected: (AppSection section) {
          ref.read(ttsControllerProvider.notifier).stop();
          ref
              .read(appNavigationControllerProvider.notifier)
              .selectSection(section);
        },
      ),
    );
  }
}
