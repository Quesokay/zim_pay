import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/wallet/wallet_bloc.dart';
import '../blocs/wallet/wallet_event.dart';
import '../blocs/wallet/wallet_state.dart';
import '../models/create_payment_method_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zim_pay_app/screens/link_tag_screen.dart';

class ManualEntryScreen extends StatefulWidget {
  // ADDED: Accept initial data from the Card Scanner
  final Map<String, String>? initialData;

  const ManualEntryScreen({super.key, this.initialData});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _holderController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // ADDED: Pre-fill the form if data was passed from the scanner
    if (widget.initialData != null) {
      String rawCard = widget.initialData!['cardNumber'] ?? '';

      // Programmatically format the scanned 16 digits to include spaces
      String formattedCard = '';
      for (int i = 0; i < rawCard.length; i++) {
        formattedCard += rawCard[i];
        if ((i + 1) % 4 == 0 && i != rawCard.length - 1) {
          formattedCard += ' ';
        }
      }

      _cardNumberController.text = formattedCard;
      _expiryController.text = widget.initialData!['expiryDate'] ?? '';
    }
  }

  void _handleSuccessfulVerification(CreatePaymentMethodDto cardDto) {
    if (mounted) {
      // Close the OTP Dialog
      Navigator.of(context, rootNavigator: true).pop();

      debugPrint('🚀 [UI] Dispatching AddManualCard event to WalletBloc...');
      _saveCardToBackend(cardDto);
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0058BA);
    const backgroundColor = Color(0xFFF4F7FA);
    const onSurfaceColor = Color(0xFF2B2F32);
    const onSurfaceVariantColor = Color(0xFF585C5F);
    const outlineColor = Color(0xFF73777A);
    const surfaceContainerLowestColor = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor.withValues(alpha: 0.6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: onSurfaceColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Enter details manually',
          style: GoogleFonts.plusJakartaSans(
            color: onSurfaceColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: BlocListener<WalletBloc, WalletState>(
        listenWhen: (previous, current) => previous.status == WalletStatus.loading && current.status == WalletStatus.success,
        listener: (context, state) {
          Navigator.pop(context);
          if (state.status == WalletStatus.success) {
            // 1. Close the manual entry screen
            Navigator.pop(context);

            // 2. Navigate to the NFC Writer screen with a test token
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LinkTagScreen(
                  digitalToken: "TEST_SECURE_TOKEN_12345", // We will use the real .NET token later!
                ),
              ),
            );
          } else if (state.status == WalletStatus.failure) {
            // Show error snackbar
          }
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Card added successfully'),
          //     backgroundColor: Colors.green,
          //   ),
          // );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card Information',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your payment card details securely.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: onSurfaceVariantColor,
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  label: 'Card Number',
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.credit_card,
                  placeholder: '0000 0000 0000 0000',
                  onSurfaceColor: onSurfaceColor,
                  outlineColor: outlineColor,
                  surfaceContainerLowestColor: surfaceContainerLowestColor,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    CardNumberFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter card number';
                    if (value.replaceAll(' ', '').length < 16) return 'Enter a valid 16-digit card number';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Expiry Date',
                        controller: _expiryController,
                        keyboardType: TextInputType.number,
                        placeholder: 'MM/YY',
                        onSurfaceColor: onSurfaceColor,
                        outlineColor: outlineColor,
                        surfaceContainerLowestColor: surfaceContainerLowestColor,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          CardExpiryFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (value.length < 5) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'CVV',
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        placeholder: '123',
                        obscureText: true,
                        onSurfaceColor: onSurfaceColor,
                        outlineColor: outlineColor,
                        surfaceContainerLowestColor: surfaceContainerLowestColor,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (value.length < 3) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Cardholder Name',
                  controller: _holderController,
                  placeholder: 'John Doe',
                  onSurfaceColor: onSurfaceColor,
                  outlineColor: outlineColor,
                  surfaceContainerLowestColor: surfaceContainerLowestColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter holder name';
                    return null;
                  },
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // 1. Create the DTO
                        final cardDto = CreatePaymentMethodDto(
                          cardNumber: _cardNumberController.text.replaceAll(' ', ''),
                          expiryDate: _expiryController.text,
                          cvv: _cvvController.text,
                          cardHolderName: _holderController.text,
                        );

                        // 2. Trigger SMS Verification instead of saving directly!
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contacting bank for verification...')),
                        );
                        _startPhoneVerification(cardDto);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: BlocBuilder<WalletBloc, WalletState>(
                      builder: (context, state) {
                        if (state.status == WalletStatus.loading) {
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
                          'Save Card',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
    );
  }

  // 1. The Phone Auth Flow
  Future<void> _startPhoneVerification(CreatePaymentMethodDto cardDto) async {
    // For a capstone, you can hardcode a test number here, or pass in the logged-in user's actual phone number.
    const testPhoneNumber = '+15555555555';
    await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: testPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolution (usually only works on Android)
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (mounted) {
          _saveCardToBackend(cardDto);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification Failed: ${e.message}')),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        // SMS was sent! Show the dialog to type the code.
        if (mounted) {
          _showOTPDialog(verificationId, cardDto);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // 2. The Pop-Up Dialog for the 6-digit code
  void _showOTPDialog(String verificationId, CreatePaymentMethodDto cardDto) {
    final otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Enter Bank OTP', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('We sent a 6-digit code to your registered phone number to verify this card.', style: GoogleFonts.inter()),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: '123456',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                debugPrint('🔥 [UI] Verifying OTP code with Firebase...');

                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: verificationId,
                  smsCode: otpController.text,
                );

                // 1. Attempt the sign in
                await FirebaseAuth.instance.signInWithCredential(credential);

                debugPrint('✅ [UI] Firebase verification SUCCESS!');
                _handleSuccessfulVerification(cardDto);

              } catch (e) {
                // 2. CHECK FOR THE PIGEON BUG:
                // If it's a type cast error but current user is NOT null, it actually worked!
                if (e.toString().contains('PigeonUserDetails') &&
                    FirebaseAuth.instance.currentUser != null) {

                  debugPrint('⚠️ [UI] Caught Pigeon type-cast bug, but User exists. Proceeding...');
                  _handleSuccessfulVerification(cardDto);

                } else {
                  debugPrint('❌ [UI] Firebase verification FAILED: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid Code. Please try again.')),
                  );
                }
              }
            },
            child: const Text('Verify & Save'),
          ),
        ],
      ),
    );
  }

  // 3. The actual save function (extracted from your old button logic)
  void _saveCardToBackend(CreatePaymentMethodDto cardDto) {
    context.read<WalletBloc>().add(
        AddManualCard(userId: 1, cardDetails: cardDto)
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    bool obscureText = false,
    required Color onSurfaceColor,
    required Color outlineColor,
    required Color surfaceContainerLowestColor,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          style: GoogleFonts.inter(color: onSurfaceColor),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: GoogleFonts.inter(color: outlineColor.withValues(alpha: 0.5)),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: outlineColor) : null,
            filled: true,
            fillColor: surfaceContainerLowestColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: outlineColor.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: outlineColor.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0058BA), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;
    String enteredData = newValue.text.replaceAll(' ', '');
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < enteredData.length; i++) {
      buffer.write(enteredData[i]);
      int index = i + 1;
      if (index % 4 == 0 && enteredData.length != index) {
        buffer.write(' ');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}

class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;

    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}