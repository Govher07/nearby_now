import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/user_mode.dart';
import 'main_navigation_screen.dart';

class ChooseUserTypeScreen extends StatelessWidget {
  const ChooseUserTypeScreen({super.key});

  void chooseMode(BuildContext context, UserMode mode) {
    selectedUserMode = mode;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/4.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.14),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 90),

                  const Text(
                    'Nearby\nNow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 58,
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

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoleCard(
                        icon: Icons.event_available_outlined,
                        title: 'Event\nSeeker',
                        onTap: () {
                          chooseMode(context, UserMode.eventSeeker);
                        },
                      ),
                      const SizedBox(width: 18),
                      _RoleCard(
                        icon: Icons.storefront_outlined,
                        title: 'Business\nOwner',
                        onTap: () {
                          chooseMode(context, UserMode.businessOwner);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 42),
                ],
              ),
            ),
          ),

          Positioned(
            right: 28,
            bottom: 32,
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white.withValues(alpha: 0.75),
              size: 34,
            ),
          ),
        ],
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(26),
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: onTap,
            child: Container(
              width: 150,
              height: 150,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 18,
              ),
              decoration: BoxDecoration(
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