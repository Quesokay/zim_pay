import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/user/user_bloc.dart';
import 'home_screen.dart';
import 'registration_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _identifierController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0058BA);
    const backgroundColor = Color(0xFFF8FAFC);
    const surfaceColor = Color(0xFFFFFFFF);
    const onSurfaceVariantColor = Color(0xFF475569);
    const slate50 = Color(0xFFF8FAFC);
    const slate200 = Color(0xFFE2E8F0);
    const slate600 = Color(0xFF475569);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserCreated) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
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
            Positioned(
              bottom: -MediaQuery.of(context).size.height * 0.1,
              left: -MediaQuery.of(context).size.width * 0.1,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            CustomScrollView(
              slivers: [
                // TopAppBar
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: const Color(0xFFF8FAFC).withValues(alpha: 0.6),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: slate600),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    'Zim Pay',
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
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.help_outline, color: slate600),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                  ],
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Branding Area
                            const SizedBox(height: 8),
                            const Icon(Icons.account_balance_wallet, color: primaryColor, size: 48),
                            const SizedBox(height: 24),
                            Text(
                              'Sign in',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'with your Zim Pay Account',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: onSurfaceVariantColor,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Form Area
                            TextFormField(
                              controller: _identifierController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                PhoneNumberFormatter(),
                                LengthLimitingTextInputFormatter(15),
                              ],
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: const Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                hintText: '+1 555 555 5555',
                                labelStyle: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: onSurfaceVariantColor,
                                ),
                                floatingLabelStyle: GoogleFonts.inter(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                filled: true,
                                fillColor: slate50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 20,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: slate200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: primaryColor, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot email?',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Guest mode info
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: onSurfaceVariantColor,
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Not your computer? Use Guest mode to sign in privately. ',
                                  ),
                                  TextSpan(
                                    text: 'Learn more',
                                    style: GoogleFonts.inter(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RegistrationScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    'Create account',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_identifierController.text.length == 15) {
                                      context.read<UserBloc>().add(
                                            LoginEvent(_identifierController.text.replaceAll(' ', '')),
                                          );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter a valid phone number')),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
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
                                        'Next',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Footer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 32, top: 16, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      border: Border(
                        top: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFooterItem(Icons.help_outline, 'Help Center'),
                        _buildFooterItem(Icons.chat_bubble_outline, 'Contact Us'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 24),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ],
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
      return newValue.copyWith(text: '+1 ', selection: const TextSelection.collapsed(offset: 3));
    }

    if (!text.startsWith('+1')) {
      text = '+1 $text';
    }

    if (text.length > 3 && text[2] != ' ') {
      text = '${text.substring(0, 2)} ${text.substring(2)}';
    }

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

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    // Blue
    paint.color = const Color(0xFF4285F4);
    final Path bluePath = Path()
      ..moveTo(size.width * 0.94, size.height * 0.51)
      ..cubicTo(size.width * 0.94, size.height * 0.48, size.width * 0.94, size.height * 0.45, size.width * 0.93, size.height * 0.42)
      ..lineTo(size.width * 0.5, size.height * 0.42)
      ..lineTo(size.width * 0.5, size.height * 0.59)
      ..lineTo(size.width * 0.75, size.height * 0.59)
      ..cubicTo(size.width * 0.74, size.height * 0.65, size.width * 0.7, size.height * 0.7, size.width * 0.65, size.height * 0.73)
      ..lineTo(size.width * 0.65, size.height * 0.85)
      ..lineTo(size.width * 0.8, size.height * 0.85)
      ..cubicTo(size.width * 0.89, size.height * 0.77, size.width * 0.94, size.height * 0.65, size.width * 0.94, size.height * 0.51);
    canvas.drawPath(bluePath, paint);

    // Green
    paint.color = const Color(0xFF34A853);
    final Path greenPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.96)
      ..cubicTo(size.width * 0.62, size.height * 0.96, size.width * 0.73, size.height * 0.92, size.width * 0.8, size.height * 0.85)
      ..lineTo(size.width * 0.65, size.height * 0.73)
      ..cubicTo(size.width * 0.61, size.height * 0.76, size.width * 0.56, size.height * 0.78, size.width * 0.5, size.height * 0.78)
      ..cubicTo(size.width * 0.38, size.height * 0.78, size.width * 0.28, size.height * 0.7, size.width * 0.24, size.height * 0.59)
      ..lineTo(size.width * 0.09, size.height * 0.71)
      ..cubicTo(size.width * 0.17, size.height * 0.86, size.width * 0.32, size.height * 0.96, size.width * 0.5, size.height * 0.96);
    canvas.drawPath(greenPath, paint);

    // Yellow
    paint.color = const Color(0xFFFBBC05);
    final Path yellowPath = Path()
      ..moveTo(size.width * 0.24, size.height * 0.59)
      ..cubicTo(size.width * 0.23, size.height * 0.56, size.width * 0.23, size.height * 0.53, size.width * 0.23, size.height * 0.5)
      ..cubicTo(size.width * 0.23, size.height * 0.47, size.width * 0.23, size.height * 0.44, size.width * 0.24, size.height * 0.41)
      ..lineTo(size.width * 0.09, size.height * 0.29)
      ..cubicTo(size.width * 0.04, size.height * 0.35, size.width * 0.01, size.height * 0.42, size.width * 0.01, size.height * 0.5)
      ..cubicTo(size.width * 0.01, size.height * 0.58, size.width * 0.04, size.height * 0.65, size.width * 0.09, size.height * 0.71)
      ..lineTo(size.width * 0.24, size.height * 0.59);
    canvas.drawPath(yellowPath, paint);

    // Red
    paint.color = const Color(0xFFEA4335);
    final Path redPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.22)
      ..cubicTo(size.width * 0.57, size.height * 0.22, size.width * 0.63, size.height * 0.25, size.width * 0.68, size.height * 0.29)
      ..lineTo(size.width * 0.81, size.height * 0.16)
      ..cubicTo(size.width * 0.73, size.height * 0.09, size.width * 0.62, size.height * 0.04, size.width * 0.5, size.height * 0.04)
      ..cubicTo(size.width * 0.32, size.height * 0.04, size.width * 0.17, size.height * 0.14, size.width * 0.09, size.height * 0.29)
      ..lineTo(size.width * 0.24, size.height * 0.41)
      ..cubicTo(size.width * 0.28, size.height * 0.3, size.width * 0.38, size.height * 0.22, size.width * 0.5, size.height * 0.22);
    canvas.drawPath(redPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
