import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(const WalletState()) {
    on<LoadWalletItems>(_onLoadWalletItems);
  }

  Future<void> _onLoadWalletItems(
    LoadWalletItems event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      final items = await walletRepository.getWalletItems();
      final loyaltyCards = await walletRepository.getLoyaltyCards();
      emit(state.copyWith(
        status: WalletStatus.success,
        walletItems: items,
        loyaltyCards: loyaltyCards,
      ));
    } catch (_) {
      emit(state.copyWith(status: WalletStatus.failure));
    }
  }
}
