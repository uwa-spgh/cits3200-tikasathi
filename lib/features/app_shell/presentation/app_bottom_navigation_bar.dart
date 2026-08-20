import 'package:flutter/material.dart';

import '../domain/app_navigation_controller.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.selectedSection,
    required this.onDestinationSelected,
  });

  final AppSection selectedSection;
  final ValueChanged<AppSection> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedSection.index,
      onTap: (int index) {
        onDestinationSelected(AppSection.values[index]);
      },
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1D65C1),
      unselectedItemColor: const Color(0xFF5A6B85),
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Learn',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
