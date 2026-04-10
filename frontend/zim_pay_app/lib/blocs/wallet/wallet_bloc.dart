import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(const WalletState()) {
    on<LoadWalletItems>(_onLoadWalletItems);
    on<AddWalletItem>(_onAddWalletItem);
    on<DeleteWalletItem>(_onDeleteWalletItem);
  }

  Future<void> _onDeleteWalletItem(
    DeleteWalletItem event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      if (event.isPass) {
        await walletRepository.deletePass(event.userId, event.itemId);
      } else {
        await walletRepository.deletePaymentMethod(event.userId, event.itemId);
      }
      add(LoadWalletItems(userId: event.userId));
    } catch (_) {
      emit(state.copyWith(status: WalletStatus.failure));
    }
  }

  Future<void> _onAddWalletItem(
    AddWalletItem event,
    Emitter<WalletState> emit,
  ) async {
    print('WalletBloc: Adding wallet item for user ${event.userId}');
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      if (event.isPass) {
        await walletRepository.addPass(event.userId, event.itemData);
      } else {
        await walletRepository.addPaymentMethod(event.userId, event.itemData);
      }
      print('WalletBloc: Successfully added item, refreshing list...');
      add(LoadWalletItems(userId: event.userId));
    } catch (e) {
      print('WalletBloc: Error adding item: $e');
      emit(state.copyWith(status: WalletStatus.failure));
    }
  }

  Future<void> _onLoadWalletItems(
    LoadWalletItems event,
    Emitter<WalletState> emit,
  ) async {
    print('WalletBloc: Loading items for user ${event.userId}');
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      final items = await walletRepository.getWalletItems(event.userId);
      print('WalletBloc: Loaded ${items.length} items');
      final loyaltyCards = await walletRepository.getLoyaltyCards(event.userId);
      print('WalletBloc: Loaded ${loyaltyCards.length} loyalty cards');
      emit(state.copyWith(
        status: WalletStatus.success,
        walletItems: items,
        loyaltyCards: loyaltyCards,
      ));
    } catch (e, stack) {
      print('WalletBloc: Failed to load wallet items: $e');
      print(stack);
      emit(state.copyWith(status: WalletStatus.failure));
    }
  }
}
