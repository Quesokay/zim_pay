import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;

  TransactionBloc({required this.transactionRepository}) : super(const TransactionState()) {
    on<LoadTransactions>(_onLoadTransactions);
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
}
