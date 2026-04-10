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

  String get formattedAmount => '${amount >= 0 ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}';
  
  String get formattedDate {
    // Simplified date formatting for extraction purposes
    return 'Nov 14'; 
  }
}
