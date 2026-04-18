import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'signup_screen.dart';
import '../constants.dart';
import '../models/user.dart';
import '../blocs/user/user_bloc.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validateForm);
    // Initialize with +1
    if (_phoneController.text.isEmpty) {
      _phoneController.text = '+1 ';
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validateForm);
    _phoneController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // The format "+1 555 555 5555" is exactly 15 characters
      _isFormValid = _phoneController.text.length == 15;
    });
  }

  // Login by only verifying the phone number with the backend
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Strip whitespaces for the database: +1 555 555 5555 -> +15555555555
    final phone = _phoneController.text.replaceAll(' ', '');

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/Auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Phone': phone}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body)['user'];
        
        if (!mounted) return;
        
        final user = User.fromJson(userData);

        // Update the Flutter BLoC State with the real user data
        context.read<UserBloc>().add(SetUserEvent(user));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful! Welcome back, ${user.name}.'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Navigate to Home!
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (response.statusCode == 404) {
        _showError('No account found with this phone number. Please sign up.');
      } else {
        _showError('Login failed. Please try again.');
      }
    } catch (e) {
      _showError('Failed to connect to the server.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo/Branding
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0058BA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: Color(0xFF0058BA), size: 32),
                ),
                const SizedBox(height: 32),
                
                Text(
                  'Welcome to ZimPay',
                  style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF2B2F32)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number to login.',
                  style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF585C5F)),
                ),
                const SizedBox(height: 40),

                // The Input Field
                Form(
                  key: _formKey,
                  onChanged: _validateForm,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.inter(fontSize: 18),
                    inputFormatters: [
                      PhoneNumberFormatter(),
                      LengthLimitingTextInputFormatter(15),
                    ],
                    decoration: InputDecoration(
                      hintText: '+1 555 555 5555',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value == '+1 ') return 'Please enter phone number';
                      if (value.length < 15) return 'Invalid phone number format';
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(height: 32),

                // The Action Button
                ElevatedButton(
                  onPressed: (_isLoading || !_isFormValid) ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0058BA),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Login', 
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New here? ',
                      style: GoogleFonts.inter(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: Text(
                        'Sign up',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0058BA),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    if (text.isEmpty) {
      return newValue.copyWith(text: '+1 ', selection: const TextSelection.collapsed(offset: 4));
    }
    
    if (!text.startsWith('+1 ')) {
      // If user tries to delete the prefix, put it back
      return oldValue;
    }

    // Extract only digits after '+1 '
    String digits = text.substring(3).replaceAll(RegExp(r'\D'), '');
    String formatted = '+1 ';
    
    for (int i = 0; i < digits.length; i++) {
      formatted += digits[i];
      if ((i == 2 || i == 5) && i != digits.length - 1) {
        formatted += ' ';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

