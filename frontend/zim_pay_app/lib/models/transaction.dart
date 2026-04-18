import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TransactionStatus { completed, pending, declined }

class Transaction {
  final String id;
  final String title;
  final String type;
  final DateTime date;
  final TransactionStatus status;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  Transaction({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.status,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final String typeFromRow = json['type'] ?? 'Payment';
    // Normalize type for comparison
    final String type = typeFromRow.toLowerCase();
    
    final String statusStr = (json['status'] ?? 'Completed').toString().toLowerCase();
    
    TransactionStatus status;
    if (statusStr.contains('pending')) {
      status = TransactionStatus.pending;
    } else if (statusStr.contains('declined') || statusStr.contains('cancelled') || statusStr.contains('failed')) {
      status = TransactionStatus.declined;
    } else {
      status = TransactionStatus.completed;
    }

    IconData icon;
    Color iconColor;
    Color bgColor;

    if (type.contains('topup')) {
      icon = Icons.account_balance_wallet;
      iconColor = const Color(0xFF006A2B);
      bgColor = const Color(0xFFCFFFCE);
    } else if (type.contains('transfer')) {
      icon = Icons.send;
      iconColor = const Color(0xFF0058BA);
      bgColor = const Color(0xFFDEE3E8);
    } else {
      icon = Icons.shopping_bag;
      iconColor = const Color(0xFF0058BA);
      bgColor = const Color(0xFFDEE3E8);
    }

    return Transaction(
      id: json['id'].toString(),
      title: json['description'] ?? 'Transaction',
      type: typeFromRow,
      date: DateTime.parse(json['date']),
      status: status,
      amount: (json['amount'] as num).toDouble(),
      icon: icon,
      iconColor: iconColor,
      bgColor: bgColor,
    );
  }

  bool get isSpending => !type.toLowerCase().contains('topup');

  String get formattedAmount => '${!isSpending ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}';
  
  String get formattedDate {
    return DateFormat('MMM d').format(date);
  }
}
