import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/routes.dart';
import 'package:talbna/screens/auth/login_screen_new.dart';
import 'package:talbna/screens/auth/welcome_screen.dart';
import 'package:talbna/screens/home/home_screen.dart';
import 'package:talbna/screens/home/select_language.dart';
import 'package:talbna/screens/splash.dart';
import 'package:talbna/screens/widgets/success_widget.dart';
import 'package:talbna/services/deep_link_service.dart';
import 'package:talbna/theme_cubit.dart';
import 'package:talbna/utils/constants.dart';
import 'package:talbna/utils/debug_logger.dart';
import 'package:talbna/utils/fcm_handler.dart';
import 'blocs/authentication/authentication_bloc.dart';
import 'blocs/authentication/authentication_event.dart';
import 'blocs/authentication/authentication_state.dart';
import 'data/repositories/authentication_repository.dart';

class MyApp extends StatefulWidget {
  final AuthenticationRepository authenticationRepository;
  final bool isDarkTheme;
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    super.key,
    required this.authenticationRepository,
    required this.isDarkTheme,
    required this.navigatorKey,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FCMHandler _fcmHandler = FCMHandler();
  final DeepLinkService _deepLinkService = DeepLinkService();
  bool _isInitialized = false;
  bool _appReadyNotified = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app comes to foreground, check for pending deep links
    if (state == AppLifecycleState.resumed && _appReadyNotified) {
      DebugLogger.log('App resumed from background, checking pending links', category: 'APP');
      // Add a small delay to ensure app is fully visible
      Future.delayed(const Duration(milliseconds: 500), () {
        _deepLinkService.checkPendingDeepLinks();
      });
    }
  }

  Future<void> _initializeApp() async {
    await _fcmHandler.initializeFCM();
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  void _notifyAppReady() {
    // Only notify app ready once
    if (_appReadyNotified) {
      DebugLogger.log('App already marked as ready, skipping duplicate notification', category: 'APP');
      return;
    }

    _appReadyNotified = true;
    DebugLogger.log('Notifying DeepLinkService that app is ready', category: 'APP');

    // Signal to the DeepLinkService that the app is ready to handle deep links
    // Use a longer delay to ensure home screen is fully loaded and stable
    Future.delayed(const Duration(milliseconds: 1000), () {
      DeepLinkService().setAppReady();
    });
  }

  Widget _buildScreenForState(AuthenticationState state, SharedPreferences prefs) {
    if (!_isInitialized) return const SplashScreen();

    final String? token = prefs.getString('auth_token');
    final int? userId = prefs.getInt('userId');
    final isFirstTime = prefs.getBool('is_first_time') ?? true;

    if (state is AuthenticationSuccess) {
      // Notify the deep link service that authentication is complete after a small delay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyAppReady();
      });
      return HomeScreen(userId: state.userId!);
    }

    if (isFirstTime) return const WelcomeScreen();

    if (token != null && token.isNotEmpty && userId != null) {
      return FutureBuilder<bool>(
        future: widget.authenticationRepository.checkTokenValidity(token),
        builder: (context, validitySnapshot) {
          if (!validitySnapshot.hasData) return const SplashScreen();

          if (validitySnapshot.data!) {
            if (state is! AuthenticationSuccess) {
              BlocProvider.of<AuthenticationBloc>(context)
                  .add(LoggedIn(token: token));
            }
            return const SplashScreen();
          }

          return const LoginScreenNew();
        },
      );
    }

    return const LoginScreenNew();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: Constants.appName,
            theme: theme,
            navigatorKey: widget.navigatorKey,
            onGenerateRoute: Routes.generateRoute,
            initialRoute: Routes.initial,
            home: FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SplashScreen();

                final prefs = snapshot.data!;
                final isFirstTime = prefs.getBool('is_first_time') ?? true;

                return BlocConsumer<AuthenticationBloc, AuthenticationState>(
                  listenWhen: (previous, current) => current is AuthenticationSuccess,
                  listener: (context, state) {
                    if (state is AuthenticationSuccess) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showCustomSnackBar(
                            context,
                            'Successfully authenticated',
                            type: SnackBarType.success
                        );
                        Routes.navigateToHome(context, state.userId!);

                        // Allow some time for navigation to complete, then notify app is ready
                        Future.delayed(const Duration(milliseconds: 800), () {
                          _notifyAppReady();
                        });
                      });
                    }
                  },
                  builder: (context, state) {
                    if (isFirstTime) return const LanguageSelectionScreen();

                    return _buildScreenForState(state, prefs);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}