import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: RegistrationPage()));
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ninController = TextEditingController();
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _nationalId = '';
  String _selectedPaymentMethod = 'Paid at the Institute';
  bool _isSubmitting = false;

  final List<String> _paymentMethods = [
    'Paid at the Institute',
  ];

  @override
  void dispose() {
    _ninController.dispose();
    super.dispose();
  }

  Future<void> _saveRegistrationToFirestore() async {
    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('registrations').add({
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
        'phone': _phone,
        'nationalId': _nationalId,
        'paymentMethod': _selectedPaymentMethod,
        'registrationDate': FieldValue.serverTimestamp(),
        'totalAmount': 80000,
        'status': 'Registered',
      });
      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String? _validateNIN(String? value) {
    if (value == null || value.isEmpty) return 'Enter NIN number';
    if (value.length < 8 || value.length > 14) {
      return 'NIN must be 8-14 characters';
    }
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(value)) return 'Invalid NIN format';
    return null;
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Registration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please confirm your details:'),
            const SizedBox(height: 16),
            Text('Name: $_firstName $_lastName'),
            Text('Email: $_email'),
            Text('Phone: $_phone'),
            Text('NIN: $_nationalId'),
            const SizedBox(height: 16),
            const Text('Amount: UGX 80,000',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _saveRegistrationToFirestore();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF794022),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Success!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 16),
            Text('$_firstName, your registration is complete!',
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('You will receive a confirmation email shortly.',
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState?.reset();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF794022),
              ),
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REGISTER', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF794022),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF794022),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration:
                            _inputDecoration('First Name', Icons.person),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                        onSaved: (value) => _firstName = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: _inputDecoration('Last Name', Icons.person),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                        onSaved: (value) => _lastName = value!.trim(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: _inputDecoration('Email', Icons.email),
                        validator: (value) => value!.isEmpty
                            ? 'Required'
                            : !value.contains('@')
                                ? 'Invalid email'
                                : null,
                        onSaved: (value) => _email = value!.trim(),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration:
                            _inputDecoration('Phone Number', Icons.phone),
                        validator: (value) => value!.isEmpty
                            ? 'Required'
                            : value.length < 10
                                ? 'Invalid number'
                                : null,
                        onSaved: (value) => _phone = value!.trim(),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ninController,
                        decoration:
                            _inputDecoration('National ID (NIN)', Icons.badge),
                        validator: _validateNIN,
                        onSaved: (value) => _nationalId = value!.trim(),
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF794022),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedPaymentMethod,
                        decoration:
                            _inputDecoration('Payment Method', Icons.payment),
                        items: _paymentMethods
                            .map((method) => DropdownMenuItem(
                                  value: method,
                                  child: Text(method),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedPaymentMethod = value!),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Registration Fee:'),
                          Text('UGX 80,000',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _showPaymentDialog();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF794022),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'REGISTER NOW',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF794022)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}
