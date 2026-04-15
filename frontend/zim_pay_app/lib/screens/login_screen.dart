import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isLoading = false;
  bool _codeSent = false;
  String _verificationId = '';

  // 1. Trigger Firebase Phone Auth
  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty) return;

    setState(() => _isLoading = true);
    
    // Using the Test Settings so you don't hit your Capstone SMS quota!
    await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (usually works on Android)
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _showError('Verification Failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _showError('Failed to start verification.');
    }
  }

  // 2. Verify the 6-digit OTP
  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) return;

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      _showError('Invalid Code. Please try again.');
    }
  }

  // 3. Connect to your .NET Backend!
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      // 1. Sign into Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      // 2. Call your brand new .NET API
      final url = Uri.parse('${ApiConstants.baseUrl}/Auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Phone': _phoneController.text}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body)['user'];
        
        if (!mounted) return;
        
        final user = User.fromJson(userData);

        // 3. Update the Flutter BLoC State with the real user data
        context.read<UserBloc>().add(SetUserEvent(user));

        // 4. Navigate to Home!
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showError('Backend Login Failed.');
      }
    } catch (e) {
      // Catch the pigeon bug if testing locally
      if (e.toString().contains('PigeonUserDetails') && FirebaseAuth.instance.currentUser != null) {
        debugPrint('Caught Pigeon bug, proceeding to backend...');
        // Duplicate the backend call here just for the Pigeon bug workaround
         final url = Uri.parse('${ApiConstants.baseUrl}/Auth/login');
         final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'Phone': _phoneController.text}),
        );
        if (response.statusCode == 200 && mounted) {
           final userData = jsonDecode(response.body)['user'];
           final user = User.fromJson(userData);
           context.read<UserBloc>().add(SetUserEvent(user));
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      } else {
        _showError('Failed to sign in.');
      }
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
                  _codeSent 
                    ? 'Enter the code sent to ${_phoneController.text}'
                    : 'Enter your phone number to get started.',
                  style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF585C5F)),
                ),
                const SizedBox(height: 40),

                // The Input Fields
                if (!_codeSent) ...[
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.inter(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: '+1 555 555 5555',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: GoogleFonts.plusJakartaSans(fontSize: 28, letterSpacing: 4, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '000000',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),

                // The Action Button
                ElevatedButton(
                  onPressed: _isLoading 
                    ? null 
                    : (_codeSent ? _verifyOTP : _verifyPhoneNumber),
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
                        _codeSent ? 'Verify & Login' : 'Send Code', 
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)
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
