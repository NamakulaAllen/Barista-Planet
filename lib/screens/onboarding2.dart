import 'package:flutter/material.dart';
import 'login_page.dart'; // Ensure this path is correct

class OnboardingScreenTwo extends StatelessWidget {
  const OnboardingScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Image Section (upper half)
            Expanded(
              flex: 5,
              child: Image.asset(
                'assets/images/mine2.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            // Text and Button Section (bottom half)
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: const Color(0xFF794022),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title text
                    const Text(
                      'Stay up to date with\ncoffee world news',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontStyle: FontStyle.italic,
                        color: Colors.white70,
                      ),
                    ),
                    // Next Button
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          // Navigate to the LoginPage when the "Next" button is pressed
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const LoginPage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin =
                                    Offset(1.0, 0.0); // Slide transition
                                const end = Offset.zero;
                                const curve = Curves.ease;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
