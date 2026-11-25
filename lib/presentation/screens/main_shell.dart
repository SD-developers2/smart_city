import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'complaints_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'admin_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final screens = <Widget>[
      const HomeScreen(),
      const MapScreen(),
      const ComplaintsScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
      if (provider.isAdmin) const AdminScreen(),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Bosh sahifa',
      ),
      const NavigationDestination(
        icon: Icon(Icons.map_outlined),
        selectedIcon: Icon(Icons.map),
        label: 'Xarita',
      ),
      const NavigationDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment),
        label: 'Murojaatlar',
      ),
      const NavigationDestination(
        icon: Icon(Icons.notifications_outlined),
        selectedIcon: Icon(Icons.notifications),
        label: 'Xabarlar',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profil',
      ),
      if (provider.isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];

    final safeIndex =
        provider.selectedIndex >= 0 &&
                provider.selectedIndex < screens.length
            ? provider.selectedIndex
            : 0;

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (index) {
          context.read<AppProvider>().changeTab(index);
        },
        destinations: destinations,
      ),
    );
  }
}
