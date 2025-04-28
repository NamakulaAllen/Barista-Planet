// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:barista_planet/screens/admin/admin_dashboard.dart';
import 'package:barista_planet/screens/home_screen.dart';
import 'package:barista_planet/screens/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();
  bool _obscurePassword = true; // For password visibility toggle
  bool _isLoading = false; // Added loading state

  // Helper method to show top flash messages with color
  void _showFlashMessage(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating, // Makes it float
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 10,
          right: 10,
        ), // Position at top
      ),
    );
  }

  Future<void> _signIn() async {
    // Set loading state to true when signin starts
    setState(() {
      _isLoading = true;
    });

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showFlashMessage("Please enter both email and password", false);
      // Reset loading state
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Authenticate with Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 1. Check email verification
      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        _showFlashMessage('Please verify your email first', false);
        // Reset loading state
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. Check user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Handle case where user document doesn't exist
        _showFlashMessage('User profile not found', false);
        // Reset loading state
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String role = userDoc.get('role');

      // 3. Redirect based on role
      if (role == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Authentication failed";
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found with this email";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email format";
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled";
          break;
      }
      _showFlashMessage(errorMessage, false);
      // Reset loading state
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showFlashMessage("Error: ${e.toString()}", false);
      // Reset loading state
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show password reset dialog
  void _showPasswordResetDialog() {
    // Pre-fill with the email from the login form if available
    _resetEmailController.text = _emailController.text.trim();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Reset Password',
            style: TextStyle(color: Color(0xFF794022)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email address to receive a password reset link',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _resetEmailController,
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  hintStyle: const TextStyle(color: Color(0xFF794022)),
                  prefixIcon: Icon(Icons.email, color: Color(0xFF794022)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF794022)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF794022)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _sendPasswordResetEmail();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF794022),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Send Reset Link',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Send password reset email
  Future<void> _sendPasswordResetEmail() async {
    if (_resetEmailController.text.trim().isEmpty) {
      _showFlashMessage("Please enter your email address", false);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _resetEmailController.text.trim(),
      );
      _showFlashMessage(
          "Password reset email sent. Please check your inbox.", true);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Failed to send reset email";
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found with this email";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email format";
          break;
      }
      _showFlashMessage(errorMessage, false);
    } catch (e) {
      _showFlashMessage("Error: ${e.toString()}", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed background to white
      body: SafeArea(
        child: SingleChildScrollView(
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
                          hintStyle: const TextStyle(color: Color(0xFF794022)),
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
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password with visibility toggle
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: Color(0xFF794022)),
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
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login Button with loading indicator
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
                            disabledBackgroundColor:
                                Color(0xFF794022).withOpacity(0.7),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'SignIn',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      // Forgot Password Link - Moved below signin button
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed:
                              _isLoading ? null : _showPasswordResetDialog,
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: _isLoading
                                  ? Color(0xFF794022).withOpacity(0.7)
                                  : Color(0xFF794022),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Sign up link
                      SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
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
                                      ? Color(0xFF794022).withOpacity(0.7)
                                      : Color(0xFF794022),
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }
}
