import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class AddWalletItem extends WalletEvent {
  final int userId;
  final Map<String, dynamic> itemData;
  final bool isPass;

  const AddWalletItem({
    required this.userId,
    required this.itemData,
    this.isPass = false,
  });

  @override
  List<Object?> get props => [userId, itemData, isPass];
}

class LoadWalletItems extends WalletEvent {
  final int userId;

  const LoadWalletItems({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class DeleteWalletItem extends WalletEvent {
  final int userId;
  final String itemId;
  final bool isPass;

  const DeleteWalletItem({
    required this.userId,
    required this.itemId,
    required this.isPass,
  });

  @override
  List<Object?> get props => [userId, itemId, isPass];
}
