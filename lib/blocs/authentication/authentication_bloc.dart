import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/data/repositories/authentication_repository.dart';
import 'package:talbna/utils/debug_logger.dart'; // Ensure this import exists

import '../../screens/check_auth.dart'; // Import the error handling

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
          email: event.email,
          password: event.password,
        );
        final userId = result['userId'];
        final token = result['token'];
        final authType = result['authType'] ?? 'email';
        final dataSaverEnabled = await _authenticationRepository.getDataSaverStatus();

        emit(AuthenticationSuccess(
          userId: userId,
          token: token,
          authType: authType,
          dataSaverEnabled: dataSaverEnabled,
        ));
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
        // Log the attempt
        DebugLogger.log('Starting Google Sign-In process', category: 'AUTH');

        final result = await _authenticationRepository.signInWithGoogle();

        // Log the result
        DebugLogger.log('Google Sign-In successful: ${result['userId']}', category: 'AUTH');

        final userId = result['userId'];
        final token = result['token'];
        final authType = result['authType'] ?? 'google';
        final isNewUser = result['isNewUser'] ?? false;
        final dataSaverEnabled = await _authenticationRepository.getDataSaverStatus();

        emit(AuthenticationSuccess(
          userId: userId,
          token: token,
          authType: authType,
          isNewUser: isNewUser,
          dataSaverEnabled: dataSaverEnabled,
        ));
      } catch (e) {
        // Log the error
        DebugLogger.log('Google Sign-In error: $e', category: 'AUTH_ERROR');

        AuthErrorType errorType;
        String errorMessage = e.toString().toLowerCase();

        if (errorMessage.contains('network') ||
            errorMessage.contains('connection') ||
            errorMessage.contains('timeout')) {
          errorType = AuthErrorType.networkError;
        } else if (errorMessage.contains('cancelled') ||
            errorMessage.contains('canceled') ||
            errorMessage.contains('cancel by user')) {
          errorType = AuthErrorType.userCancelled;
        } else if (errorMessage.contains('token') ||
            errorMessage.contains('authentication')) {
          errorType = AuthErrorType.serverError;
        } else {
          errorType = AuthErrorType.unknownError;
        }

        emit(AuthenticationFailure(
          error: e.toString(),
          errorType: errorType,
        ));
      }
    });

    // Logged In Event Handler
    on<LoggedIn>((event, emit) async {
      emit(AuthenticationInProgress());
      try {
        // If token is provided in the event, use it directly
        String? token = event.token;

        // If not provided, try to get from repository
        token ??= await _authenticationRepository.getAuthToken();

        final userId = await _authenticationRepository.getUserId();
        final authType = await _authenticationRepository.getAuthType() ?? 'email';
        final dataSaverEnabled = await _authenticationRepository.getDataSaverStatus();

        if (token != null && userId != null) {
          // Verify token validity with the server
          final bool isValid = await _authenticationRepository.checkTokenValidity(token);

          if (isValid) {
            emit(AuthenticationSuccess(
              userId: userId,
              token: token,
              authType: authType,
              dataSaverEnabled: dataSaverEnabled,
            ));
          } else {
            // Token is invalid, log out and return to initial state
            await _authenticationRepository.clearAuthData();
            emit(AuthenticationInitial());
          }
        } else {
          emit(AuthenticationInitial());
        }
      } catch (e) {
        // Log authentication error
        DebugLogger.log('Authentication check error: $e', category: 'AUTH_ERROR');

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
        );
        final userId = result['userId'];
        final token = result['token'];
        final authType = result['authType'] ?? 'email';
        final dataSaverEnabled = false; // Default for new users

        emit(AuthenticationSuccess(
          userId: userId,
          token: token,
          authType: authType,
          dataSaverEnabled: dataSaverEnabled,
        ));
      } catch (e) {
        AuthErrorType errorType;
        String errorMessage = e.toString().toLowerCase();

        if (errorMessage.contains('email') &&
            (errorMessage.contains('exists') || errorMessage.contains('taken'))) {
          errorType = AuthErrorType.emailAlreadyExists;
        } else if (errorMessage.contains('network')) {
          errorType = AuthErrorType.networkError;
        } else {
          errorType = AuthErrorType.serverError;
        }

        emit(AuthenticationFailure(
          error: e.toString(),
          errorType: errorType,
        ));
      }
    });

    // Logout Event Handler
    on<LoggedOut>((event, emit) async {
      await _authenticationRepository.logout();
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
        String errorMessage = e.toString().toLowerCase();

        if (errorMessage.contains('network')) {
          errorType = AuthErrorType.networkError;
        } else if (errorMessage.contains('user')) {
          errorType = AuthErrorType.invalidCredentials;
        } else {
          errorType = AuthErrorType.serverError;
        }

        emit(AuthenticationFailure(
          error: e.toString(),
          errorType: errorType,
        ));
      }
    });

    // Toggle Data Saver Event Handler
    on<ToggleDataSaver>((event, emit) async {
      if (state is AuthenticationSuccess) {
        final currentState = state as AuthenticationSuccess;
        try {
          final newDataSaverStatus = await _authenticationRepository.toggleDataSaver();

          emit(currentState.copyWith(
            dataSaverEnabled: newDataSaverStatus,
          ));

          // Emit a special state to notify listeners about data saver change
          emit(DataSaverToggled(
            isEnabled: newDataSaverStatus,
            userId: currentState.userId,
            token: currentState.token,
            authType: currentState.authType,
          ));

        } catch (e) {
          // Emit temporary failure notification
          emit(DataSaverToggleFailure(
            error: e.toString(),
            userId: currentState.userId,
            token: currentState.token,
            authType: currentState.authType,
            dataSaverEnabled: currentState.dataSaverEnabled,
          ));

          // Return to original state
          emit(currentState);
        }
      }
    });

    // Direct data saver setting
    on<SetDataSaverEnabled>((event, emit) async {
      if (state is AuthenticationSuccess) {
        final currentState = state as AuthenticationSuccess;
        try {
          await _authenticationRepository.setDataSaverStatus(event.enabled);

          emit(currentState.copyWith(
            dataSaverEnabled: event.enabled,
          ));

        } catch (e) {
          // Just log the error but don't change the state
          DebugLogger.log('Error setting data saver: $e', category: 'AUTH_ERROR');
        }
      }
    });
  }
}