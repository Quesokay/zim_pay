part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CreateUserEvent extends UserEvent {
  final String email;
  final String name;
  final String phone;

  CreateUserEvent(this.email, this.name, this.phone);

  @override
  List<Object> get props => [email, name, phone];
}