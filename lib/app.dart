import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/routes.dart';
import 'package:talbna/screens/auth/welcome_screen.dart';
import 'package:talbna/screens/home/home_screen.dart';
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
import 'widgets/splash_transition.dart'; // Import the new transition widget

class MyApp extends StatefulWidget {
  final AuthenticationRepository authenticationRepository;
  final bool isDarkTheme;
  final GlobalKey<NavigatorState> navigatorKey;
  final bool autoAuthenticated;

  const MyApp({
    super.key,
    required this.authenticationRepository,
    required this.isDarkTheme,
    required this.navigatorKey,
    this.autoAuthenticated = false,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FCMHandler _fcmHandler = FCMHandler();
  final DeepLinkService _deepLinkService = DeepLinkService();
  bool _isInitialized = false;
  bool _appReadyNotified = false;
  bool _hasCheckedDeepLinksAfterAuth = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();

    // If we're already auto-authenticated, notify app ready sooner
    if (widget.autoAuthenticated) {
      DebugLogger.log('Auto-authenticated, will check deep links soon', category: 'APP');
      Future.delayed(const Duration(milliseconds: 1000), () {
        _notifyAppReady();
      });
    }
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
    // Shorter delay as the native splash screen is already showing
    await Future.delayed(const Duration(milliseconds: 200));

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
    DeepLinkService().setAppReady();

    // Check for pending deep links
    DeepLinkService().checkPendingDeepLinks();
  }

  Widget _buildScreenForState(BuildContext context, AuthenticationState state, SharedPreferences prefs) {
    final String? token = prefs.getString('auth_token');
    final int? userId = prefs.getInt('userId');
    final bool isFirstTime = prefs.getBool('is_first_time') ?? true;

    // Handle successful authentication
    if (state is AuthenticationSuccess) {
      // Check if we need to process deep links after authentication
      if (!_hasCheckedDeepLinksAfterAuth) {
        _hasCheckedDeepLinksAfterAuth = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _notifyAppReady();
          });
        });
      }

      // Use transition for HomeScreen
      return AppLoadingTransition(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: HomeScreen(userId: state.userId!),
      );
    }

    // If has token, verify it and use it
    if (token != null && token.isNotEmpty && userId != null) {
      return FutureBuilder<bool>(
        future: widget.authenticationRepository.checkTokenValidity(token),
        builder: (context, validitySnapshot) {
          if (!validitySnapshot.hasData) {
            // Show nothing during this check, maintaining splash screen look
            return Container(color: Theme.of(context).scaffoldBackgroundColor);
          }

          if (validitySnapshot.data!) {
            if (state is! AuthenticationSuccess) {
              BlocProvider.of<AuthenticationBloc>(context)
                  .add(LoggedIn(token: token));

              // If token is valid, notify the deep link service
              _deepLinkService.setPreAuthenticated(userId);
            }

            // Show nothing during authentication, maintaining splash screen look
            return Container(color: Theme.of(context).scaffoldBackgroundColor);
          }

          // Token is invalid, show welcome screen with transition
          return AppLoadingTransition(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: const WelcomeScreen(),
          );
        },
      );
    }

    // No authentication, show welcome screen with transition
    return AppLoadingTransition(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: const WelcomeScreen(),
    );
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
            home: !_isInitialized
            // Show nothing during initialization, preserving splash screen
                ? Container(color: theme.scaffoldBackgroundColor)
                : FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  // Show nothing during prefs loading, preserving splash screen
                  return Container(color: theme.scaffoldBackgroundColor);
                }

                final prefs = snapshot.data!;
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

                        // Check for pending deep links BEFORE navigating to home
                        _deepLinkService.checkPendingDeepLinks().then((_) {
                          // Only navigate to home if not already handling a deep link
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (Navigator.of(context).canPop()) {
                              // If we can pop, we're already on a screen (probably from deep link)
                              // so don't navigate to home
                              DebugLogger.log('Already on a screen, not navigating to home', category: 'APP');
                              _notifyAppReady();
                            } else {
                              // Otherwise go to home screen
                              Routes.navigateToHome(context, state.userId!);

                              // After navigation, mark app as ready
                              Future.delayed(const Duration(milliseconds: 800), () {
                                _notifyAppReady();
                              });
                            }
                          });
                        });
                      });
                    }
                  },
                  builder: (context, state) {
                    return _buildScreenForState(context, state, prefs);
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