import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/services/deep_link_service.dart';
import 'package:talbna/utils/debug_logger.dart';
import 'package:talbna/utils/fcm_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';
import 'core/app_bloc_providers.dart';
import 'core/app_repositories.dart';

String language = 'ar';

class AppInitializer {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final DeepLinkService deepLinkService = DeepLinkService();

  static Future<void> initialize() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize core services first
      await _initializeFoundationServices();

      // Load app preferences
      final prefs = await SharedPreferences.getInstance();

      // Pre-check authentication status for cold start
      await _checkAuthForColdStart(prefs);

      // Configure system UI
      await _configureSystemUI(prefs.getBool('isDarkTheme') ?? true);

      // Request runtime permissions
      await _requestPermissions();

      // Run the application
      final repositories = AppRepositories.initialize();
      _runApplication(prefs, repositories);
    } catch (e, stackTrace) {
      debugPrint('App Initialization Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      DebugLogger.log('App Initialization Error: $e\n$stackTrace', category: 'INIT');
    }
  }

  static Future<void> _initializeFoundationServices() async {
    await Firebase.initializeApp();

    // Initialize DeepLinkService and set the navigator key
    deepLinkService.setNavigatorKey(navigatorKey);
    await deepLinkService.initialize();

    await FCMHandler().initializeFCM();
  }

  // Check authentication for cold start with deep links
  static Future<void> _checkAuthForColdStart(SharedPreferences prefs) async {
    final String? token = prefs.getString('auth_token');
    final int? userId = prefs.getInt('userId');

    if (token != null && token.isNotEmpty && userId != null) {
      DebugLogger.log('Found stored token for cold start: userId=$userId', category: 'INIT');

      try {
        // Initialize repositories to check token
        final repositories = AppRepositories.initialize();
        final authRepository = repositories.authenticationRepository;

        // Validate token
        final bool isValid = await authRepository.checkTokenValidity(token);

        if (isValid) {
          DebugLogger.log('Token is valid for cold start, pre-authenticating', category: 'INIT');
          // Tell DeepLinkService we're pre-authenticated for deep link handling
          deepLinkService.setPreAuthenticated(userId);
        } else {
          DebugLogger.log('Token is invalid, clearing stored credentials', category: 'INIT');
          await prefs.remove('auth_token');
          await prefs.remove('userId');
        }
      } catch (e) {
        DebugLogger.log('Error validating token: $e', category: 'INIT');
      }
    } else {
      DebugLogger.log('No stored token found for cold start', category: 'INIT');
    }
  }

  static Future<void> _configureSystemUI(bool isDarkTheme) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final brightness = isDarkTheme ? Brightness.dark : Brightness.light;
    AppTheme.setSystemBarColors(
      brightness,
      isDarkTheme ? AppTheme.darkPrimaryColor : AppTheme.lightPrimaryColor,
      isDarkTheme ? AppTheme.darkPrimaryColor : AppTheme.lightPrimaryColor,
    );

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: isDarkTheme ? AppTheme.darkPrimaryColor : AppTheme.lightPrimaryColor,
      systemNavigationBarIconBrightness: isDarkTheme ? Brightness.light : Brightness.dark,
    ));
  }

  static Future<void> _requestPermissions() async {
    final permissions = [
      Permission.location,
      Permission.storage,
      Permission.photos,
      Permission.contacts,
      Permission.camera,
      Permission.notification,
    ];

    try {
      // Request permissions one by one with small delay to avoid concurrent request issues
      for (var permission in permissions) {
        await permission.request();
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      debugPrint('Permission Request Error: $e');
      DebugLogger.log('Permission Request Error: $e', category: 'PERMISSIONS');
    }
  }

  // Navigation guard with a shorter time window
  static final Map<String, DateTime> _recentNavigations = {};

  static bool shouldAllowNavigation(String route) {
    final now = DateTime.now();
    final routeKey = route.split('?').first; // Remove query params for comparison

    if (_recentNavigations.containsKey(routeKey)) {
      final lastNavigation = _recentNavigations[routeKey]!;
      if (now.difference(lastNavigation).inMilliseconds < 800) {
        DebugLogger.log('Navigation guard: blocking duplicate navigation to $routeKey',
            category: 'NAVIGATION');
        return false;
      }
    }

    // Allow this navigation and record it
    _recentNavigations[routeKey] = now;
    _cleanupRecentNavigations();
    return true;
  }

  static void _cleanupRecentNavigations() {
    if (_recentNavigations.length > 20) {
      final now = DateTime.now();
      _recentNavigations.removeWhere((_, timestamp) =>
      now.difference(timestamp).inSeconds > 5);
    }
  }

  static void _runApplication(SharedPreferences prefs, AppRepositories repositories) {
    final isDarkTheme = prefs.getBool('isDarkTheme') ?? true;

    // Get the initial token for auto-login
    final String? token = prefs.getString('auth_token');
    final int? userId = prefs.getInt('userId');
    final bool hasValidToken = token != null && token.isNotEmpty && userId != null;

    final appBlocProviders = AppBlocProviders.getProviders(repositories);

    runApp(
      MultiBlocProvider(
        providers: appBlocProviders,
        child: Builder(
            builder: (context) {
              // Auto-login if we have a valid token
              if (hasValidToken) {
                DebugLogger.log('Auto-logging in with token: $token', category: 'INIT');
                // Dispatch login event to the authentication bloc
                BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn(token: token));
              }

              return MyApp(
                authenticationRepository: repositories.authenticationRepository,
                isDarkTheme: isDarkTheme,
                navigatorKey: navigatorKey,
                autoAuthenticated: hasValidToken,
              );
            }
        ),
      ),
    );
  }
}

Future<void> main() async {
  await AppInitializer.initialize();
}