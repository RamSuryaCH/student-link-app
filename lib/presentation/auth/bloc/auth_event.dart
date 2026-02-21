import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String department;
  final String? yearOfStudy;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.department,
    this.yearOfStudy,
  });

  @override
  List<Object?> get props => [email, password, name, department, yearOfStudy];
}

class SignOutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}
