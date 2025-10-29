import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;
  final String displayName;
  final DateTime dateOfBirth;
  final String? gender;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.username,
    required this.displayName,
    required this.dateOfBirth,
    this.gender,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        username,
        displayName,
        dateOfBirth,
        gender,
      ];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthUpdateInterests extends AuthEvent {
  final List<String> interests;

  const AuthUpdateInterests(this.interests);

  @override
  List<Object> get props => [interests];
}
