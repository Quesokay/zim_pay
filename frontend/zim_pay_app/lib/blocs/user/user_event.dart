part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginEvent extends UserEvent {
  final String pin;

  LoginEvent(this.pin);

  @override
  List<Object> get props => [pin];
}

class CreateUserEvent extends UserEvent {
  final String email;
  final String name;
  final String pin;

  CreateUserEvent(this.email, this.name, this.pin);

  @override
  List<Object> get props => [email, name, pin];
}

class SetUserEvent extends UserEvent {
  final User user;

  SetUserEvent(this.user);

  @override
  List<Object> get props => [user];
}

class LogoutEvent extends UserEvent {}

class UpdateUserEvent extends UserEvent {
  final String? name;
  final String? phone;
  final bool? fingerprintEnabled;
  final bool? contactlessEnabled;
  final double? tapLimit;

  UpdateUserEvent({
    this.name,
    this.phone,
    this.fingerprintEnabled,
    this.contactlessEnabled,
    this.tapLimit,
  });

  @override
  List<Object> get props => [
        name ?? '',
        phone ?? '',
        fingerprintEnabled ?? '',
        contactlessEnabled ?? '',
        tapLimit ?? '',
      ];
}
