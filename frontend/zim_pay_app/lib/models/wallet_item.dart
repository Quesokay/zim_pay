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
}
