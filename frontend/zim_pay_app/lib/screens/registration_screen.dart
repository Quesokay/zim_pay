import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/user/user_bloc.dart';
import 'link_tag_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0058BA);
    const backgroundColor = Color(0xFFF8FAFC);
    const surfaceColor = Color(0xFFFFFFFF);
    const onSurfaceVariantColor = Color(0xFF475569);
    const slate600 = Color(0xFF475569);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserCreated) {
            // Identity token logic: The backend currently returns the user ID, 
            // which we will use as the seed for the Identity Token on the tag.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LinkTagScreen(
                  digitalToken: 'ZIMPAY_ID_${state.user.id}', 
                ),
              ),
            );
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Stack(
          children: [
            // Background Decorative Elements
            Positioned(
              top: -MediaQuery.of(context).size.height * 0.1,
              right: -MediaQuery.of(context).size.width * 0.1,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.08),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: const Color(0xFFF8FAFC).withValues(alpha: 0.6),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: slate600),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    'Create Account',
                    style: GoogleFonts.plusJakartaSans(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),

                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 448),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 48,
                              offset: const Offset(0, 24),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_add_outlined, color: primaryColor, size: 48),
                              const SizedBox(height: 24),
                              Text(
                                'Join Zim Pay',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your secure wallet account',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: onSurfaceVariantColor,
                                ),
                              ),
                              const SizedBox(height: 40),

                              _buildTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                icon: Icons.person,
                                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value!.isEmpty ? 'Enter your email' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                validator: (value) => value!.isEmpty ? 'Enter your phone' : null,
                              ),
                              const SizedBox(height: 40),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<UserBloc>().add(
                                            CreateUserEvent(
                                              _emailController.text,
                                              _nameController.text,
                                              _phoneController.text,
                                            ),
                                          );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                    shadowColor: primaryColor.withValues(alpha: 0.2),
                                  ),
                                  child: BlocBuilder<UserBloc, UserState>(
                                    builder: (context, state) {
                                      if (state is UserLoading) {
                                        return const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        );
                                      }
                                      return Text(
                                        'Create Account',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    const primaryColor = Color(0xFF0058BA);
    const onSurfaceVariantColor = Color(0xFF475569);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 16,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: onSurfaceVariantColor, size: 20),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: onSurfaceVariantColor,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}
