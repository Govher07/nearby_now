import 'package:flutter/material.dart';
import '../data/user_mode.dart';
import 'choose_user_type_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String get modeText {
    if (selectedUserMode == UserMode.businessOwner) {
      return 'Business Owner';
    }
    return 'Event Seeker';
  }

  void switchMode(BuildContext context) {
    selectedUserMode = null;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ChooseUserTypeScreen(),
      ),
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

            const Text(
              'Nearby Now User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
                subtitle: const Text('Change between Event Seeker and Business Owner'),
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
          ],
        ),
      ),
    );
  }
}