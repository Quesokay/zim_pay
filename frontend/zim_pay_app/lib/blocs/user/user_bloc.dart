import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc(this.userRepository) : super(UserInitial()) {
    on<CreateUserEvent>(_onCreateUser);
    on<LoginEvent>(_onLogin);
    on<UpdateUserEvent>(_onUpdateUser);
  }

  Future<void> _onUpdateUser(UpdateUserEvent event, Emitter<UserState> emit) async {
    final currentState = state;
    if (currentState is UserCreated) {
      emit(UserLoading());
      try {
        final updatedUser = await userRepository.updateUser(
          currentState.user.id,
          name: event.name,
          phone: event.phone,
          fingerprintEnabled: event.fingerprintEnabled,
          contactlessEnabled: event.contactlessEnabled,
        );
        emit(UserCreated(updatedUser));
      } catch (e) {
        emit(UserError(e.toString()));
        emit(currentState); // Revert to previous state
      }
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final user = await userRepository.login(event.email);
      emit(UserCreated(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onCreateUser(CreateUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final user = await userRepository.createUser(event.email, event.name, event.phone);
      emit(UserCreated(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}