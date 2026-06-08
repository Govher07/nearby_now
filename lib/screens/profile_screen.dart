import 'package:flutter/material.dart';

import '../core/app_mode.dart' as app_mode;
import '../core/data/current_user.dart';
import 'choose_user_type_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'saved_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  bool get isBusinessMode {
    return app_mode.selectedAppRole == 'business_owner';
  }

  bool get userMatchesSelectedMode {
    return currentUser != null && currentUser!.role == app_mode.selectedAppRole;
  }

  bool get canShowSavedEvents {
    return !isBusinessMode && userMatchesSelectedMode;
  }

  String get modeLabel {
    return isBusinessMode ? 'Business Owner Mode' : 'Event Seeker Mode';
  }

  String get userName {
    if (!userMatchesSelectedMode) {
      return 'Guest User';
    }

    return currentUser?.name ?? 'User';
  }

  String get userId {
    if (!userMatchesSelectedMode) {
      return 'Not signed in';
    }

    return currentUser?.id ?? 'Not signed in';
  }

  String get roleLabel {
    if (!userMatchesSelectedMode) {
      return 'Guest';
    }

    if (currentUser?.role == 'business_owner') {
      return 'Business Owner';
    }

    return 'Event Seeker';
  }

  void openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          selectedRole: app_mode.selectedAppRole,
        ),
      ),
    );
  }

  void openRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(
          selectedRole: app_mode.selectedAppRole,
        ),
      ),
    );
  }

  void openSavedEvents(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedScreen(),
      ),
    );
  }

  void changeMode(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const ChooseUserTypeScreen(),
      ),
      (route) => false,
    );
  }

  void logout(BuildContext context) {
    currentUser = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out'),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const ChooseUserTypeScreen(),
      ),
      (route) => false,
    );
  }

  void showComingSoon(BuildContext context, String title) {
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

  @override
  Widget build(BuildContext context) {
    final bool isWebLayout = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: isWebLayout
          ? null
          : AppBar(
              title: const Text('Profile'),
            ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWebLayout ? 720 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isWebLayout ? 32 : 16,
                24,
                isWebLayout ? 32 : 16,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isWebLayout)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  buildProfileHeader(context),

                  const SizedBox(height: 18),

                  if (!userMatchesSelectedMode) buildAuthActions(context),

                  const SizedBox(height: 18),

                  buildModeCard(context),

                  const SizedBox(height: 18),

                  buildMenuSection(context),

                  const SizedBox(height: 18),

                  if (userMatchesSelectedMode)
                    OutlinedButton.icon(
                      onPressed: () {
                        logout(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Log Out'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              child: Icon(
                isBusinessMode
                    ? Icons.storefront_outlined
                    : Icons.person_outline,
                size: 34,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(roleLabel),
                  const SizedBox(height: 4),
                  Text(
                    userId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
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
      ),
    );
  }

  Widget buildAuthActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isBusinessMode
                  ? 'Sign in or register to manage your business events.'
                  : 'Sign in or register to save events and write reviews.',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                openLogin(context);
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                openRegister(context);
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildModeCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          isBusinessMode
              ? Icons.storefront_outlined
              : Icons.event_available_outlined,
        ),
        title: const Text('Current Mode'),
        subtitle: Text(modeLabel),
        trailing: TextButton(
          onPressed: () {
            changeMode(context);
          },
          child: const Text('Change'),
        ),
      ),
    );
  }

  Widget buildMenuSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          if (canShowSavedEvents) ...[
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Saved Events'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                openSavedEvents(context);
              },
            ),
            const Divider(height: 1),
          ],
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showComingSoon(context, 'Settings');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showComingSoon(context, 'Help & Support');
            },
          ),
        ],
      ),
    );
  }
}