import '../../screens/check_auth.dart';

abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}
class AuthenticationSignOut extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  final String? token;
  final int? userId;

  AuthenticationSuccess({required this.userId, required this.token});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AuthenticationSuccess && runtimeType == other.runtimeType && token == other.token;

  @override
  int get hashCode => token.hashCode;
}

class AuthenticationInProgress extends AuthenticationState {}

class AuthenticationFailure extends AuthenticationState {
  final String error;
  final AuthErrorType errorType;

  AuthenticationFailure({
    required this.error,
    this.errorType = AuthErrorType.unknownError,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AuthenticationFailure &&
              runtimeType == other.runtimeType &&
              error == other.error &&
              errorType == other.errorType;

  @override
  int get hashCode => Object.hash(error, errorType);
}

class ForgotPasswordSuccess extends AuthenticationState {
  final String message;

  ForgotPasswordSuccess({required this.message});
}