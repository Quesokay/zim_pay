import 'package:equatable/equatable.dart';
import '../../models/wallet_item.dart';

enum WalletStatus { initial, loading, success, failure }

class WalletState extends Equatable {
  final WalletStatus status;
  final List<WalletItem> walletItems;
  final List<LoyaltyCard> loyaltyCards;
  final String? lastGeneratedToken;

  const WalletState({
    this.status = WalletStatus.initial,
    this.walletItems = const [],
    this.loyaltyCards = const [],
    this.lastGeneratedToken,
  });

  WalletState copyWith({
    WalletStatus? status,
    List<WalletItem>? walletItems,
    List<LoyaltyCard>? loyaltyCards,
    String? lastGeneratedToken,
  }) {
    return WalletState(
      status: status ?? this.status,
      walletItems: walletItems ?? this.walletItems,
      loyaltyCards: loyaltyCards ?? this.loyaltyCards,
      lastGeneratedToken: lastGeneratedToken ?? this.lastGeneratedToken,
    );
  }

  @override
  List<Object?> get props => [status, walletItems, loyaltyCards, lastGeneratedToken];
}
