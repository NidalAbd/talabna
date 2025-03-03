import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class LoginRequest extends AuthenticationEvent {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class GoogleSignInRequest extends AuthenticationEvent {}

class AppleSignInRequest extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final String? token;

  const LoggedIn({this.token});

  @override
  List<Object> get props => token != null ? [token!] : [];
}

class Register extends AuthenticationEvent {
  final String name;
  final String email;
  final String password;

  const Register({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, password];
}

class LoggedOut extends AuthenticationEvent {}

class ForgotPassword extends AuthenticationEvent {
  final String email;

  const ForgotPassword({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}

class ToggleDataSaver extends AuthenticationEvent {
  const ToggleDataSaver();
}

class SetDataSaverEnabled extends AuthenticationEvent {
  final bool enabled;

  const SetDataSaverEnabled({required this.enabled});

  @override
  List<Object> get props => [enabled];
}