import 'package:flutter/material.dart';
import '../models/wallet_item.dart';

class WalletRepository {
  Future<List<WalletItem>> getWalletItems() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      CreditCard(
        id: '1',
        title: 'Bank of Future',
        bankName: 'Bank of Future',
        cardNumber: '•••• •••• •••• 8892',
        expiryDate: '12/28',
        primaryColor: const Color(0xFF0058BA),
        secondaryColor: const Color(0xFF6C9FFF),
      ),
      TransitPass(
        id: '2',
        title: 'City Transit',
        balance: '\$42.50',
        primaryColor: const Color(0xFF006A2B),
        secondaryColor: const Color(0xFF86F898),
      ),
    ];
  }

  Future<List<LoyaltyCard>> getLoyaltyCards() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      LoyaltyCard(
        id: '3',
        title: 'Coffee Shop Rewards',
        subtitle: '8 of 10 stars earned',
        icon: Icons.coffee,
        iconColor: const Color(0xFFB41A14),
        bgColor: const Color(0xFFFF9384).withValues(alpha: 0.3),
      ),
      LoyaltyCard(
        id: '4',
        title: 'Public Library',
        subtitle: 'Membership Active',
        icon: Icons.local_library,
        iconColor: const Color(0xFF0058BA),
        bgColor: const Color(0xFF6C9FFF).withValues(alpha: 0.3),
      ),
      LoyaltyCard(
        id: '5',
        title: 'Everest Gym',
        subtitle: 'Next billing: Oct 12',
        icon: Icons.fitness_center,
        iconColor: const Color(0xFF006A2B),
        bgColor: const Color(0xFF86F898).withValues(alpha: 0.3),
      ),
    ];
  }
}
