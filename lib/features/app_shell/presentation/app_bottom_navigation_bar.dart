import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tikasathi/features/settings/domain/app_language.dart';
import 'package:tikasathi/features/settings/domain/language_controller.dart';

import '../domain/app_navigation_controller.dart';

class AppBottomNavigationBar extends ConsumerWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.selectedSection,
    required this.onDestinationSelected,
  });

  final AppSection selectedSection;
  final ValueChanged<AppSection> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppLanguage> languageState =
        ref.watch(languageControllerProvider);

    return languageState.when(
      data: (AppLanguage language) {
        final bool isNp = language == AppLanguage.nepali;
        return BottomNavigationBar(
          currentIndex: selectedSection.index,
          onTap: (int index) {
            onDestinationSelected(AppSection.values[index]);
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1D65C1),
          unselectedItemColor: const Color(0xFF5A6B85),
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_filled),
              label: isNp ? 'गृहपृष्ठ' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              activeIcon: const Icon(Icons.menu_book),
              label: isNp ? 'सिक्नुहोस्' : 'Learn',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: isNp ? 'सेटिङहरू' : 'Settings',
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stackTrace) => SizedBox(
        height: 80,
        child: Center(
          child: Text('Unable to load language settings: $error'),
        ),
      ),
    );
  }
}
