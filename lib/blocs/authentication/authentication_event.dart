import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final String token;

  const LoggedIn({required this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'LoggedIn { token: $token }';
}
class GoogleSignInRequest extends AuthenticationEvent {}
class GoogleSignInRequestSuccess extends AuthenticationEvent {
  final String token;

  const GoogleSignInRequestSuccess({required this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'LoggedIn { token: $token }';
}
class LoggedOut extends AuthenticationEvent {}

class LoginRequest extends AuthenticationEvent {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];

  @override
  String toString() => 'Login { email: $email, password: $password }';
}

class Register extends AuthenticationEvent {
  final String name;
  final String email;
  final String password;

  const Register({required this.name, required this.email, required this.password});

  @override
  List<Object> get props => [name, email, password];

  @override
  String toString() => 'Register { name: $name, email: $email, password: $password }';
}

class ForgotPassword extends AuthenticationEvent {
  final String email;

  const ForgotPassword({required this.email});

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'ForgotPassword { email: $email }';
}
