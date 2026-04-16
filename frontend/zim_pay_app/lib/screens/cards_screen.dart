import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/wallet/wallet_bloc.dart';
import '../blocs/wallet/wallet_event.dart';
import '../blocs/wallet/wallet_state.dart';
import '../blocs/user/user_bloc.dart';
import '../models/wallet_item.dart';
import 'transaction_history_screen.dart';
import 'settings_screen.dart';
import 'home_screen.dart';
import 'add_to_wallet_screen.dart';
import 'card_details_screen.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  @override
  void initState() {
    super.initState();
    final userState = context.read<UserBloc>().state;
    if (userState is UserCreated) {
      final userId = userState.user.id;
      context.read<WalletBloc>().add(LoadWalletItems(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0058BA);
    const secondaryColor = Color(0xFF006A2B);
    const backgroundColor = Color(0xFFF4F7FA);
    const onSurfaceColor = Color(0xFF2B2F32);
    const outlineColor = Color(0xFF73777A);
    const surfaceContainerLowColor = Color(0xFFEEF1F5);
    const surfaceContainerLowestColor = Color(0xFFFFFFFF);
    const surfaceContainerHighColor = Color(0xFFDEE3E8);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state.status == WalletStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == WalletStatus.failure) {
            return const Center(child: Text('Failed to load wallet items'));
          }

          return BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              final bool contactlessEnabled = userState is UserCreated ? userState.user.contactlessEnabled : true;

              return Stack(
                children: [
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Top App Bar
                      SliverAppBar(
                        floating: true,
                        pinned: true,
                        backgroundColor: backgroundColor.withValues(alpha: 0.6),
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.close, color: onSurfaceColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                        title: Text(
                          'Zim Pay',
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
                        actions: [
                          BlocBuilder<UserBloc, UserState>(
                            builder: (context, userState) {
                              String name = 'Guest';
                              if (userState is UserCreated) {
                                name = userState.user.name;
                              }
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                    );
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Hero Section
                            Column(
                              children: [
                                Text(
                                  'Pay with',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: outlineColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Select a card',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: onSurfaceColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (contactlessEnabled)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: surfaceContainerLowColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.contactless, color: secondaryColor, size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Ready to tap',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: onSurfaceColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.not_interested, color: Colors.red, size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Contactless disabled',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: onSurfaceColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                        const SizedBox(height: 40),

                        // Cards List
                        ...state.walletItems.map((item) {
                          if (item is CreditCard) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CardDetailsScreen(item: item),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: _buildPaymentCard(
                                  title: item.bankName,
                                  subtitle: '•••• ${item.cardNumber.substring(item.cardNumber.length - 4)}',
                                  brand: item.bankName.contains('VISA') ? 'VISA' : 'Mastercard',
                                  brandColors: [item.primaryColor, item.secondaryColor],
                                  isDefault: item.isDefault,
                                  isSelected: item.isDefault,
                                  primaryColor: primaryColor,
                                  surfaceContainerLowestColor: surfaceContainerLowestColor,
                                ),
                              ),
                            );
                          } else if (item is TransitPass) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CardDetailsScreen(item: item),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: _buildGenericCard(
                                  title: item.title,
                                  subtitle: 'Balance: \$${item.balance.toStringAsFixed(2)}',
                                  icon: Icons.train,
                                  iconColor: Colors.white,
                                  bgColor: item.primaryColor.withValues(alpha: 0.1),
                                  accentColor: item.primaryColor,
                                  label: 'Transit',
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),

                        const SizedBox(height: 48),

                        // Add Card Button
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddToWalletScreen()),
                              );
                            },
                            icon: const Icon(Icons.add_card),
                            label: const Text('Add a new card'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: surfaceContainerHighColor,
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 120),
                      ]),
                    ),
                  ),
                ],
              ),

              // Bottom Navigation Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 24, top: 12, left: 16, right: 16),
                  decoration: BoxDecoration(
                    color: backgroundColor.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2B2F32).withValues(alpha: 0.08),
                        blurRadius: 32,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(context, Icons.wallet, 'Wallet', false, onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                              (route) => false,
                            );
                          }),
                          _buildNavItem(context, Icons.history, 'History', false, onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
                            );
                          }),
                          _buildNavItem(context, Icons.credit_card, 'Cards', true),
                          _buildNavItem(context, Icons.settings, 'Settings', false, onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPaymentCard({
    required String title,
    required String subtitle,
    required String brand,
    required List<Color> brandColors,
    required bool isDefault,
    required bool isSelected,
    required Color primaryColor,
    required Color surfaceContainerLowestColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainerLowestColor,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: primaryColor, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: brandColors,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    brand,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      fontStyle: brand == 'Mastercard' ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              else
                const Text(
                  'Select',
                  style: TextStyle(color: Color(0xFF73777A), fontSize: 10, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2B2F32),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF73777A),
                        letterSpacing: 2.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? primaryColor : const Color(0xFFAAADB1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenericCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color accentColor,
    required String label,
    IconData? trailingIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column( crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Text(
                label,
                style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: accentColor.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                trailingIcon ?? Icons.arrow_forward_ios,
                color: accentColor.withValues(alpha: 0.8),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: isActive
              ? BoxDecoration(
                  color: const Color(0xFFD3E3FD),
                  borderRadius: BorderRadius.circular(30),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFF041E49) : const Color(0xFF44474E),
                size: 24,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isActive ? const Color(0xFF041E49) : const Color(0xFF44474E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
