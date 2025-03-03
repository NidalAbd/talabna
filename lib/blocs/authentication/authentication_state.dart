import 'package:equatable/equatable.dart';
import '../../screens/check_auth.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationInProgress extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  final int? userId;
  final String? token;
  final String authType;
  final bool isNewUser;
  final bool dataSaverEnabled;

  const AuthenticationSuccess({
    required this.userId,
    required this.token,
    this.authType = 'email',
    this.isNewUser = false,
    this.dataSaverEnabled = false,
  });

  @override
  List<Object?> get props => [userId, token, authType, isNewUser, dataSaverEnabled];

  // Add a copyWith method for easy state updates
  AuthenticationSuccess copyWith({
    int? userId,
    String? token,
    String? authType,
    bool? isNewUser,
    bool? dataSaverEnabled,
  }) {
    return AuthenticationSuccess(
      userId: userId ?? this.userId,
      token: token ?? this.token,
      authType: authType ?? this.authType,
      isNewUser: isNewUser ?? this.isNewUser,
      dataSaverEnabled: dataSaverEnabled ?? this.dataSaverEnabled,
    );
  }
}

class DataSaverToggled extends AuthenticationSuccess {
  final bool isEnabled;

  const DataSaverToggled({
    required this.isEnabled,
    required super.userId,
    required super.token,
    required super.authType,
    super.isNewUser,
  }) : super(
    dataSaverEnabled: isEnabled,
  );

  @override
  List<Object?> get props => [userId, token, authType, isEnabled];
}

class DataSaverToggleFailure extends AuthenticationSuccess {
  final String error;

  const DataSaverToggleFailure({
    required this.error,
    required super.userId,
    required super.token,
    required super.authType,
    super.isNewUser,
    super.dataSaverEnabled,
  });

  @override
  List<Object?> get props => [userId, token, authType, error];
}

class AuthenticationFailure extends AuthenticationState {
  final String error;
  final AuthErrorType errorType;

  const AuthenticationFailure({
    required this.error,
    this.errorType = AuthErrorType.unknownError,
  });

  @override
  List<Object> get props => [error, errorType];
}

class ForgotPasswordSuccess extends AuthenticationState {
  final String message;

  const ForgotPasswordSuccess({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}