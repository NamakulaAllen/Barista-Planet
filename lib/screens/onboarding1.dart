import 'package:flutter/material.dart';
import 'onboarding2.dart';

class OnboardingScreenOne extends StatelessWidget {
  const OnboardingScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Image.asset(
              'assets/images/mine1.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF794022), // Brown color
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Align items to space between
                children: [
                  // Update text style
                  const Text(
                    'See coffee drink recipes and also try at home',
                    style: TextStyle(
                      fontSize: 24, // Increased font size
                      fontFamily: 'Inter', // Set font family to Inter
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(), // Spacer to push the button to the bottom
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingScreenTwo(),
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
    );
  }
}
