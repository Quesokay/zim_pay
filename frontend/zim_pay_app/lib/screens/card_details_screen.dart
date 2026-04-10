import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'card_details_expanded_screen.dart';
import 'transactions_screen.dart';
import 'home_screen.dart';
import 'transaction_history_screen.dart';
import 'cards_screen.dart';
import 'settings_screen.dart';

class CardDetailsScreen extends StatefulWidget {
  const CardDetailsScreen({super.key});

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _nfcController;

  @override
  void initState() {
    super.initState();
    _nfcController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _nfcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0058BA);
    const surfaceColor = Color(0xFFF4F7FA);
    const onSurfaceColor = Color(0xFF2B2F32);
    const onSurfaceVariantColor = Color(0xFF585C5F);
    const surfaceContainerLowColor = Color(0xFFEEF1F5);
    const surfaceContainerHighColor = Color(0xFFDEE3E8);
    const surfaceContainerHighestColor = Color(0xFFD8DDE2);
    const surfaceContainerLowestColor = Color(0xFFFFFFFF);
    const secondaryColor = Color(0xFF006A2B);

    return Scaffold(
      backgroundColor: surfaceColor,
      extendBody: true,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top App Bar
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: Colors.white.withValues(alpha: 0.6),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: onSurfaceColor),
                ),
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                title: Text(
                  'Card Details',
                  style: GoogleFonts.plusJakartaSans(
                    color: onSurfaceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBlWht8DGoSIVyoaKPjQ5VRMHzgXZ5LzFe3HJWy82gqk5_T9Jr2OhZINSUdVOmiVwf5vvEZJbCZYbrp68P9bzD-IU9V0SkLq4yt4r5jQCzTUxVYZrnuyDhPRqf30A56ggjsfNtDnjkw99Y5rQ5XOtxofNAbzFbz0LPBBzhCStG_Q8G0zUXq9SghHZ5iFXaD37ci0IR7IrQhYEDacxtCGcL_rvH9kFUDk3QDOrO-iGiy9OLt7QC0Eihz_6wAEc_2SF5M-doWx7iXtoFV'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // NFC Contactless Indicator
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ScaleTransition(
                                scale: Tween(begin: 1.0, end: 1.5).animate(
                                  CurvedAnimation(parent: _nfcController, curve: Curves.easeOut),
                                ),
                                child: FadeTransition(
                                  opacity: Tween(begin: 0.5, end: 0.0).animate(
                                    CurvedAnimation(parent: _nfcController, curve: Curves.easeOut),
                                  ),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primaryColor.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: surfaceContainerLowColor,
                                ),
                                child: const Icon(
                                  Icons.contactless,
                                  color: primaryColor,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'HOLD TO READER',
                            style: GoogleFonts.inter(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Premium Visa Card
                    _buildInfiniteObsidianCard(),
                    const SizedBox(height: 32),

                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            Icons.info_outline,
                            'Details',
                            surfaceContainerHighColor,
                            primaryColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CardDetailsExpandedScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            Icons.settings_outlined,
                            'Settings',
                            surfaceContainerHighColor,
                            primaryColor,
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => const SettingsScreen()),
                              // );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Recent Activity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: onSurfaceColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TransactionsScreen()),
                            );
                          },
                          child: Text(
                            'View all',
                            style: GoogleFonts.inter(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: surfaceContainerLowestColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          _buildTransactionItem(
                            Icons.shopping_bag_outlined,
                            'Apple Store',
                            'Oct 24 • 2:14 PM',
                            '-\$1,299.00',
                            'Completed',
                            surfaceContainerHighestColor,
                            onSurfaceColor,
                            onSurfaceVariantColor,
                            secondaryColor,
                          ),
                          _buildTransactionItem(
                            Icons.local_cafe_outlined,
                            'Blue Bottle Coffee',
                            'Oct 23 • 8:45 AM',
                            '-\$6.50',
                            'Completed',
                            surfaceContainerHighestColor,
                            onSurfaceColor,
                            onSurfaceVariantColor,
                            secondaryColor,
                            isAlternate: true,
                          ),
                          _buildTransactionItem(
                            Icons.train_outlined,
                            'MTA Transit',
                            'Oct 22 • 5:30 PM',
                            '-\$2.90',
                            'Completed',
                            surfaceContainerHighestColor,
                            onSurfaceColor,
                            onSurfaceVariantColor,
                            secondaryColor,
                          ),
                          _buildTransactionItem(
                            Icons.restaurant_outlined,
                            'Sweet-green',
                            'Oct 22 • 12:15 PM',
                            '-\$18.42',
                            'Completed',
                            surfaceContainerHighestColor,
                            onSurfaceColor,
                            onSurfaceVariantColor,
                            secondaryColor,
                            isAlternate: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Security Message
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceContainerLowColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.verified_user, color: primaryColor),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Encrypted & Secure',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: onSurfaceColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your card number is replaced with a unique digital identifier, so your actual details are never shared with merchants.',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: onSurfaceVariantColor,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),

          // Bottom Nav Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 24, top: 12, left: 32, right: 32),
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.6),
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
                      _buildNavItem(context, Icons.credit_card, 'Cards', true, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CardsScreen()),
                        );
                      }),
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
      ),
    );
  }

  Widget _buildInfiniteObsidianCard() {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Colors.black,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PREFERRED REWARDS',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        'Infinite Obsidian',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.nfc, color: Colors.white70, size: 32),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '•••• •••• •••• 8842',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CARD HOLDER',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'ALEXANDER R. VANCE',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'VISA',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color bgColor, Color textColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    IconData icon,
    String title,
    String date,
    String amount,
    String status,
    Color iconBgColor,
    Color titleColor,
    Color subtitleColor,
    Color statusColor, {
    bool isAlternate = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: isAlternate ? const Color(0xFFEEF1F5).withValues(alpha: 0.3) : null,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: subtitleColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    color: subtitleColor,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  fontSize: 16,
                ),
              ),
              Text(
                status.toUpperCase(),
                style: GoogleFonts.inter(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
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
