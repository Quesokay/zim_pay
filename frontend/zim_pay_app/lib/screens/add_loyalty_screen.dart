import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/wallet/wallet_bloc.dart';
import '../blocs/wallet/wallet_event.dart';
import '../blocs/wallet/wallet_state.dart';
import '../blocs/user/user_bloc.dart';
import '../models/create_payment_method_dto.dart';

class AddLoyaltyScreen extends StatefulWidget {
  final String initialTitle;
  final String screenTitle;
  const AddLoyaltyScreen({
    super.key,
    this.initialTitle = '',
    this.screenTitle = 'Add Loyalty Card',
  });

  @override
  State<AddLoyaltyScreen> createState() => _AddLoyaltyScreenState();
}

class _AddLoyaltyScreenState extends State<AddLoyaltyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  final _detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
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
          widget.screenTitle,
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
        listener: (context, state) {
          if (state.status == WalletStatus.success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loyalty card added successfully')),
            );
          } else if (state.status == WalletStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add loyalty card')),
            );
          }
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
                  'Enter details for your rewards or membership card.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: onSurfaceVariantColor,
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  label: 'Program Name',
                  controller: _titleController,
                  placeholder: 'e.g. Starbucks Rewards',
                  prefixIcon: Icons.card_membership,
                  onSurfaceColor: onSurfaceColor,
                  outlineColor: outlineColor,
                  surfaceContainerLowestColor: surfaceContainerLowestColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter program name';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Details/Member ID',
                  controller: _detailsController,
                  placeholder: 'e.g. 123456789',
                  prefixIcon: Icons.tag,
                  onSurfaceColor: onSurfaceColor,
                  outlineColor: outlineColor,
                  surfaceContainerLowestColor: surfaceContainerLowestColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter card details';
                    return null;
                  },
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final userState = context.read<UserBloc>().state;
                        final userId = (userState is UserCreated) ? userState.user.id : 1;

                        context.read<WalletBloc>().add(
                          AddManualCard(
                            userId: userId,
                            cardDetails: CreatePaymentMethodDto(
                              cardNumber: '', // Not used for loyalty
                              expiryDate: '', // Not used for loyalty
                              cvv: '', // Not used for loyalty
                              cardHolderName: _titleController.text,
                            ),
                          ),
                        );
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    required Color onSurfaceColor,
    required Color outlineColor,
    required Color surfaceContainerLowestColor,
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
