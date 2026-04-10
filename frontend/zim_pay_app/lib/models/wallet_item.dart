import 'package:flutter/material.dart';

enum WalletItemType { creditCard, transitPass, loyaltyCard }

abstract class WalletItem {
  final String id;
  final String title;
  final WalletItemType type;

  WalletItem({required this.id, required this.title, required this.type});
}

class CreditCard extends WalletItem {
  final String bankName;
  final String cardNumber;
  final String expiryDate;
  final Color primaryColor;
  final Color secondaryColor;

  CreditCard({
    required super.id,
    required super.title,
    required this.bankName,
    required this.cardNumber,
    required this.expiryDate,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(type: WalletItemType.creditCard);

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'].toString(),
      title: json['bankName'] ?? 'Credit Card',
      bankName: json['bankName'] ?? 'Bank',
      cardNumber: '•••• •••• •••• ${json['cardNumber']?.toString().split(' ').last ?? '0000'}',
      expiryDate: json['expiryDate'] ?? 'MM/YY',
      primaryColor: const Color(0xFF0058BA),
      secondaryColor: const Color(0xFF6C9FFF),
    );
  }
}

class TransitPass extends WalletItem {
  final String balance;
  final Color primaryColor;
  final Color secondaryColor;

  TransitPass({
    required super.id,
    required super.title,
    required this.balance,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(type: WalletItemType.transitPass);

  factory TransitPass.fromJson(Map<String, dynamic> json) {
    return TransitPass(
      id: json['id'].toString(),
      title: json['title'] ?? 'Transit Pass',
      balance: '\$${(json['balance'] ?? 0.0).toStringAsFixed(2)}',
      primaryColor: const Color(0xFF006A2B),
      secondaryColor: const Color(0xFF86F898),
    );
  }
}

class LoyaltyCard extends WalletItem {
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  LoyaltyCard({
    required super.id,
    required super.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  }) : super(type: WalletItemType.loyaltyCard);

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'].toString(),
      title: json['title'] ?? 'Loyalty Card',
      subtitle: json['details'] ?? 'Membership',
      icon: Icons.card_membership,
      iconColor: const Color(0xFF0058BA),
      bgColor: const Color(0xFF6C9FFF).withValues(alpha: 0.3),
    );
  }
}
