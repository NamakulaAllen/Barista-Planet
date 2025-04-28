import 'package:barista_planet/screens/home_screen.dart';
import 'package:barista_planet/screens/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'email_confirmation_page.dart';

// 1. Add this to your pubspec.yaml:
// dependencies:
//   url_launcher: ^6.1.10

// 2. Create a new screen for handling password reset confirmation
class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _isChecking = true;
  bool _isSuccess = false;
  String _message =
      "Please check your email for instructions to reset your password.";

  @override
  void initState() {
    super.initState();
    _checkEmailSent();
  }

  Future<void> _checkEmailSent() async {
    try {
      // Wait for a moment to simulate checking
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _isChecking = false;
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isChecking = false;
        _isSuccess = false;
        _message = "An error occurred: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset Password"),
        backgroundColor: Color(0xFF794022),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isChecking
                  ? CircularProgressIndicator(color: Color(0xFF794022))
                  : Icon(
                      _isSuccess ? Icons.check_circle : Icons.error,
                      color: _isSuccess ? Colors.green : Colors.red,
                      size: 80,
                    ),
              SizedBox(height: 20),
              Text(
                _isSuccess ? "Password Reset Email Sent" : "Error",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF794022),
                ),
              ),
              SizedBox(height: 20),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              if (_isSuccess) ...[
                SizedBox(height: 10),
                Text(
                  "We've sent an email to: ${widget.email}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "1. Open the email and click on the password reset link\n"
                  "2. You'll be directed to a secure page to create a new password\n"
                  "3. After resetting, you can return to the app and sign in",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Button to open email app
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Try to open email app - this is a basic implementation
                        // and may not work on all devices
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: '',
                        );
                        if (await canLaunchUrl(emailLaunchUri)) {
                          await launchUrl(emailLaunchUri);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF794022),
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      icon: Icon(Icons.email),
                      label: Text("Open Email"),
                    ),

                    // Button to resend email
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: widget.email);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Password reset email resent")));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("Failed to resend: ${e.toString()}")));
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF794022),
                        side: BorderSide(color: Color(0xFF794022)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      icon: Icon(Icons.refresh),
                      label: Text("Resend Email"),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Back to Sign In",
                  style: TextStyle(
                      color: Color(0xFF794022), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modified SignInScreen
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true; // For password visibility toggle
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // This is the correct way to sign in with Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // If we get here, sign-in was successful
      if (userCredential.user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      String errorMessage = "Failed to sign in";

      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Wrong password provided";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is not valid";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This user account has been disabled";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Handle any other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Improved password reset function
  Future<void> _resetPassword(String email) async {
    if (email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter an email address")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

      // Navigate to confirmation screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: email.trim(),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Failed to send reset email";

      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is not valid";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    resetEmailController.text =
        _emailController.text; // Pre-fill with current email if any

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Reset Password",
          style: TextStyle(color: Color(0xFF794022)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter your email to receive a password reset link"),
            SizedBox(height: 10),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: TextStyle(color: Color(0xFF794022)),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF794022)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF794022)),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (resetEmailController.text.trim().isNotEmpty) {
                Navigator.pop(context); // Close dialog first
                _resetPassword(resetEmailController.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter an email address")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF794022),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Send Link",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // Top logo section
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      height: 180,
                    ),
                  ),
                ),

                // Sign In Text
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF794022),
                    ),
                  ),
                ),

                // Form fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Address with icon
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email Address',
                            hintStyle:
                                const TextStyle(color: Color(0xFF794022)),
                            prefixIcon:
                                Icon(Icons.email, color: Color(0xFF794022)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF794022)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF794022)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Password with visibility toggle
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle:
                                const TextStyle(color: Color(0xFF794022)),
                            prefixIcon:
                                Icon(Icons.lock, color: Color(0xFF794022)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Color(0xFF794022),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF794022)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF794022)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF794022),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              disabledBackgroundColor: Color(0xFFBB9986),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Forgot Password centered below sign in button
                        Center(
                          child: TextButton(
                            onPressed:
                                _isLoading ? null : _showForgotPasswordDialog,
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: _isLoading
                                    ? Colors.grey
                                    : Color(0xFF794022),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Sign up link
                        SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.black),
                              ),
                              InkWell(
                                onTap: _isLoading
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SignUpScreen()),
                                        );
                                      },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: _isLoading
                                        ? Colors.grey
                                        : Color(0xFF794022),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
