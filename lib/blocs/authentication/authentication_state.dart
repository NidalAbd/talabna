
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

  AuthenticationFailure({required this.error});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AuthenticationFailure && runtimeType == other.runtimeType && error == other.error;

  @override
  int get hashCode => error.hashCode;
}
class ForgotPasswordSuccess extends AuthenticationState {
  final String message;

  ForgotPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
