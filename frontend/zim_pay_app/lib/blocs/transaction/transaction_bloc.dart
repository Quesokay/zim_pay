import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;

  TransactionBloc({required this.transactionRepository}) : super(const TransactionState()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadPendingTransactions>(_onLoadPendingTransactions);
    on<ApproveTransaction>(_onApproveTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus_State.loading));
    try {
      final transactions = await transactionRepository.getTransactions(event.userId);
      emit(state.copyWith(
        status: TransactionStatus_State.success,
        transactions: transactions,
      ));
    } catch (_) {
      emit(state.copyWith(status: TransactionStatus_State.failure));
    }
  }

  Future<void> _onLoadPendingTransactions(
    LoadPendingTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus_State.loading));
    try {
      final pendingTransactions = await transactionRepository.getPendingTransactions(event.userId);
      emit(state.copyWith(
        status: TransactionStatus_State.success,
        pendingTransactions: pendingTransactions,
      ));
    } catch (_) {
      emit(state.copyWith(status: TransactionStatus_State.failure));
    }
  }

  Future<void> _onApproveTransaction(
    ApproveTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus_State.loading));
    try {
      await transactionRepository.approveTransaction(event.transactionId);
      // Remove approved transaction from local state by comparing IDs as strings
      final updatedPending = state.pendingTransactions
          .where((t) => t.id != event.transactionId.toString())
          .toList();
      emit(state.copyWith(
        status: TransactionStatus_State.success,
        pendingTransactions: updatedPending,
      ));
    } catch (_) {
      emit(state.copyWith(status: TransactionStatus_State.failure));
    }
  }
}
