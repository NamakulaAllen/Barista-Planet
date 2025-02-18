import 'package:flutter/material.dart';

class EmailConfirmationPage extends StatefulWidget {
  const EmailConfirmationPage({super.key});

  @override
  EmailConfirmationPageState createState() => EmailConfirmationPageState();
}

class EmailConfirmationPageState extends State<EmailConfirmationPage> {
  // Controller to manage input fields for confirmation code
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  // Function to validate the confirmation code
  bool _isCodeValid() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  // Function to simulate resending the code (you can replace it with actual API call)
  void _resendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Confirmation code resent to your email!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon or Image for Email Confirmation
              const Icon(
                Icons.mail_outline,
                size: 80,
                color: Color(0xFF794022),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Email Confirmation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF794022),
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              const Text(
                'Enter the confirmation code sent to your email.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // Confirmation Code Input (4 digits)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _controllers[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF794022)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_isCodeValid()) {
                      // If the code is valid, show success dialog and navigate to login
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Success'),
                            content:
                                const Text('Account created successfully!'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close dialog
                                  Navigator.pushNamed(
                                      context, '/login'); // Navigate to login
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Show error if code is incomplete
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please enter the full confirmation code.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF794022),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Resend Code
              TextButton(
                onPressed: () {
                  _resendCode();
                },
                child: const Text(
                  'Resend Code',
                  style: TextStyle(
                    color: Color(0xFF794022),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
