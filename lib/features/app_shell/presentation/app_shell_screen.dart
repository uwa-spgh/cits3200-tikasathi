import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/features/home/presentation/home_screen.dart';
import 'package:tikasathi/features/learn/presentation/learn_placeholder_screen.dart';
import 'package:tikasathi/features/settings/presentation/settings_placeholder_screen.dart';

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
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1D65C1),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Read aloud is not available yet.'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.record_voice_over,
                        color: Color(0xFF1D65C1),
                      ),
                      tooltip: 'Read aloud',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: selectedSection.index,
                children: const <Widget>[
                  HomeScreen(),
                  LearnPlaceholderScreen(),
                  SettingsPlaceholderScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedSection: selectedSection,
        onDestinationSelected: (AppSection section) {
          ref
              .read(appNavigationControllerProvider.notifier)
              .selectSection(section);
        },
      ),
    );
  }
}
