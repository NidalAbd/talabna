import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/data/repositories/authentication_repository.dart';

import '../../screens/check_auth.dart'; // Import the new error handling

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;

  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(AuthenticationInitial()) {
    // Login Event Handler
    on<LoginRequest>((event, emit) async {
      emit(AuthenticationInProgress());
      try {
        final result = await _authenticationRepository.login(
          authProvider: 'email',
          email: event.email,
          password: event.password,
        );
        final userId = result['userId'];
        final token = result['token'];

        emit(AuthenticationSuccess(userId: userId, token: token));
      } catch (e) {
        // Detailed error handling
        AuthErrorType errorType;
        String errorMessage = e.toString();

        if (errorMessage.contains('network')) {
          errorType = AuthErrorType.networkError;
        } else if (errorMessage.contains('credentials')) {
          errorType = AuthErrorType.invalidCredentials;
        } else if (errorMessage.contains('verify')) {
          errorType = AuthErrorType.emailNotVerified;
        } else if (errorMessage.contains('locked')) {
          errorType = AuthErrorType.accountLocked;
        } else if (errorMessage.contains('attempts')) {
          errorType = AuthErrorType.tooManyAttempts;
        } else if (errorMessage.contains('server')) {
          errorType = AuthErrorType.serverError;
        } else {
          errorType = AuthErrorType.unknownError;
        }

        emit(AuthenticationFailure(
          error: errorMessage,
          errorType: errorType,
        ));
      }
    });

    // Google Sign-In Event Handler
    on<GoogleSignInRequest>((event, emit) async {
      emit(AuthenticationInProgress());
      try {
        final result = await _authenticationRepository.signInWithGoogle();
        final userId = result['id'];
        final token = result['token'];

        emit(AuthenticationSuccess(userId: userId, token: token));
      } catch (e) {
        AuthErrorType errorType;
        String errorMessage = e.toString();

        if (errorMessage.contains('network')) {
          errorType = AuthErrorType.networkError;
        } else if (errorMessage.contains('canceled')) {
          errorType = AuthErrorType.unknownError;
        } else {
          errorType = AuthErrorType.serverError;
        }

        emit(AuthenticationFailure(
          error: errorMessage,
          errorType: errorType,
        ));
      }
    });

    // Logged In Event Handler
    on<LoggedIn>((event, emit) async {
      emit(AuthenticationInProgress());
      try {
        final token = await _authenticationRepository.getAuthToken();
        final userId = await _authenticationRepository.getUserId();
        emit(AuthenticationSuccess(userId: userId, token: token));
      } catch (e) {
        emit(AuthenticationFailure(
          error: e.toString(),
          errorType: AuthErrorType.unknownError,
        ));
      }
    });

    // Registration Event Handler
    on<Register>((event, emit) async {
      emit(AuthenticationInProgress());
      try {
        final result = await _authenticationRepository.register(
          name: event.name,
          email: event.email,
          password: event.password,
          authProvider: 'email',
        );
        final userId = result['userId'];
        final token = result['token'];

        emit(AuthenticationSuccess(userId: userId, token: token));
      } catch (e) {
        AuthErrorType errorType;
        String errorMessage = e.toString();

        if (errorMessage.contains('email')) {
          errorType = AuthErrorType.emailNotVerified;
        } else if (errorMessage.contains('network')) {
          errorType = AuthErrorType.networkError;
        } else {
          errorType = AuthErrorType.serverError;
        }

        emit(AuthenticationFailure(
          error: errorMessage,
          errorType: errorType,
        ));
      }
    });

    // Logout Event Handler
    on<LoggedOut>((event, emit) async {
      await _authenticationRepository.removeAuthToken();
      emit(AuthenticationInitial());
    });

    // Forgot Password Event Handler
    on<ForgotPassword>((event, emit) async {
      emit(AuthenticationInProgress());
      try {
        await _authenticationRepository.resetPassword(email: event.email);
        emit(ForgotPasswordSuccess(
          message: "Password reset link sent successfully.",
        ));
      } catch (e) {
        AuthErrorType errorType;
        String errorMessage = e.toString();

        if (errorMessage.contains('network')) {
          errorType = AuthErrorType.networkError;
        } else if (errorMessage.contains('user')) {
          errorType = AuthErrorType.invalidCredentials;
        } else {
          errorType = AuthErrorType.serverError;
        }

        emit(AuthenticationFailure(
          error: errorMessage,
          errorType: errorType,
        ));
      }
    });
  }
}