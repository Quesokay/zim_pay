import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/user/user_bloc.dart';
import '../models/user.dart';
import 'link_tag_screen.dart';
import '../constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _pinController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _emailController.removeListener(_validateForm);
    _pinController.removeListener(_validateForm);
    _nameController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final nameValid = _nameController.text.trim().isNotEmpty;
    final emailValid = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim());
    final pinValid = _pinController.text.length >= 4;
    
    setState(() {
      _isFormValid = nameValid && emailValid && pinValid;
    });
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/User'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'pin': _pinController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> userJson = responseData['data'];
        final String nfcToken = userJson['nfcIdentityToken'];
        final User user = User.fromJson(userJson);

        if (mounted) {
          // 1. Update the Global User State immediately!
          context.read<UserBloc>().add(SetUserEvent(user));

          // 2. Proceed to Link Tag
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LinkTagScreen(digitalToken: nfcToken),
            ),
          );
        }
      } else {
        _showError(responseData['message'] ?? 'Registration failed.');
      }
    } catch (e) {
      _showError('Network error. Could not connect to backend.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2B2F32)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          onChanged: _validateForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0058BA),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join ZimPay to unify your digital wallets.',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              
              _buildTextField(
                controller: _nameController, 
                label: 'Full Name', 
                icon: Icons.person,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController, 
                label: 'Email Address', 
                icon: Icons.email, 
                isEmail: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email is required';
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _pinController, 
                label: 'Security PIN', 
                icon: Icons.lock_outline, 
                isPin: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'PIN is required';
                  if (value.length < 4) return 'PIN must be at least 4 digits';
                  return null;
                },
              ),
              
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_isFormValid) ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0058BA),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Register & Link Tag', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    bool isEmail = false, 
    bool isPin = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : (isPin ? TextInputType.number : TextInputType.text),
      obscureText: isPin,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: isPin 
        ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)] 
        : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0058BA)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0058BA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
