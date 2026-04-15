import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final int userId;

  const LoadTransactions({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadPendingTransactions extends TransactionEvent {
  final int userId;

  const LoadPendingTransactions({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ApproveTransaction extends TransactionEvent {
  final int transactionId;

  const ApproveTransaction({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}
