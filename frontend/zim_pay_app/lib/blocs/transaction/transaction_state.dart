// ignore_for_file: camel_case_types

import 'package:equatable/equatable.dart';
import '../../models/transaction.dart';

enum TransactionStatus_State { initial, loading, success, failure }

class TransactionState extends Equatable {
  final TransactionStatus_State status;
  final List<Transaction> transactions;
  final List<Transaction> pendingTransactions;

  const TransactionState({
    this.status = TransactionStatus_State.initial,
    this.transactions = const [],
    this.pendingTransactions = const [],
  });

  TransactionState copyWith({
    TransactionStatus_State? status,
    List<Transaction>? transactions,
    List<Transaction>? pendingTransactions,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      pendingTransactions: pendingTransactions ?? this.pendingTransactions,
    );
  }

  @override
  List<Object?> get props => [status, transactions, pendingTransactions];
}
