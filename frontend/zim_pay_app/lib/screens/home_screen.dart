import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import '../services/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../blocs/wallet/wallet_bloc.dart';
import '../blocs/wallet/wallet_event.dart';
import '../blocs/wallet/wallet_state.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../blocs/transaction/transaction_state.dart';
import '../blocs/user/user_bloc.dart';
import '../models/wallet_item.dart';
import 'add_to_wallet_screen.dart';
import 'card_details_screen.dart';
import 'passes_loyalty_screen.dart';
import 'transaction_history_screen.dart';
import 'settings_screen.dart';
import 'cards_screen.dart';
import 'merchant_pos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Use a large initial page to allow "infinite" swiping in both directions
    _pageController = PageController(viewportFraction: 0.9, initialPage: 5000);
    _pageController.addListener(_onPageChange);

    // Load initial wallet and transactions
    _initialLoad();
  }

  void _onPageChange() {
    if (_pageController.hasClients && _pageController.page != null) {
      final walletState = context.read<WalletBloc>().state;
      if (walletState.walletItems.isNotEmpty) {
        int realCount = walletState.walletItems.length;
        int next = _pageController.page!.round();
        int actualIndex = next % realCount;

        if (_currentPage != actualIndex) {
          setState(() {
            _currentPage = actualIndex;
          });

          // Set default payment method without blocking UI or causing unnecessary rebuilds
          scheduleMicrotask(() => _updateDefaultPaymentMethod(actualIndex));
        }
      }
    }
  }

  void _updateDefaultPaymentMethod(int index) {
    final walletState = context.read<WalletBloc>().state;
    if (walletState.walletItems.isNotEmpty && index < walletState.walletItems.length) {
      final item = walletState.walletItems[index];
      final userState = context.read<UserBloc>().state;
      if (userState is UserCreated) {
        context.read<WalletBloc>().add(SetDefaultPaymentMethod(
          userId: userState.user.id,
          paymentMethodId: item.id,
        ));
      }
    }
  }

  void _initialLoad() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserCreated) {
      final userId = userState.user.id;
      context.read<WalletBloc>().add(LoadWalletItems(userId: userId));
      context.read<TransactionBloc>().add(LoadTransactions(userId: userId));
      _loadPendingTransactions();
    }
  }

  void _loadPendingTransactions() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserCreated) {
      final userId = userState.user.id;
      context.read<TransactionBloc>().add(LoadPendingTransactions(userId: userId));
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChange);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0058BA);
    const surfaceColor = Color(0xFFF4F7FA);
    const onSurfaceColor = Color(0xFF2B2F32);
    const onSurfaceVariantColor = Color(0xFF585C5F);
    const surfaceContainerLowestColor = Color(0xFFFFFFFF);
    const surfaceContainerLowColor = Color(0xFFEEF1F5);
    const surfaceContainerHighestColor = Color(0xFFD8DDE2);

    return Scaffold(
      backgroundColor: surfaceColor,
      extendBody: true,
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state.status == WalletStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == WalletStatus.failure) {
            return const Center(child: Text('Failed to load wallet items'));
          }

          return Stack(
            children: [
              // Main Scrollable Content
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // TopAppBar
                  SliverAppBar(
                    floating: true,
                    pinned: false,
                    backgroundColor: Colors.white.withValues(alpha: 0.6),
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    title: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Zim Pay',
                          style: GoogleFonts.plusJakartaSans(
                            color: onSurfaceColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MerchantPosScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.point_of_sale, color: Colors.redAccent, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'POS Test',
                                  style: GoogleFonts.inter(
                                    color: Colors.redAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: surfaceContainerHighestColor, width: 2),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ✨ FLOATING PENDING TRANSACTION ALERT ✨
                        BlocBuilder<TransactionBloc, TransactionState>(
                          builder: (context, txState) {
                            if (txState.pendingTransactions.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: txState.pendingTransactions.map((tx) {
                                return _buildPendingTransactionCard(
                                  int.parse(tx.id),
                                  tx.amount,
                                  tx.title,
                                );
                              }).toList(),
                            );
                          },
                        ),

                        // Hero Carousel Section
                        if (state.walletItems.isNotEmpty)
                          SizedBox(
                            height: 220,
                            child: PageView.builder(
                              controller: _pageController,
                              physics: const BouncingScrollPhysics(),
                              allowImplicitScrolling: true,
                              itemBuilder: (context, index) {
                                final actualIndex = index % state.walletItems.length;
                                final item = state.walletItems[actualIndex];
                                return AnimatedBuilder(
                                  animation: _pageController,
                                  builder: (context, child) {
                                    double value = 1.0;
                                    if (_pageController.position.haveDimensions) {
                                      value = _pageController.page! - index;
                                      value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                                    } else {
                                      value = index == 5000 ? 1.0 : 0.9;
                                    }
                                    return Transform.scale(
                                      scale: value,
                                      child: Opacity(
                                        opacity: value,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: RepaintBoundary(
                                      child: _buildWalletItemCard(context, item),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (state.walletItems.isNotEmpty) const SizedBox(height: 12),

                        // Carousel Pagination
                        if (state.walletItems.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(state.walletItems.length, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _currentPage == index ? 24 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _currentPage == index ? primaryColor : surfaceContainerHighestColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        const SizedBox(height: 32),

                        // Add to Wallet Button
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AddToWalletScreen()),
                                  );
                                },
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text('Add to Wallet'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Loyalty & Passes Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Loyalty & Passes',
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
                                    MaterialPageRoute(builder: (context) => const PassesLoyaltyScreen()),
                                  );
                                },
                                child: Text(
                                  'View All',
                                  style: GoogleFonts.inter(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Loyalty Items
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: state.loyaltyCards.map((card) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildLoyaltyItemFromModel(
                                  card,
                                  onSurfaceColor: onSurfaceColor,
                                  onSurfaceVariantColor: onSurfaceVariantColor,
                                  surfaceContainerLowestColor: surfaceContainerLowestColor,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Security Info Note
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: surfaceContainerLowColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.verified_user, color: primaryColor),
                                const SizedBox(height: 12),
                                Text(
                                  'Your payment info is securely encrypted. Zim Pay does not share your actual card numbers with businesses.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: onSurfaceVariantColor,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 120), // Bottom nav space
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
                          _buildNavItem(context, Icons.wallet, 'Wallet', true, onTap: () {}),
                          _buildNavItem(context, Icons.history, 'History', false, onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
                            );
                          }),
                          _buildNavItem(context, Icons.credit_card, 'Cards', false, onTap: () {
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

              // Removing floating notification since it is now in the list
            ],
          );
        },
      ),
    );
  }

  Widget _buildPendingTransactionCard(int transactionId, double amount, String merchantName) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5), // Soft warning orange
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB020).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB020).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fingerprint, color: Color(0xFFB27B16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Approval Required',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF8A5A00)),
                ),
                Text(
                  '\$${amount.toStringAsFixed(2)} at $merchantName',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF8A5A00)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _executeFingerprintApproval(transactionId, amount),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB020),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeFingerprintApproval(int transactionId, double amount) async {
    // 1. Trigger the native Fingerprint / FaceID scanner
    bool isAuthorized = await BiometricService.authenticate(
      context,
      'Authorize payment of \$${amount.toStringAsFixed(2)}',
    );

    if (!mounted) return;

    if (isAuthorized) {
      // 2. The user successfully scanned their fingerprint! 
      // Now we tell the C# backend to release the funds.
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      try {
        final url = Uri.parse('${ApiConstants.baseUrl}/Transaction/$transactionId/approve');
        final response = await http.post(url);

        if (!mounted) return;
        Navigator.pop(context); // Remove loading spinner

        if (response.statusCode == 200) {
          // Success!
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Payment Approved Successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh state
          int userId = 1;
          final userState = context.read<UserBloc>().state;
          if (userState is UserCreated) {
            userId = userState.user.id;
          }
          context.read<TransactionBloc>().add(LoadPendingTransactions(userId: userId));
          context.read<TransactionBloc>().add(LoadTransactions(userId: userId));
          context.read<WalletBloc>().add(LoadWalletItems(userId: userId));

        } else { // Handled backend error (e.g., Insufficient funds)
          final error = jsonDecode(response.body)['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Decline: $error'), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Try again.')),
        );
      }
    } else {
      // 3. User cancelled the fingerprint prompt or it failed
      debugPrint('Fingerprint cancelled by user.');
    }
  }

  Widget _buildWalletItemCard(BuildContext context, WalletItem item) {
    if (item is CreditCard) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CardDetailsScreen(item: item)),
          );
        },
        child: _buildCreditCard(
          item.primaryColor,
          item.secondaryColor,
          item.bankName,
          item.cardNumber,
          item.expiryDate,
          item.balance,
        ),
      );
    } else if (item is TransitPass) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CardDetailsScreen(item: item)),
          );
        },
        child: _buildTransitPass(
          item.primaryColor,
          item.secondaryColor,
          item.title,
          '\$${item.balance.toStringAsFixed(2)}',
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoyaltyItemFromModel(
      LoyaltyCard card, {
        required Color onSurfaceColor,
        required Color onSurfaceVariantColor,
        required Color surfaceContainerLowestColor,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CardDetailsScreen(item: card)),
        );
      },
      child: _buildLoyaltyItem(
        icon: card.icon,
        iconColor: card.iconColor,
        bgColor: card.bgColor,
        title: card.title,
        subtitle: card.subtitle,
        onSurfaceColor: onSurfaceColor,
        onSurfaceVariantColor: onSurfaceVariantColor,
        surfaceContainerLowestColor: surfaceContainerLowestColor,
      ),
    );
  }

  Widget _buildCreditCard(
      Color color1,
      Color color2,
      String bank,
      String number,
      String expiry,
      double balance,
      ) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color1.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.contactless, color: Colors.white, size: 32),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VALID THRU',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        expiry,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransitPass(Color color1, Color color2, String title, String balance) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color1.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_subway, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                balance,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Remaining Balance',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required Color onSurfaceColor,
    required Color onSurfaceVariantColor,
    required Color surfaceContainerLowestColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceContainerLowestColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: onSurfaceColor,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: onSurfaceVariantColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: onSurfaceVariantColor.withValues(alpha: 0.5)),
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