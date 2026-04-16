import 'package:flutter/material.dart';

enum WalletItemType { creditCard, transitPass, loyaltyCard }

enum CardType {
  creditCard,
  debitCard,
  bankAccount,
}

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
  final double balance;
  final bool isDefault;
  final CardType cardType;

  CreditCard({
    required super.id,
    required super.title,
    required this.bankName,
    required this.cardNumber,
    required this.expiryDate,
    required this.primaryColor,
    required this.secondaryColor,
    required this.balance,
    required this.isDefault,
    required this.cardType,
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
      balance: (json['balance'] as num?)?.toDouble() ?? 1500.0,
      isDefault: json['isDefault'] ?? false,
      cardType: CardType.values[json['type'] ?? 0],
    );
  }
}

class TransitPass extends WalletItem {
  final double balance;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDefault;

  TransitPass({
    required super.id,
    required super.title,
    required this.balance,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDefault,
  }) : super(type: WalletItemType.transitPass);

  factory TransitPass.fromJson(Map<String, dynamic> json) {
    return TransitPass(
      id: json['id'].toString(),
      title: json['title'] ?? 'Transit Pass',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      primaryColor: const Color(0xFF006A2B),
      secondaryColor: const Color(0xFF86F898),
      isDefault: json['isDefault'] ?? false,
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
