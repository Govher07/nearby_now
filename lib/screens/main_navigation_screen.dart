import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/data/current_user.dart';
import 'business_screen.dart';
import 'create_event_screen.dart';
import 'home_screen.dart';
import 'map_screen.dart' as map_screen;
import 'my_events_screen.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static const String selectedTabKey = 'selected_tab_index';

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadSelectedTab();
  }

  Future<void> loadSelectedTab() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      selectedIndex = prefs.getInt(selectedTabKey) ?? 0;
    });
  }

  Future<void> saveSelectedTab(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(selectedTabKey, index);
  }

  List<Widget> get screens {
    if (currentUser?.role == 'business_owner') {
      return [
        const BusinessScreen(),
        CreateEventScreen(
          onEventPosted: () {
            setState(() {
              selectedIndex = 0;
            });

            saveSelectedTab(0);
          },
        ),
        const MyEventsScreen(),
        const ProfileScreen(),
      ];
    }

    return const [
      HomeScreen(),
      map_screen.MapScreen(),
      SavedScreen(),
      ProfileScreen(),
    ];
  }

  List<NavigationDestination> get destinations {
    if (currentUser?.role == 'business_owner') {
      return const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: 'Create',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note),
          label: 'My Events',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }

    return const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.map_outlined),
        selectedIcon: Icon(Icons.map),
        label: 'Map',
      ),
      NavigationDestination(
        icon: Icon(Icons.bookmark_border),
        selectedIcon: Icon(Icons.bookmark),
        label: 'Saved',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    saveSelectedTab(index);
  }

  @override
  Widget build(BuildContext context) {
    final int safeIndex = selectedIndex >= screens.length ? 0 : selectedIndex;

    return Scaffold(
      body: screens[safeIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: onTabTapped,
        destinations: destinations,
      ),
    );
  }
}