import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionRepository {
  Future<List<Transaction>> getTransactions() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      Transaction(
        id: '1',
        title: 'Whole Foods Market',
        date: DateTime.now(),
        status: TransactionStatus.completed,
        amount: -84.20,
        icon: Icons.shopping_bag,
        iconColor: const Color(0xFF0058BA),
        bgColor: const Color(0xFFDEE3E8),
      ),
      Transaction(
        id: '2',
        title: 'Google Play Reward',
        date: DateTime.now(),
        status: TransactionStatus.completed,
        amount: 5.00,
        icon: Icons.card_giftcard,
        iconColor: const Color(0xFF006A2B),
        bgColor: const Color(0xFFCFFFCE),
      ),
      Transaction(
        id: '3',
        title: 'Uber Technologies',
        date: DateTime.now(),
        status: TransactionStatus.pending,
        amount: -22.50,
        icon: Icons.local_taxi,
        iconColor: const Color(0xFF0058BA),
        bgColor: const Color(0xFFDEE3E8),
      ),
      Transaction(
        id: '4',
        title: 'Blue Bottle Coffee',
        date: DateTime.now(),
        status: TransactionStatus.completed,
        amount: -6.75,
        icon: Icons.coffee,
        iconColor: const Color(0xFF0058BA),
        bgColor: const Color(0xFFDEE3E8),
      ),
      Transaction(
        id: '5',
        title: 'Transport for London',
        date: DateTime.now(),
        status: TransactionStatus.completed,
        amount: -2.40,
        icon: Icons.train,
        iconColor: const Color(0xFF0058BA),
        bgColor: const Color(0xFFDEE3E8),
      ),
      Transaction(
        id: '6',
        title: 'Netflix Subscription',
        date: DateTime.now(),
        status: TransactionStatus.declined,
        amount: -15.99,
        icon: Icons.warning,
        iconColor: const Color(0xFFB41A14),
        bgColor: const Color(0xFFFF9384).withValues(alpha: 0.1),
      ),
    ];
  }
}
