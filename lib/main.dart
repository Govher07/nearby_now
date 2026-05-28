import 'package:flutter/material.dart';

import 'screens/auth_gate_screen.dart';

void main() {
  runApp(const NearbyNowApp());
}

class NearbyNowApp extends StatelessWidget {
  const NearbyNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nearby Now',
      debugShowCheckedModeBanner: false,
      home: const AuthGateScreen(),
    );
  }
}