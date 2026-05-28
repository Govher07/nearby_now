import 'package:flutter/material.dart';

import '../core/data/current_user.dart';
import 'choose_user_type_screen.dart';
import 'main_navigation_screen.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CurrentUserStorage.loadUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (currentUser != null) {
          return const MainNavigationScreen();
        }

        return const ChooseUserTypeScreen();
      },
    );
  }
}