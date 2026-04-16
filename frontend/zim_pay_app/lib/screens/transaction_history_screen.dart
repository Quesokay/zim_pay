// ignore_for_file: unused_local_variable

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../blocs/transaction/transaction_state.dart';
import '../models/transaction.dart';
import 'home_screen.dart';
import 'cards_screen.dart';
import 'settings_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final userState = context.read<UserBloc>().state;
    if (userState is UserCreated) {
      final userId = userState.user.id;
      context.read<TransactionBloc>().add(LoadTransactions(userId: userId));
      context.read<TransactionBloc>().add(LoadPendingTransactions(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0058BA);
    const primaryContainerColor = Color(0xFFD3E3FD);
    const secondaryColor = Color(0xFF006A2B);
    const backgroundColor = Color(0xFFF4F7FA);
    const onSurfaceColor = Color(0xFF2B2F32);
    const onSurfaceVariantColor = Color(0xFF585C5F);
    const outlineColor = Color(0xFF73777A);
    const surfaceContainerLowestColor = Color(0xFFFFFFFF);
    const surfaceContainerLowColor = Color(0xFFEEF1F5);
    const surfaceContainerHighColor = Color(0xFFDEE3E8);
    const errorColor = Color(0xFFB31B25);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state.status == TransactionStatus_State.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TransactionStatus_State.failure) {
            return const Center(child: Text('Failed to load transactions'));
          }

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Top Bar
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    backgroundColor: backgroundColor.withValues(alpha: 0.6),
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: false,
                    title: Row(
                      children: [
                        BlocBuilder<UserBloc, UserState>(
                          builder: (context, userState) {
                            String name = 'Guest';
                            if (userState is UserCreated) {
                              name = userState.user.name;
                            }
                            return GestureDetector(
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
                                  image: DecorationImage(
                                    image: NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Zim Pay',
                          style: GoogleFonts.plusJakartaSans(
                            color: onSurfaceColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF44474E)),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Search Bar
                        Container(
                          height: 56,
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
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search transactions',
                              hintStyle: GoogleFonts.inter(color: outlineColor),
                              prefixIcon: const Icon(Icons.search, color: outlineColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildFilterChip('All', true, primaryColor, primaryContainerColor, onSurfaceColor, surfaceContainerLowColor),
                              const SizedBox(width: 8),
                              _buildFilterChip('Spending', false, primaryColor, primaryContainerColor, onSurfaceVariantColor, surfaceContainerLowColor),
                              const SizedBox(width: 8),
                              _buildFilterChip('Rewards', false, primaryColor, primaryContainerColor, onSurfaceVariantColor, surfaceContainerLowColor),
                              const SizedBox(width: 8),
                              _buildFilterChip('Cards', false, primaryColor, primaryContainerColor, onSurfaceVariantColor, surfaceContainerLowColor),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Transaction List Grouped by Month (Simulated grouping)
                        _buildSectionHeader('NOVEMBER 2023', outlineColor),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: surfaceContainerLowestColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              ...state.pendingTransactions,
                              ...state.transactions,
                            ].map((tx) {
                              return _buildTransactionItemFromModel(
                                tx,
                                onSurfaceColor: onSurfaceColor,
                                onSurfaceVariantColor: onSurfaceVariantColor,
                                secondaryColor: secondaryColor,
                                errorColor: errorColor,
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Summary Card
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              // Decorative elements
                              Positioned(
                                top: -48,
                                right: -48,
                                child: Container(
                                  width: 192,
                                  height: 192,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -32,
                                left: -32,
                                child: Container(
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF004DA4).withValues(alpha: 0.4),
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total Spent this month',
                                      style: GoogleFonts.inter(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      r'$1,432.50',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '12% less than last month',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
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

              // Bottom Navigation Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 24, top: 12, left: 24, right: 24),
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
                          _buildNavItem(context, Icons.history, 'History', true, isFilled: true),
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionItemFromModel(
    Transaction tx, {
    required Color onSurfaceColor,
    required Color onSurfaceVariantColor,
    required Color secondaryColor,
    required Color errorColor,
  }) {
    return _buildTransactionItem(
      icon: tx.icon,
      iconColor: tx.iconColor,
      bgColor: tx.bgColor,
      title: tx.title,
      subtitle: '${tx.formattedDate} • ${tx.status.name[0].toUpperCase()}${tx.status.name.substring(1)}',
      isSubtitleItalic: tx.status == TransactionStatus.pending,
      subtitleColor: tx.status == TransactionStatus.declined ? errorColor : null,
      amount: tx.formattedAmount,
      amountColor: tx.amount > 0 ? secondaryColor : null,
      isAmountStrikethrough: tx.status == TransactionStatus.declined,
      onSurfaceColor: onSurfaceColor,
      onSurfaceVariantColor: onSurfaceVariantColor,
    );
  }
  Widget _buildFilterChip(String label, bool isActive, Color primaryColor, Color primaryContainer, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? primaryContainer : bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: isActive ? const Color(0xFF041E49) : textColor,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    bool isSubtitleItalic = false,
    Color? subtitleColor,
    required String amount,
    Color? amountColor,
    bool isAmountStrikethrough = false,
    required Color onSurfaceColor,
    required Color onSurfaceVariantColor,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
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
                      color: subtitleColor ?? onSurfaceVariantColor,
                      fontSize: 14,
                      fontStyle: isSubtitleItalic ? FontStyle.italic : FontStyle.normal,
                      fontWeight: subtitleColor != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: amountColor ?? onSurfaceColor,
                fontSize: 16,
                decoration: isAmountStrikethrough ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, {bool isFilled = false, VoidCallback? onTap}) {
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
                shadows: isFilled && isActive ? [] : null,
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
