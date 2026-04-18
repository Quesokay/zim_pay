import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../models/wallet_item.dart';
import '../models/transaction.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_state.dart';
import 'card_details_expanded_screen.dart';
import 'home_screen.dart';
import 'transaction_history_screen.dart';
import 'cards_screen.dart';
import 'settings_screen.dart';

class CardDetailsScreen extends StatefulWidget {
  final WalletItem item;
  const CardDetailsScreen({super.key, required this.item});

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
    // ignore: unused_local_variable
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
                  widget.item is CreditCard
                      ? 'Card Details'
                      : widget.item is TransitPass
                          ? 'Pass Details'
                          : 'Loyalty Details',
                  style: GoogleFonts.plusJakartaSans(
                    color: onSurfaceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // NFC Contactless Indicator
                    if (widget.item is! LoyaltyCard)
                      BlocBuilder<UserBloc, UserState>(
                        builder: (context, userState) {
                          final bool contactlessEnabled = userState is UserCreated ? userState.user.contactlessEnabled : true;

                          if (!contactlessEnabled) {
                            return Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red.withValues(alpha: 0.1),
                                    ),
                                    child: const Icon(
                                      Icons.not_interested,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'CONTACTLESS DISABLED',
                                    style: GoogleFonts.inter(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Center(
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
                          );
                        },
                      )
                    else
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: BarcodeWidget(
                                barcode: Barcode.code128(),
                                data: (widget.item as LoyaltyCard).id.toString().padLeft(12, '0'),
                                width: 250,
                                height: 100,
                                drawText: true,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: onSurfaceColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'SHOW BARCODE TO SCAN',
                              style: GoogleFonts.inter(
                                color: onSurfaceVariantColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Card Display
                    if (widget.item is CreditCard)
                      _buildCreditCard(widget.item as CreditCard)
                    else if (widget.item is TransitPass)
                      _buildTransitPass(widget.item as TransitPass)
                    else if (widget.item is LoyaltyCard)
                      _buildLoyaltyCardDisplay(widget.item as LoyaltyCard),
                    
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
                                MaterialPageRoute(builder: (context) => CardDetailsExpandedScreen(item: widget.item)),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SettingsScreen()),
                              );
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
                              MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
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

                    BlocBuilder<TransactionBloc, TransactionState>(
                      builder: (context, txState) {
                        final cardTransactions = txState.transactions.where((tx) {
                          if (widget.item is CreditCard) {
                            return tx.paymentMethodId == (widget.item as CreditCard).id.toString();
                          }
                          // Add logic for TransitPass or LoyaltyCard if they have associated transactions
                          return false;
                        }).toList();

                        if (cardTransactions.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: surfaceContainerLowestColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.history, color: onSurfaceVariantColor.withValues(alpha: 0.2), size: 48),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No recent activity for this card',
                                    style: GoogleFonts.inter(color: onSurfaceVariantColor),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Container(
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
                            children: cardTransactions.take(5).map((tx) {
                              return _buildTransactionItem(
                                tx.icon,
                                tx.title,
                                tx.formattedDate,
                                tx.formattedAmount,
                                tx.status.name,
                                tx.bgColor,
                                onSurfaceColor,
                                onSurfaceVariantColor,
                                tx.status == TransactionStatus.completed ? secondaryColor : Colors.orange,
                                isAlternate: cardTransactions.indexOf(tx) % 2 != 0,
                              );
                            }).toList(),
                          ),
                        );
                      },
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
                                  'Your details are replaced with a unique digital identifier, so your actual data is never shared. Zim Pay keeps you safe.',
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

  Widget _buildCreditCard(CreditCard card) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              card.primaryColor,
              card.secondaryColor,
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
                        card.bankName,
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
                      card.cardNumber,
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
                const Spacer(),
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

  Widget _buildTransitPass(TransitPass pass) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              pass.primaryColor,
              pass.secondaryColor,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TRANSIT PASS',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Icon(Icons.train, color: Colors.white, size: 28),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pass.title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Balance: ${pass.balance}',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.contactless, color: Colors.white, size: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyCardDisplay(LoyaltyCard card) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              card.iconColor,
              card.iconColor.withValues(alpha: 0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LOYALTY CARD',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Icon(card.icon, color: Colors.white, size: 28),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.subtitle,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.qr_code_2, color: Colors.white, size: 32),
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
      borderRadius: BorderRadius.circular(12),
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
