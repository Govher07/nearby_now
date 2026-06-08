import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_mode.dart' as app_mode;
import '../core/data/current_user.dart';
import 'business_screen.dart';
import 'choose_user_type_screen.dart';
import 'create_event_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'map_screen.dart' as map_screen;
import 'my_events_screen.dart';
import 'profile_screen.dart';
import 'register_screen.dart';
import 'saved_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final bool forceHomeTab;

  const MainNavigationScreen({
    super.key,
    this.forceHomeTab = false,
  });

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

    if (widget.forceHomeTab) {
      await prefs.setInt(selectedTabKey, 0);

      setState(() {
        selectedIndex = 0;
      });

      return;
    }

    setState(() {
      selectedIndex = prefs.getInt(selectedTabKey) ?? 0;
    });
  }

  Future<void> saveSelectedTab(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(selectedTabKey, index);
  }

  bool get isBusinessMode {
    return app_mode.selectedAppRole == 'business_owner';
  }

  bool get isBusinessOwnerLoggedIn {
    return currentUser?.role == 'business_owner';
  }

  bool get userMatchesSelectedMode {
    return currentUser != null && currentUser!.role == app_mode.selectedAppRole;
  }

  String get modeLabel {
    return isBusinessMode ? 'Business Owner Mode' : 'Event Seeker Mode';
  }

  String get displayName {
    if (!userMatchesSelectedMode) {
      return 'Guest User';
    }

    return currentUser?.name ?? 'User';
  }

  String get displayRole {
    if (!userMatchesSelectedMode) {
      return modeLabel;
    }

    if (currentUser?.role == 'business_owner') {
      return 'Business Owner';
    }

    return 'Event Seeker';
  }

  List<Widget> get screens {
    if (isBusinessMode) {
      if (!isBusinessOwnerLoggedIn) {
        return const [
          _BusinessGuestScreen(),
          _BusinessGuestScreen(),
          _BusinessGuestScreen(),
          ProfileScreen(),
        ];
      }

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
      ProfileScreen(),
    ];
  }

  List<NavigationDestination> get destinations {
    if (isBusinessMode) {
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

  void openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          selectedRole: app_mode.selectedAppRole,
        ),
      ),
    );
  }

  void openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(
          selectedRole: app_mode.selectedAppRole,
        ),
      ),
    );
  }

  void openChooseMode() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const ChooseUserTypeScreen(),
      ),
      (route) => false,
    );
  }

  void openSavedEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedScreen(),
      ),
    );
  }

  void logout() {
    setState(() {
      currentUser = null;
      selectedIndex = 0;
    });

    saveSelectedTab(0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out'),
      ),
    );
  }

  void showComingSoon(String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: const Text(
            'This feature is coming soon in a future update.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void handleProfileMenuAction(String action) {
    switch (action) {
      case 'signin':
        openLogin();
        break;

      case 'register':
        openRegister();
        break;

      case 'saved':
        openSavedEvents();
        break;

      case 'create':
        onTabTapped(1);
        break;

      case 'my_events':
        onTabTapped(2);
        break;

      case 'settings':
        showComingSoon('Settings');
        break;

      case 'help':
        showComingSoon('Help & Support');
        break;

      case 'change_mode':
        openChooseMode();
        break;

      case 'logout':
        logout();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWebLayout = MediaQuery.sizeOf(context).width >= 900;

    final List<Widget> currentScreens = screens;
    final List<NavigationDestination> currentDestinations = destinations;

    final int safeIndex =
        selectedIndex >= currentScreens.length ? 0 : selectedIndex;

    if (!isWebLayout) {
      return Scaffold(
        body: currentScreens[safeIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: safeIndex,
          onDestinationSelected: onTabTapped,
          destinations: currentDestinations,
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          currentScreens[safeIndex],
          Positioned(
            top: 18,
            right: 24,
            child: buildProfileMenuButton(),
          ),
        ],
      ),
    );
  }

  Widget buildProfileMenuButton() {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      borderRadius: BorderRadius.circular(30),
      child: PopupMenuButton<String>(
        tooltip: 'Account',
        offset: const Offset(0, 48),
        icon: const Icon(Icons.person_outline),
        onSelected: handleProfileMenuAction,
        itemBuilder: (context) {
          return [
            PopupMenuItem<String>(
              enabled: false,
              child: buildProfileMenuHeader(),
            ),

            const PopupMenuDivider(),

            if (!userMatchesSelectedMode)
              const PopupMenuItem<String>(
                value: 'signin',
                child: ListTile(
                  leading: Icon(Icons.login),
                  title: Text('Sign In'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

            if (!userMatchesSelectedMode)
              const PopupMenuItem<String>(
                value: 'register',
                child: ListTile(
                  leading: Icon(Icons.person_add_alt_outlined),
                  title: Text('Register'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

            // Saved Events only for logged-in Event Seeker.
            if (!isBusinessMode && userMatchesSelectedMode)
              const PopupMenuItem<String>(
                value: 'saved',
                child: ListTile(
                  leading: Icon(Icons.bookmark_border),
                  title: Text('Saved Events'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

            if (isBusinessMode && isBusinessOwnerLoggedIn)
              const PopupMenuItem<String>(
                value: 'create',
                child: ListTile(
                  leading: Icon(Icons.add_circle_outline),
                  title: Text('Create Event'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

            if (isBusinessMode && isBusinessOwnerLoggedIn)
              const PopupMenuItem<String>(
                value: 'my_events',
                child: ListTile(
                  leading: Icon(Icons.event_note_outlined),
                  title: Text('My Events'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

            const PopupMenuDivider(),

            const PopupMenuItem<String>(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Settings'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const PopupMenuItem<String>(
              value: 'help',
              child: ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('Help & Support'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const PopupMenuItem<String>(
              value: 'change_mode',
              child: ListTile(
                leading: Icon(Icons.swap_horiz),
                title: Text('Change Mode'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            if (userMatchesSelectedMode) const PopupMenuDivider(),

            if (userMatchesSelectedMode)
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log Out'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ];
        },
      ),
    );
  }

  Widget buildProfileMenuHeader() {
    return SizedBox(
      width: 260,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: Icon(
              isBusinessMode
                  ? Icons.storefront_outlined
                  : Icons.person_outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayRole,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessGuestScreen extends StatelessWidget {
  const _BusinessGuestScreen();

  void openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          selectedRole: 'business_owner',
        ),
      ),
    );
  }

  void openRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(
          selectedRole: 'business_owner',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWebLayout = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: isWebLayout
          ? null
          : AppBar(
              title: const Text('Business Owner'),
            ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 560,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        size: 64,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Business Owner Mode',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sign in or register to create events, manage your listings, and view your business dashboard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            openLogin(context);
                          },
                          child: const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            openRegister(context);
                          },
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}