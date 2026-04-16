import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/wallet/wallet_bloc.dart';
import '../blocs/wallet/wallet_event.dart';
import '../blocs/wallet/wallet_state.dart';
import '../models/create_pass_dto.dart';

import 'package:flutter/services.dart';

class AddTransitPassScreen extends StatefulWidget {
  const AddTransitPassScreen({super.key});

  @override
  State<AddTransitPassScreen> createState() => _AddTransitPassScreenState();
}

class _AddTransitPassScreenState extends State<AddTransitPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _balanceController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006A2B); // Transit green
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
          'Add Transit Pass',
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transit pass added successfully')),
            );
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (state.status == WalletStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add transit pass')),
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
                  'Pass Information',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter details for your bus or train pass.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: onSurfaceVariantColor,
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  label: 'Pass Name',
                  controller: _titleController,
                  placeholder: 'e.g. London Underground',
                  prefixIcon: Icons.directions_subway,
                  onSurfaceColor: onSurfaceColor,
                  outlineColor: outlineColor,
                  surfaceContainerLowestColor: surfaceContainerLowestColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter pass name';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Initial Balance',
                  controller: _balanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  placeholder: '0.00',
                  prefixIcon: Icons.attach_money,
                  onSurfaceColor: onSurfaceColor,
                  outlineColor: outlineColor,
                  surfaceContainerLowestColor: surfaceContainerLowestColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter balance';
                    if (double.tryParse(value) == null) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final passDto = CreatePassDto(
                          type: "TransitPass",
                          title: _titleController.text,
                          details: "Transit Pass",
                          issuerId: "ZimPay",
                          issuerName: "ZimPay Transit",
                          passNumber: DateTime.now().millisecondsSinceEpoch.toString(),
                          barcode: "TR-${DateTime.now().millisecondsSinceEpoch}",
                          balance: double.tryParse(_balanceController.text) ?? 0.0,
                          color: "#006A2B",
                        );

                        final userState = context.read<UserBloc>().state;
                        if (userState is UserCreated) {
                          final userId = userState.user.id;

                          context.read<WalletBloc>().add(
                            AddPass(
                              userId: userId,
                              passDetails: passDto,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please log in first')),
                          );
                        }
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
                          'Save Pass',
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
    List<TextInputFormatter>? inputFormatters,
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
              borderSide: const BorderSide(color: Color(0xFF006A2B), width: 2),
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
