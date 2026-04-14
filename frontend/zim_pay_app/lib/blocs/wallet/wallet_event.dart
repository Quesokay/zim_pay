import 'package:equatable/equatable.dart';
import '../../models/create_payment_method_dto.dart';
import '../../models/create_pass_dto.dart';

abstract class WalletEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWalletItems extends WalletEvent {}

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
