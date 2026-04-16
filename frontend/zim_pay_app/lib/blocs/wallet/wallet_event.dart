import 'package:equatable/equatable.dart';
import '../../models/create_payment_method_dto.dart';
import '../../models/create_pass_dto.dart';

abstract class WalletEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWalletItems extends WalletEvent {
  final int userId;

  LoadWalletItems({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddManualCard extends WalletEvent {
  final int userId;
  final CreatePaymentMethodDto cardDetails;

  AddManualCard({required this.userId, required this.cardDetails});

  @override
  List<Object?> get props => [userId, cardDetails];
}

class AddPass extends WalletEvent {
  final int userId;
  final CreatePassDto passDetails;

  AddPass({required this.userId, required this.passDetails});

  @override
  List<Object?> get props => [userId, passDetails];
}

class DeleteWalletItem extends WalletEvent {
  final int userId;
  final String paymentMethodId;

  DeleteWalletItem({required this.userId, required this.paymentMethodId});

  @override
  List<Object?> get props => [userId, paymentMethodId];
}

class DeletePass extends WalletEvent {
  final int userId;
  final String passId;

  DeletePass({required this.userId, required this.passId});

  @override
  List<Object?> get props => [userId, passId];
}

class SetDefaultPaymentMethod extends WalletEvent {
  final int userId;
  final String paymentMethodId;

  SetDefaultPaymentMethod({required this.userId, required this.paymentMethodId});

  @override
  List<Object?> get props => [userId, paymentMethodId];
}
