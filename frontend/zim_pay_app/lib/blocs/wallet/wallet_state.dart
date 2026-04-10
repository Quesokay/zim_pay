import 'package:equatable/equatable.dart';
import '../../models/wallet_item.dart';

enum WalletStatus { initial, loading, success, failure }

class WalletState extends Equatable {
  final WalletStatus status;
  final List<WalletItem> walletItems;
  final List<LoyaltyCard> loyaltyCards;

  const WalletState({
    this.status = WalletStatus.initial,
    this.walletItems = const [],
    this.loyaltyCards = const [],
  });

  WalletState copyWith({
    WalletStatus? status,
    List<WalletItem>? walletItems,
    List<LoyaltyCard>? loyaltyCards,
  }) {
    return WalletState(
      status: status ?? this.status,
      walletItems: walletItems ?? this.walletItems,
      loyaltyCards: loyaltyCards ?? this.loyaltyCards,
    );
  }

  @override
  List<Object?> get props => [status, walletItems, loyaltyCards];
}
