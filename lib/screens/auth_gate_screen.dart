import 'package:flutter/material.dart';

import '../core/app_mode.dart' as app_mode;
import '../core/data/current_user.dart';
import 'choose_user_type_screen.dart';
import 'main_navigation_screen.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  late final Future<bool> initializationFuture;

  @override
  void initState() {
    super.initState();
    initializationFuture = initializeApp();
  }

  Future<bool> initializeApp() async {
    final bool hasSavedMode = await app_mode.loadSelectedAppRole();

    await CurrentUserStorage.loadUser();

    if (currentUser != null) {
      await app_mode.saveSelectedAppRole(currentUser!.role);

      return true;
    }

    return hasSavedMode;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool hasSelectedMode = snapshot.data ?? false;

        if (hasSelectedMode) {
          return const MainNavigationScreen();
        }

        return const ChooseUserTypeScreen();
      },
    );
  }
}
