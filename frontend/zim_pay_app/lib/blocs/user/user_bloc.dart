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