import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/app_mode.dart' as app_mode;
import '../core/data/current_user.dart';
import '../screens/main_navigation_screen.dart';

class ChooseUserTypeScreen extends StatelessWidget {
  const ChooseUserTypeScreen({super.key});

  void chooseMode(BuildContext context, String role) {
    app_mode.selectedAppRole = role;

    // Prevent old logged-in user from leaking into the other mode.
    if (currentUser?.role != role) {
      currentUser = null;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(
          forceHomeTab: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final bool isShortScreen = screenHeight < 700;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/90.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: const Text(
                    'Background image failed to load',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                );
              },
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.22),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    SizedBox(height: isShortScreen ? 42 : 70),

                    const Text(
                      'Nearby\nNow',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 54,
                        height: 0.95,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Choose how you want to explore local events.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 28,
                    right: 28,
                    bottom: isShortScreen ? 28 : 42,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 18,
                    runSpacing: 18,
                    children: [
                      _RoleCard(
                        icon: Icons.event_available_outlined,
                        title: 'Event\nSeeker',
                        onTap: () {
                          chooseMode(context, 'event_seeker');
                        },
                      ),
                      _RoleCard(
                        icon: Icons.storefront_outlined,
                        title: 'Business\nOwner',
                        onTap: () {
                          chooseMode(context, 'business_owner');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 150,
              height: 150,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 42,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}