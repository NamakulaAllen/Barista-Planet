import 'dart:ui';
import 'package:flutter/material.dart';
import 'screens/onboarding1.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 5000), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreenOne(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/image2.jpg',
                fit: BoxFit.cover,
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                child: Container(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 400,
                  width: 400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
