part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginEvent extends UserEvent {
  final String email;

  LoginEvent(this.email);

  @override
  List<Object> get props => [email];
}

class CreateUserEvent extends UserEvent {
  final String email;
  final String name;
  final String phone;

  CreateUserEvent(this.email, this.name, this.phone);

  @override
  List<Object> get props => [email, name, phone];
}

class SetUserEvent extends UserEvent {
  final User user;

  SetUserEvent(this.user);

  @override
  List<Object> get props => [user];
}

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
