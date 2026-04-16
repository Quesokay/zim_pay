import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(const WalletState()) {
    on<LoadWalletItems>(_onLoadWalletItems);
    on<AddManualCard>(_onAddManualCard);
    on<AddPass>(_onAddPass);
    on<DeleteWalletItem>(_onDeleteWalletItem);
    on<DeletePass>(_onDeletePass);
    on<SetDefaultPaymentMethod>(_onSetDefaultPaymentMethod);
  }

  Future<void> _onSetDefaultPaymentMethod(SetDefaultPaymentMethod event, Emitter<WalletState> emit) async {
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      await walletRepository.setDefaultPaymentMethod(event.userId, event.paymentMethodId);
      add(LoadWalletItems(userId: event.userId));
    } catch (e) {
      debugPrint('❌ [BLOC] SetDefaultPaymentMethod FAILED: $e');
      emit(state.copyWith(status: WalletStatus.failure));
    }
  }

  Future<void> _onLoadWalletItems(LoadWalletItems event, Emitter<WalletState> emit) async {
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      final items = await walletRepository.getWalletItems(event.userId);
      final loyaltyCards = await walletRepository.getLoyaltyCards(event.userId);
      emit(state.copyWith(
        status: WalletStatus.success,
        walletItems: items,
        loyaltyCards: loyaltyCards,
      ));
    } catch (_) {
      emit(state.copyWith(status: WalletStatus.failure));
    }
  }

  Future<void> _onAddManualCard(AddManualCard event, Emitter<WalletState> emit) async {
    debugPrint('📥 [BLOC] Received AddManualCard event. User ID: ${event.userId}');
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      debugPrint('🌐 [API] Sending POST request to .NET backend...');
      final token = await walletRepository.addPaymentMethod(event.userId, event.cardDetails);
      add(LoadWalletItems(userId: event.userId));
      debugPrint('✅ [API] Backend responded successfully with token: $token');
      emit(state.copyWith(status: WalletStatus.success, lastGeneratedToken: token));
    } catch (e) {
      debugPrint('❌ [API] HTTP Request completely FAILED: $e');
      emit(state.copyWith(status: WalletStatus.failure));
    }
  }

  Future<void> _onAddPass(AddPass event, Emitter<WalletState> emit) async {
    debugPrint('📥 [BLOC] Received AddPass event. User ID: ${event.userId}');
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      debugPrint('🌐 [API] Sending POST request to .NET backend for Pass...');
      await walletRepository.addPass(event.userId, event.passDetails);
      add(LoadWalletItems(userId: event.userId));
      debugPrint('✅ [API] Pass added successfully!');
      emit(state.copyWith(status: WalletStatus.success));
    } catch (e) {
      debugPrint('❌ [API] AddPass FAILED: $e');
      emit(state.copyWith(status: WalletStatus.failure));
    }
  }

  Future<void> _onDeleteWalletItem(DeleteWalletItem event, Emitter<WalletState> emit) async {
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      await walletRepository.deletePaymentMethod(event.userId, event.paymentMethodId);
      add(LoadWalletItems(userId: event.userId));
    } catch (e) {
      debugPrint('❌ [BLOC] DeleteWalletItem FAILED: $e');
      emit(state.copyWith(status: WalletStatus.failure));
    }
  }

  Future<void> _onDeletePass(DeletePass event, Emitter<WalletState> emit) async {
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      await walletRepository.deletePass(event.userId, event.passId);
      add(LoadWalletItems(userId: event.userId));
    } catch (e) {
      debugPrint('❌ [BLOC] DeletePass FAILED: $e');
      emit(state.copyWith(status: WalletStatus.failure));
    }
  }
}
