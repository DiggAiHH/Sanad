import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanad_ui/sanad_ui.dart';
import 'package:badges/badges.dart' as badges;

/// Staff app shell with bottom navigation
class StaffShell extends StatelessWidget {
  final Widget child;

  const StaffShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(location),
        onDestinationSelected: (index) => _onItemTap(context, index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Start',
          ),
          NavigationDestination(
            icon: badges.Badge(
              badgeContent: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10)),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: badges.Badge(
              badgeContent: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10)),
              child: const Icon(Icons.chat_bubble),
            ),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: badges.Badge(
              badgeContent: const Text('5', style: TextStyle(color: Colors.white, fontSize: 10)),
              child: const Icon(Icons.task_outlined),
            ),
            selectedIcon: badges.Badge(
              badgeContent: const Text('5', style: TextStyle(color: Colors.white, fontSize: 10)),
              child: const Icon(Icons.task),
            ),
            label: 'Aufgaben',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Team',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/chat')) return 1;
    if (location.startsWith('/tasks')) return 2;
    if (location.startsWith('/team')) return 3;
    return 0;
  }

  void _onItemTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/chat');
        break;
      case 2:
        context.go('/tasks');
        break;
      case 3:
        context.go('/team');
        break;
    }
  }
}
