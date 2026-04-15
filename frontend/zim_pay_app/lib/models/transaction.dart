import 'package:flutter/material.dart';

enum TransactionStatus { completed, pending, declined }

class Transaction {
  final String id;
  final String title;
  final DateTime date;
  final TransactionStatus status;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  Transaction({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final String type = json['type'] ?? 'Payment';
    final String statusStr = json['status'] ?? 'Completed';
    
    TransactionStatus status;
    switch (statusStr) {
      case 'Pending':
        status = TransactionStatus.pending;
        break;
      case 'Declined':
      case 'Cancelled':
        status = TransactionStatus.declined;
        break;
      default:
        status = TransactionStatus.completed;
    }

    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case 'TopUp':
        icon = Icons.account_balance_wallet;
        iconColor = const Color(0xFF006A2B);
        bgColor = const Color(0xFFCFFFCE);
        break;
      case 'Transfer':
        icon = Icons.send;
        iconColor = const Color(0xFF0058BA);
        bgColor = const Color(0xFFDEE3E8);
        break;
      default:
        icon = Icons.shopping_bag;
        iconColor = const Color(0xFF0058BA);
        bgColor = const Color(0xFFDEE3E8);
    }

    return Transaction(
      id: json['id'].toString(),
      title: json['description'] ?? 'Transaction',
      date: DateTime.parse(json['date']),
      status: status,
      amount: (json['amount'] as num).toDouble(),
      icon: icon,
      iconColor: iconColor,
      bgColor: bgColor,
    );
  }

  String get formattedAmount => '${amount >= 0 ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}';
  
  String get formattedDate {
    // Simplified date formatting for extraction purposes
    return 'Nov 14'; 
  }
}
