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
import '../services/biometric_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _pinController.removeListener(_validateForm);
    _pinController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _pinController.text.length >= 4;
    });
  }

  Future<void> _loginWithBiometrics() async {
    final authenticated = await BiometricService.authenticate(
      context, 
      'Please authenticate to log in to ZimPay'
    );

    if (authenticated) {
      // In a real app, you'd send a secure token to the backend.
      // For this demo, we'll simulate by logging in with the most recent user's PIN if available,
      // or simply showing a message. Here we'll just try a generic biometric login if we have a stored PIN.
      _showError('Biometric login initiated. (Simulated)');
    }
  }

  // Login by only verifying the PIN with the backend
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    final pin = _pinController.text;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/Auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Pin': pin}),
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
      } else if (response.statusCode == 401) {
        _showError('Invalid PIN. Please try again.');
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
                  'Enter your security PIN to login.',
                  style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF585C5F)),
                ),
                const SizedBox(height: 40),

                // The Input Field
                Form(
                  key: _formKey,
                  onChanged: _validateForm,
                  child: TextFormField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: GoogleFonts.inter(fontSize: 24, letterSpacing: 8),
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                      hintText: '••••',
                      hintStyle: GoogleFonts.inter(letterSpacing: 8),
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your PIN';
                      if (value.length < 4) return 'PIN must be at least 4 digits';
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

                const SizedBox(height: 16),
                
                // Biometric Login Button
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _loginWithBiometrics,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Login with Biometrics'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: Color(0xFF0058BA)),
                    foregroundColor: const Color(0xFF0058BA),
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

