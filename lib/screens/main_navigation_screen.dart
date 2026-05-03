import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'map_screen.dart' as map_screen;
import 'saved_screen.dart';
import 'business_screen.dart';
import 'create_event_screen.dart';
import 'profile_screen.dart';
import '../data/user_mode.dart';
import 'my_events_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  List<Widget> get screens {
    if (selectedUserMode == UserMode.businessOwner) {
        return [
            const BusinessScreen(),
            CreateEventScreen(
                onEventPosted: () {
                    setState(() {
                        selectedIndex = 0;
                    });
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
    if (selectedUserMode == UserMode.businessOwner) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onTabTapped,
        destinations: destinations,
      ),
    );
  }
}