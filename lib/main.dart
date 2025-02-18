import 'package:flutter/material.dart';

import 'package:barista_planet/splash_screen.dart'; // Assuming you already have this screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that Firebase is initialized before app starts

  runApp(const MyApp()); // Now run your app after Firebase initialization
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Your splash screen where users see loading first
    );
  }
}
