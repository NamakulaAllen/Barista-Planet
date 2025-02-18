import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(hintText: 'Enter phone number'),
            ),
            ElevatedButton(
              onPressed: _verifyPhoneNumber,
              child: const Text('Verify Phone Number'),
            ),
            if (_verificationId.isNotEmpty)
              TextField(
                onChanged: (value) {
                  // Listen for OTP code input
                },
                decoration: const InputDecoration(hintText: 'Enter OTP'),
              ),
            ElevatedButton(
              onPressed: _signInWithPhoneNumber,
              child: const Text('Submit OTP'),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Verify phone number
  void _verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        // Navigate to home page after successful registration
        Navigator.pushReplacementNamed(context, '/home');
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message!)));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Step 2: Sign in with the OTP sent to the phone
  void _signInWithPhoneNumber() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: 'user_entered_otp', // Replace with the OTP entered by the user
    );

    try {
      await _auth.signInWithCredential(credential);
      // After successful login, navigate to home page
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
