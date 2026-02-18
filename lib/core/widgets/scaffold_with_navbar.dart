import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A scaffold widget that provides a persistent bottom navigation bar
/// across multiple screens within the app.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});

  /// The child widget (screen content) to be displayed
  final Widget child;

  /// Determines the current navigation index based on the route location
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/home')) {
      return 0;
    } else if (location.startsWith('/chat')) {
      return 1;
    } else if (location.startsWith('/profile')) {
      return 2;
    } else if (location.startsWith('/settings')) {
      return 3;
    }
    return 0; // Default to home
  }

  /// Handles navigation when a nav item is tapped
  void _onNavItemTapped(int index, BuildContext context) {
    final routes = ['/home', '/chat', '/profile', '/settings'];
    context.go(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);
    const mfuRed = Color(0xFFB71C1C);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            _onNavItemTapped(index, context);
          },
          selectedIndex: currentIndex,
          backgroundColor: Colors.white,
          indicatorColor: mfuRed.withOpacity(0.1),
          elevation: 0,
          height: 65,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: <Widget>[
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home, color: mfuRed),
              label: 'Market',
            ),
            NavigationDestination(
              icon: const Icon(Icons.chat_bubble_outline),
              selectedIcon: const Icon(Icons.chat_bubble, color: mfuRed),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person, color: mfuRed),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings, color: mfuRed),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
