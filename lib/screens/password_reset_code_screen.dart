import 'package:flutter/material.dart';

class ResetPasswordCodeScreen extends StatelessWidget {
  const ResetPasswordCodeScreen({super.key});

  // Function to simulate sending the code
  void _resendCode(BuildContext context) {
    // Simulate the process of sending a verification code
    // Here you would normally trigger an API call to resend the code.

    // Display a success message when the code is sent
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Verification code has been resent successfully!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(
                0xFF794022), // Set the text color to the brown you are using
          ),
        ),
        backgroundColor: Color(0xFFE8C5A5), // Keeping the background as is
        behavior:
            SnackBarBehavior.floating, // Optional: Makes the snack bar floating
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0)
              .copyWith(top: 50.0), // Add extra top padding if needed
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Reset Password Icon
                const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Color(0xFF794022),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF794022),
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  'We’ve sent a code to your email. Please enter it below to proceed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // Code Input Field
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter the verification code',
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF794022)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Reset Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle reset password logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF794022),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Resend Code Option
                GestureDetector(
                  onTap: () {
                    _resendCode(context); // Trigger resend code function
                  },
                  child: const Text(
                    'Didn’t receive the code? Resend',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold, // Make text bold
                      color: Color(0xFF794022), // Set text color to brown
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
