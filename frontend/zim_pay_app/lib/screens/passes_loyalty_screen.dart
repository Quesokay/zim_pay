import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/wallet/wallet_bloc.dart';
import '../blocs/wallet/wallet_event.dart';
import '../blocs/wallet/wallet_state.dart';
import '../models/wallet_item.dart';
import 'home_screen.dart';
import 'cards_screen.dart';
import 'transaction_history_screen.dart';
import 'settings_screen.dart';
import 'add_to_wallet_screen.dart';
import 'card_details_screen.dart';

class PassesLoyaltyScreen extends StatefulWidget {
  const PassesLoyaltyScreen({super.key});

  @override
  State<PassesLoyaltyScreen> createState() => _PassesLoyaltyScreenState();
}

class _PassesLoyaltyScreenState extends State<PassesLoyaltyScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(LoadWalletItems());
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0058BA);
    const primaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0058BA), Color(0xFF6C9FFF)],
    );
    const surfaceColor = Color(0xFFF4F7FA);
    const onSurfaceColor = Color(0xFF2B2F32);
    const onSurfaceVariantColor = Color(0xFF585C5F);
    const surfaceContainerLowColor = Color(0xFFEEF1F5);
    const surfaceContainerHighColor = Color(0xFFDEE3E8);
    const surfaceContainerLowestColor = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: surfaceColor,
      extendBody: true,
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state.status == WalletStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final loyaltyCards = state.loyaltyCards;
          final transitPasses = state.walletItems.whereType<TransitPass>().toList();

          return Stack(
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
                    centerTitle: false,
                    title: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: primaryColor, size: 30),
                        const SizedBox(width: 12),
                        Text(
                          'Zim Pay',
                          style: GoogleFonts.plusJakartaSans(
                            color: onSurfaceColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    flexibleSpace: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    actions: [
                      BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          String? avatarUrl;
                          if (state is UserCreated) {
                            avatarUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(state.user.name)}&background=random';
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: avatarUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(avatarUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : const DecorationImage(
                                        image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBaPePwODv1RibxUwly-1lZCI2955uEu8Nz_gSWK-i-AK3cJknG8DDJJ6iASMu2_IYcGt4wbsw1NUpFPUNmiPib_WkPOOtJooEMUKnRw3QEh3HOHJEl7PNYyX1t19kpmtc5R-u-JJQoZIbytSSUwrllAUBpBKlfcFN3LlaKeS6UOePXAQwbl_h3-eqCsEQRF2gQGGfhbwNr9UsWwsTLAlr-yaLOW_C92on-4Yzoa_DD1YT6Ft_VZ9gkeipe2-JSdBNvAXEti5hhPEEH'),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: surfaceContainerLowColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: onSurfaceVariantColor),
                              const SizedBox(width: 12),
                              Text(
                                'Search passes and cards',
                                style: GoogleFonts.inter(
                                  color: onSurfaceVariantColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Category Filters
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildFilterChip('All', true, primaryColor, surfaceContainerHighColor),
                              const SizedBox(width: 8),
                              _buildFilterChip('Shopping', false, primaryColor, surfaceContainerHighColor),
                              const SizedBox(width: 8),
                              _buildFilterChip('Travel', false, primaryColor, surfaceContainerHighColor),
                              const SizedBox(width: 8),
                              _buildFilterChip('Events', false, primaryColor, surfaceContainerHighColor),
                              const SizedBox(width: 8),
                              _buildFilterChip('Health', false, primaryColor, surfaceContainerHighColor),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Travel Section
                        if (transitPasses.isNotEmpty) ...[
                          _buildSectionHeader('Upcoming Travel'),
                          const SizedBox(height: 16),
                          ...transitPasses.map((pass) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CardDetailsScreen(item: pass),
                                      ),
                                    );
                                  },
                                  child: _buildTransitPassItem(
                                    pass,
                                    primaryColor: primaryColor,
                                    surfaceContainerLowestColor: surfaceContainerLowestColor,
                                    onSurfaceVariantColor: onSurfaceVariantColor,
                                  ),
                                ),
                              )),
                          const SizedBox(height: 16),
                        ],

                        // Loyalty Section
                        _buildSectionHeader('Loyalty & Rewards'),
                        const SizedBox(height: 16),
                        loyaltyCards.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text('No loyalty cards found', style: GoogleFonts.inter(color: onSurfaceVariantColor)),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 1.5,
                                ),
                                itemCount: loyaltyCards.length,
                                itemBuilder: (context, index) {
                                  final card = loyaltyCards[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CardDetailsScreen(item: card),
                                        ),
                                      );
                                    },
                                    child: _buildLoyaltyCard(
                                      card.title,
                                      card.subtitle,
                                      card.icon,
                                      card.iconColor,
                                      card.iconColor.withValues(alpha: 0.1),
                                      surfaceContainerLowestColor,
                                      onSurfaceVariantColor,
                                    ),
                                  );
                                },
                              ),
                        const SizedBox(height: 32),

                        // Events Section
                        _buildSectionHeader('Upcoming Events'),
                        const SizedBox(height: 16),
                        _buildEventTicket(
                          date: 'Fri, Oct 24',
                          title: 'The Midnight Echo',
                          venue: 'The Grand Arena, London',
                          section: 'A2',
                          row: '14',
                          seat: '102',
                          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDyvJzWDjuSCtZKxTBIFDZEJokV807Pbi7c6eyTn1kS_SvN57O_pXEf4GR2BrqxQZ9-iaFNsrWY2tMKfyb5dIONH1eE1V5wOy0eZ2EPUOnWhw52PlXukyDnHsej1_6H0DRYPSX91Lx01FQKJel-u02SJ3t6879kzIRB850AienMawYYz68m_iqsm479INLjmFXqbIXaMrT1cPiLnBlO_rAX7ILzf0uLtjeWNlXuKbZTVclydbKpZ3_NSCR8PfqR-RrKbcbKe50y6UVX',
                          primaryColor: primaryColor,
                          surfaceColor: surfaceColor,
                          surfaceContainerLowestColor: surfaceContainerLowestColor,
                          onSurfaceVariantColor: onSurfaceVariantColor,
                          surfaceContainerHighColor: surfaceContainerHighColor,
                        ),
                      ]),
                    ),
                  ),
                ],
              ),

              // Floating Action Button
              Positioned(
                bottom: 110,
                right: 24,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddToWalletScreen()),
                    );
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ),
              ),

              // Bottom Navigation Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 24, top: 12, left: 24, right: 24),
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
          );
        },
      ),
    );
  }

  Widget _buildTransitPassItem(
    TransitPass pass, {
    required Color primaryColor,
    required Color surfaceContainerLowestColor,
    required Color onSurfaceVariantColor,
  }) {
    return _buildBoardingPass(
      airline: pass.title,
      flight: 'Transit Pass',
      fromCode: 'BAL',
      fromCity: 'Balance',
      toCode: pass.balance,
      toCity: 'Available',
      duration: 'Unlimited',
      primaryColor: pass.primaryColor,
      surfaceContainerLowestColor: surfaceContainerLowestColor,
      onSurfaceVariantColor: onSurfaceVariantColor,
    );
  }

  Widget _buildFilterChip(String label, bool isActive, Color primaryColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? primaryColor : bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: isActive ? Colors.white : const Color(0xFF2B2F32),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2B2F32),
        ),
      ),
    );
  }

  Widget _buildBoardingPass({
    required String airline,
    required String flight,
    required String fromCode,
    required String fromCity,
    required String toCode,
    required String toCity,
    required String duration,
    required Color primaryColor,
    required Color surfaceContainerLowestColor,
    required Color onSurfaceVariantColor,
  }) {
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
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 8,
            child: Container(color: primaryColor),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.flight_takeoff, color: primaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(airline, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                            Text(flight, style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariantColor)),
                          ],
                        ),
                      ],
                    ),
                    Icon(Icons.more_vert, color: onSurfaceVariantColor),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fromCode, style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold)),
                          Text(fromCity, style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariantColor)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const _DashedLine(),
                              Container(
                                color: surfaceContainerLowestColor,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.flight, color: primaryColor, size: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            duration.toUpperCase(),
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: onSurfaceVariantColor),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(toCode, style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold)),
                          Text(toCity, style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariantColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    Color iconBgColor,
    Color surfaceContainerLowestColor,
    Color onSurfaceVariantColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariantColor), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTicket({
    required String date,
    required String title,
    required String venue,
    required String section,
    required String row,
    required String seat,
    required String imageUrl,
    required Color primaryColor,
    required Color surfaceColor,
    required Color surfaceContainerLowestColor,
    required Color onSurfaceVariantColor,
    required Color surfaceContainerHighColor,
  }) {
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
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imageUrl, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(date.toUpperCase(), style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      Text(title, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Venue', style: GoogleFonts.inter(fontSize: 12, color: onSurfaceVariantColor)),
                        Text(venue, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Icon(Icons.confirmation_number, color: primaryColor),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTicketDetail('Section', section, onSurfaceVariantColor),
                    _buildTicketDetail('Row', row, onSurfaceVariantColor),
                    _buildTicketDetail('Seat', seat, onSurfaceVariantColor),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: surfaceContainerHighColor,
                      foregroundColor: primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('View Ticket', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketDetail(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
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

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFAAADB1)),
              ),
            );
          }),
        );
      },
    );
  }
}
