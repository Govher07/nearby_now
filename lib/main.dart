import 'package:flutter/material.dart';
import 'screens/choose_user_type_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const ChooseUserTypeScreen(),
    );
  }
}