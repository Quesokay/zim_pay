import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F7FA);
    const onSurfaceColor = Color(0xFF2B2F32);
    const onSurfaceVariantColor = Color(0xFF585C5F);
    const surfaceContainerLowestColor = Color(0xFFFFFFFF);

    final transactions = [
      {'title': 'Starbucks Coffee', 'date': 'Today, 08:45 AM', 'amount': '-\$4.50', 'icon': Icons.coffee, 'color': Colors.brown},
      {'title': 'Amazon.com', 'date': 'Yesterday, 02:15 PM', 'amount': '-\$89.99', 'icon': Icons.shopping_bag, 'color': Colors.orange},
      {'title': 'Uber Trip', 'date': 'Oct 24, 11:30 PM', 'amount': '-\$24.20', 'icon': Icons.directions_car, 'color': Colors.black},
      {'title': 'Apple Subscription', 'date': 'Oct 22, 09:00 AM', 'amount': '-\$9.99', 'icon': Icons.apple, 'color': Colors.grey},
      {'title': 'Salary Deposit', 'date': 'Oct 20, 08:00 AM', 'amount': '+\$4,250.00', 'icon': Icons.account_balance, 'color': Colors.green},
      {'title': 'City Metro', 'date': 'Oct 19, 05:45 PM', 'amount': '-\$2.75', 'icon': Icons.train, 'color': Colors.blue},
      {'title': 'Grocery Store', 'date': 'Oct 18, 12:30 PM', 'amount': '-\$64.12', 'icon': Icons.shopping_cart, 'color': Colors.green},
    ];

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
          'Transactions',
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
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          final isPositive = (tx['amount'] as String).startsWith('+');

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceContainerLowestColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (tx['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(tx['icon'] as IconData, color: tx['color'] as Color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['title'] as String,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        tx['date'] as String,
                        style: GoogleFonts.inter(
                          color: onSurfaceVariantColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  tx['amount'] as String,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : onSurfaceColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
