import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/category/subcategory_bloc.dart';
import 'package:talbna/blocs/category/subcategory_event.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/provider/language_change_notifier.dart';
import 'package:talbna/services/deep_link_service.dart';
import 'package:talbna/theme_cubit.dart';
import 'package:talbna/utils/debug_logger.dart';
import 'package:talbna/utils/fcm_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';
import 'core/app_bloc_providers.dart';
import 'core/app_repositories.dart';
import 'core/service_locator.dart';
import 'data/repositories/authentication_repository.dart';
import 'data/repositories/categories_repository.dart';
import 'data/repositories/service_post_repository.dart';
import 'first_lunch_initializer.dart';

String language = 'ar';

class AppInitializer {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final DeepLinkService deepLinkService = DeepLinkService();

  static Future<void> _loadLanguageSettings(SharedPreferences prefs) async {
    try {
      // Get saved language or use 'ar' as default
      final savedLanguage = prefs.getString('language');
      language = savedLanguage ?? 'ar';

      // Debug log
      DebugLogger.log('App initialized with language: $language', category: 'LANGUAGE');
    } catch (e) {
      DebugLogger.log('Error loading language settings: $e', category: 'LANGUAGE');
      // Fallback to default language
      language = 'ar';
    }
  }

  static Future<void> initialize() async {
    try {
      // This needs to be called first to preserve the native splash screen
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      try {
        // Initialize core services first
        await _initializeFoundationServices();

        // Set up service locator first
        await setupServiceLocator();

        // Pre-load app data in background - important for fast startup
        await preloadAppData();

        // Load app preferences
        final prefs = await SharedPreferences.getInstance();
        await _loadLanguageSettings(prefs);

        // Pre-check authentication status for cold start
        await _checkAuthForColdStart(prefs);

        // Configure system UI
        await _configureSystemUI(prefs.getBool('isDarkTheme') ?? true);

        // Request runtime permissions
        await _requestPermissions();

        // Run the application
        final repositories = await AppRepositories.initialize();
        _runApplication(prefs, repositories);

        // Now that the app UI is initialized, we can remove the splash screen
        FlutterNativeSplash.remove();
      } catch (initializationError, initializationStackTrace) {
        // Log detailed initialization errors
        debugPrint('Detailed App Initialization Error: $initializationError');
        debugPrint('Detailed Initialization Stack Trace: $initializationStackTrace');
        DebugLogger.log(
            'Detailed App Initialization Error: $initializationError\n$initializationStackTrace',
            category: 'INIT'
        );

        // Fallback: Run app with minimal configuration
        _runFallbackApplication();
      }
    } catch (fatalError, fatalStackTrace) {
      // Catch any truly unexpected errors
      debugPrint('Fatal App Initialization Error: $fatalError');
      debugPrint('Fatal Stack Trace: $fatalStackTrace');
      DebugLogger.log(
          'Fatal App Initialization Error: $fatalError\n$fatalStackTrace',
          category: 'FATAL_INIT'
      );
    } finally {
      // Ensure splash screen is removed in all scenarios
      FlutterNativeSplash.remove();
    }
  }

  static void _runFallbackApplication() {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Unable to initialize the app fully'),
                ElevatedButton(
                  onPressed: () => AppInitializer.initialize(),
                  child: const Text('Retry Initialization'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _initializeFoundationServices() async {
    await Firebase.initializeApp();

    // Initialize DeepLinkService and set the navigator key
    deepLinkService.setNavigatorKey(navigatorKey);
    await deepLinkService.initialize();

    await FCMHandler().initializeFCM();
  }

  static Future<void> _checkAuthForColdStart(SharedPreferences prefs) async {
    final String? token = prefs.getString('auth_token');
    final int? userId = prefs.getInt('userId');

    if (token == null || token.isEmpty || userId == null) {
      DebugLogger.log('No valid authentication token found', category: 'INIT');
      return;
    }

    try {
      // Initialize repositories
      final repositories = await AppRepositories.initialize();
      final authRepository = repositories.authenticationRepository;

      // Get repositories from service locator
      final categoriesRepository = serviceLocator<CategoriesRepository>();
      final servicePostRepository = serviceLocator<ServicePostRepository>();

      final firstLaunchInitializer = FirstLaunchInitializer(
        prefs: prefs,
        categoriesRepository: categoriesRepository,
        servicePostRepository: servicePostRepository,
      );

      // Perform first-time initialization if needed
      if (firstLaunchInitializer.needsInitialization()) {
        await _performFirstTimeInitialization(firstLaunchInitializer);
      }

      // Validate token
      await _validateUserToken(authRepository, prefs, token, userId);
    } catch (e) {
      DebugLogger.log('Cold start authentication error: $e', category: 'INIT_ERROR');
    }
  }

  static Future<void> _performFirstTimeInitialization(FirstLaunchInitializer initializer) async {
    try {
      await initializer.initializeAppData();
    } catch (e) {
      DebugLogger.log('First launch initialization failed: $e', category: 'INIT_ERROR');
      await initializer.resetInitializationState();
    }
  }

  static Future<void> _validateUserToken(
      AuthenticationRepository authRepository,
      SharedPreferences prefs,
      String token,
      int userId
      ) async {
    final bool isValid = await authRepository.checkTokenValidity(token);

    if (isValid) {
      DebugLogger.log('Token is valid, pre-authenticating', category: 'INIT');
      deepLinkService.setPreAuthenticated(userId);
    } else {
      DebugLogger.log('Token is invalid, clearing credentials', category: 'INIT');
      await prefs.remove('auth_token');
      await prefs.remove('userId');
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
    try {
      // Only request essential permissions at startup
      // We'll request other permissions only when needed in specific features
      await Permission.notification.request();

      // Log the change in approach
      DebugLogger.log('Only requesting notification permissions at startup. Other permissions will be requested when needed.', category: 'PERMISSIONS');
    } catch (e) {
      debugPrint('Permission Request Error: $e');
      DebugLogger.log('Permission Request Error: $e', category: 'PERMISSIONS');
    }
  }

  // Navigation guard with a shorter time window
  static final Map<String, DateTime> _recentNavigations = {};

  static bool shouldAllowNavigation(String route) {
    // For service post routes, use a specific check based on post ID
    if (route.contains('service-post')) {
      final routeParts = route.split('/');
      final postId = routeParts.last;
      final routeKey = 'service-post-$postId';

      // Much shorter threshold for service posts - only 500ms
      const int servicePostThrottleMs = 500;
      final now = DateTime.now();

      final lastNavigation = _recentNavigations[routeKey];
      if (lastNavigation != null &&
          now.difference(lastNavigation).inMilliseconds < servicePostThrottleMs) {
        DebugLogger.log(
            'Navigation guard: blocking duplicate service post navigation to $routeKey',
            category: 'NAVIGATION'
        );
        return false;
      }

      _recentNavigations[routeKey] = now;
      return true;
    }

    // For other routes, use the original logic but with reduced threshold
    const int navigationThrottleMs = 600; // Reduced from 800ms
    const int maxNavigationEntries = 20;
    const int navigationCleanupSeconds = 5;

    final now = DateTime.now();
    final routeKey = route.split('?').first;

    // Check for recent navigation to same route
    final lastNavigation = _recentNavigations[routeKey];
    if (lastNavigation != null &&
        now.difference(lastNavigation).inMilliseconds < navigationThrottleMs) {
      DebugLogger.log(
          'Navigation guard: blocking duplicate navigation to $routeKey',
          category: 'NAVIGATION'
      );
      return false;
    }

    // Record and clean up navigation entries
    _recentNavigations[routeKey] = now;
    _cleanupRecentNavigations(
        maxEntries: maxNavigationEntries,
        maxAge: navigationCleanupSeconds
    );

    return true;
  }

  static void _cleanupRecentNavigations({
    int maxEntries = 20,
    int maxAge = 5
  }) {
    if (_recentNavigations.length > maxEntries) {
      final now = DateTime.now();
      _recentNavigations.removeWhere((_, timestamp) =>
      now.difference(timestamp).inSeconds > maxAge
      );
    }
  }

  static Future<void> preloadAppData() async {
    try {
      final stopwatch = Stopwatch()..start();
      DebugLogger.log('Starting app data preload', category: 'INIT');

      // Get repositories from service locator
      final categoriesRepository = serviceLocator<CategoriesRepository>();

      // Preload categories in background
      categoriesRepository.getCategories(forceRefresh: false).then((categories) {
        DebugLogger.log('Preloaded ${categories.length} categories', category: 'INIT');
      }).catchError((e) {
        DebugLogger.log('Error preloading categories: $e', category: 'INIT_ERROR');
      });

      // Preload category menu in background
      categoriesRepository.getCategoryMenu(forceRefresh: false).then((categoryMenu) {
        DebugLogger.log('Preloaded ${categoryMenu.length} category menu items', category: 'INIT');
      }).catchError((e) {
        DebugLogger.log('Error preloading category menu: $e', category: 'INIT_ERROR');
      });


      stopwatch.stop();
      DebugLogger.log('App data preload initiated in ${stopwatch.elapsedMilliseconds}ms',
          category: 'INIT');
    } catch (e) {
      DebugLogger.log('Error in preloadAppData: $e', category: 'INIT_ERROR');
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

              // Initialize caches for faster loading
              _initializeBlocCaches(context);

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

  // Initialize bloc caches early to avoid showing loading screens unnecessarily
  static void _initializeBlocCaches(BuildContext context) {
    try {
      // Initialize service post cache
      final servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
      servicePostBloc.add(const InitializeCachesEvent());

      // Initialize category/subcategory cache
      final subcategoryBloc = BlocProvider.of<SubcategoryBloc>(context);
      subcategoryBloc.add( InitializeSubcategoryCache());

      DebugLogger.log('Initialized bloc caches', category: 'INIT');
    } catch (e) {
      DebugLogger.log('Error initializing bloc caches: $e', category: 'INIT_ERROR');
    }
  }
}
Future<void> main() async {
  // Set up dependency injection first
  await AppInitializer.initialize();
}

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: LanguageChangeBuilder(
        builder: (context) => child,
      ),
    );
  }
}