import 'package:flutter/material.dart';

import '../core/data/current_user.dart';
import 'choose_user_type_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String get modeText {
    if (currentUser?.role == 'business_owner') {
      return 'Business Owner';
    }

    return 'Event Seeker';
  }

  String get userName {
    return currentUser?.name ?? 'Nearby Now User';
  }

  String get userEmail {
    return currentUser?.email ?? 'No email available';
  }

  Future<void> logout(BuildContext context) async {
    await CurrentUserStorage.clearUser();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const ChooseUserTypeScreen(),
      ),
      (route) => false,
    );
  }

  void switchMode(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const ChooseUserTypeScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile / Menu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 36,
              child: Icon(Icons.person, size: 40),
            ),

            const SizedBox(height: 16),

            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              userEmail,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 8),

            Text(
              'Current mode: $modeText',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            Card(
              child: ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text('Switch Account Type'),
                subtitle: const Text(
                  'Return to role selection and choose a different mode',
                ),
                onTap: () {
                  switchMode(context);
                },
              ),
            ),

            const Card(
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                subtitle: Text('Coming soon'),
              ),
            ),

            const Card(
              child: ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('Help & Support'),
                subtitle: Text('Coming soon'),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log Out'),
                subtitle: const Text('Return to account selection'),
                onTap: () {
                  logout(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}