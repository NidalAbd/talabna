import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/data/repositories/authentication_repository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;

  AuthenticationBloc(
      {required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(AuthenticationInitial()) {
    print('AuthenticationBloc created: $hashCode');

    // Register the event handlers for LoginRequest and Register events
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
        print(userId);
        print(token);

        emit(AuthenticationSuccess(userId: userId, token: token));
      } catch (e) {
        print(e);

        emit(AuthenticationFailure(error: e.toString()));
      }
    });

    on<GoogleSignInRequest>((event, emit) async {
      emit(AuthenticationInProgress());
      try {
        final result = await _authenticationRepository.signInWithGoogle();
        final userId = result['id'];
        final token = result['token'];
        print('result');
        print(result);
        emit(AuthenticationSuccess(userId: userId, token: token));
      } catch (e) {
        print(e);
        emit(AuthenticationFailure(error: e.toString()));
      }
    });
    on<LoggedIn>((event, emit) async {
      emit(AuthenticationInProgress());
      try {
        final token = await _authenticationRepository.getAuthToken();
        final userId = await _authenticationRepository.getUserId(); // Assuming you pass userId in LoggedIn event
        emit(AuthenticationSuccess(userId: userId, token: token));
      } catch (e) {
        print(e);

        emit(AuthenticationFailure(error: e.toString()));
      }
    });

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
        print(userId);
        print(userId);
        emit(AuthenticationSuccess(userId: userId, token: token));
      } catch (e) {
        emit(AuthenticationFailure(error: e.toString()));
      }
    });

    on<LoggedOut>((event, emit) async {
      // register a handler for LoggedOut event
      await _authenticationRepository.removeAuthToken();
      emit(AuthenticationInitial());
    });

    on<ForgotPassword>((event, emit) async {
      emit(AuthenticationInProgress());
      try {
        emit(ForgotPasswordSuccess(
            message: "Password reset link sent successfully."));
        await _authenticationRepository.resetPassword(email: event.email);
      } catch (e) {
        emit(AuthenticationFailure(error: e.toString()));
      }
    });
  }

  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      final bool hasToken =
          (await _authenticationRepository.getAuthToken()) as bool;
      if (hasToken) {
        final String? token = await _authenticationRepository.getAuthToken();
        final userId = await _authenticationRepository.getUserId(); // Assuming you pass userId in LoggedIn event
        emit(AuthenticationSuccess(userId: userId, token: token));
      } else {
        yield AuthenticationInitial();
      }
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState(event);
    } else if (event is LoginRequest) {
      yield* _mapLoginRequestInToState(event);
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    } else if (event is Register) {
      yield* _mapRegisterToState(event);
    } else if (event is ForgotPassword) {
      yield* _mapForgotPasswordToState(event);
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _authenticationRepository.isSignedIn();
      if (isSignedIn) {
        final token = await _authenticationRepository.getAuthToken();
        final userId = await _authenticationRepository.getUserId(); // Assuming you pass userId in LoggedIn event
        emit(AuthenticationSuccess(userId: userId, token: token));
      } else {
        yield AuthenticationInitial();
      }
    } catch (e) {
      yield AuthenticationFailure(error: e.toString());
    }
  }

  Stream<AuthenticationState> _mapLoginRequestInToState(
    LoginRequest event,
  ) async* {
    yield AuthenticationInProgress();
    try {
      await _authenticationRepository.login(
        authProvider: 'email',
        email: event.email,
        password: event.password,
      );
      final String? token = await _authenticationRepository.getAuthToken();
      final userId = await _authenticationRepository.getUserId(); // Assuming you pass userId in LoggedIn event
      emit(AuthenticationSuccess(userId: userId, token: token));
    } catch (e) {
      yield AuthenticationFailure(error: e.toString());
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState(
    LoggedIn event,
  ) async* {
    yield AuthenticationInProgress();
    try {
      await _authenticationRepository.saveAuthToken(event.token);
      final userId = await _authenticationRepository.getUserId(); // Assuming you pass userId in LoggedIn event
      yield AuthenticationSuccess(token: event.token, userId: userId);
    } catch (e) {
      yield AuthenticationFailure(error: e.toString());
    }
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield AuthenticationInProgress();
    try {
      await _authenticationRepository.removeAuthToken();
      yield AuthenticationInitial();
    } catch (e) {
      yield AuthenticationFailure(error: e.toString());
    }
  }

  Stream<AuthenticationState> _mapRegisterToState(
      Register event,
      ) async* {
    yield AuthenticationInProgress();
    try {
      final result = await _authenticationRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        authProvider: 'email',
      );
      final userId = result['user_id'];
      final token = result['token'];
      await _authenticationRepository.saveAuthToken(token!);
      yield AuthenticationSuccess(userId: userId, token: token);
    } catch (e) {
      yield AuthenticationFailure(error: e.toString());
    }
  }


  Stream<AuthenticationState> _mapForgotPasswordToState(
    ForgotPassword event,
  ) async* {
    yield AuthenticationInProgress();
    try {
      await _authenticationRepository.resetPassword(email: event.email);
      yield ForgotPasswordSuccess(
          message: "Password reset link sent successfully.");
    } catch (e) {
      yield AuthenticationFailure(error: e.toString());
    }
  }
}
