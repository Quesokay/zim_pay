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
