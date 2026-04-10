import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletItems extends WalletEvent {
  final int userId;

  const LoadWalletItems({required this.userId});

  @override
  List<Object?> get props => [userId];
}
