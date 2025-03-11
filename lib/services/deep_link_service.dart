import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/routes.dart';
import 'package:talbna/utils/debug_logger.dart';

class DeepLinkService {
  // Singleton pattern
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();
  static const String CONTENT_TYPE_REELS = 'reels';
  static const String CONTENT_TYPE_POST = 'service-post';

  // Reference to navigator key
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Set the navigator key
  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  // Initialization and cleanup
  StreamSubscription? _uriSubscription;
  bool _isInitialized = false;
  bool _isAppReady = false;

  // Navigation state tracking
  bool _isNavigating = false;
  String? _currentlyNavigatingTo;
  DateTime? _lastNavigationTime;

  // Authentication state for cold starts
  bool _isPreAuthenticated = false;
  int? _preAuthenticatedUserId;

  // Store processed URIs to avoid duplicates
  final Set<String> _processedUris = {};

  // Methods for pre-authenticated state handling
  // This is called when the app validates the token during cold start
  void setPreAuthenticated(int userId) {
    _isPreAuthenticated = true;
    _preAuthenticatedUserId = userId;
    DebugLogger.log('DeepLinkService: Pre-authenticated with userId: $userId',
        category: 'DEEPLINK');

    // Check for pending links immediately after pre-authentication
    Future.delayed(const Duration(milliseconds: 500), () {
      checkPendingDeepLinks();
    });
  }

  // Set app ready state - called after home screen is loaded
  void setAppReady() {
    if (_isAppReady) {
      DebugLogger.log('App already marked as ready, ignoring duplicate call', category: 'DEEPLINK');
      return;
    }

    DebugLogger.log('Setting app ready state = true', category: 'DEEPLINK');
    _isAppReady = true;

    // Process pending deep links after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _processPendingDeepLinks();
    });
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // Handle initial deep link on app launch
      final initialLink = await getInitialUri();
      if (initialLink != null) {
        final uriString = initialLink.toString();
        DebugLogger.log('Initial deep link received: $uriString', category: 'DEEPLINK');

        // Store deep link and mark as processed
        _processedUris.add(uriString);
        await storePendingDeepLink(_parseRoute(initialLink), _parseId(initialLink));
      }

      // Listen for runtime deep links
      _uriSubscription = uriLinkStream.listen(
            (Uri? uri) {
          if (uri != null) {
            final uriString = uri.toString();

            // Skip if already processed
            if (_processedUris.contains(uriString)) {
              DebugLogger.log('Ignoring already processed URI: $uriString', category: 'DEEPLINK');
              return;
            }

            DebugLogger.log('Runtime deep link received: $uriString', category: 'DEEPLINK');
            _processedUris.add(uriString);

            // Store and process based on app state
            storePendingDeepLink(_parseRoute(uri), _parseId(uri));

            if (_isAppReady && !_isNavigating) {
              // Delay slightly to avoid race conditions
              Future.delayed(const Duration(milliseconds: 300), () {
                _processPendingDeepLinks();
              });
            }
          }
        },
        onError: (err) {
          DebugLogger.log('Deep Link Error: $err', category: 'DEEPLINK');
        },
      );
    } on PlatformException catch (e) {
      DebugLogger.log('Platform Exception in Deep Link: ${e.message}', category: 'DEEPLINK');
    }
  }

  void dispose() {
    _uriSubscription?.cancel();
    _isInitialized = false;
    _isAppReady = false;
    _isPreAuthenticated = false;
    _preAuthenticatedUserId = null;
    _processedUris.clear();
  }

  // Check if navigation is allowed
  bool _canNavigate() {
    if (_isNavigating) {
      DebugLogger.log('Navigation already in progress - skipping', category: 'DEEPLINK');
      return false;
    }

    if (_lastNavigationTime != null) {
      final now = DateTime.now();
      final diff = now.difference(_lastNavigationTime!).inMilliseconds;
      if (diff < 1000) {
        DebugLogger.log('Last navigation was too recent ($diff ms) - skipping', category: 'DEEPLINK');
        return false;
      }
    }

    return true;
  }

  String? _parseRoute(Uri uri) {
    final pathSegments = uri.pathSegments;
    final contentType = _parseContentType(uri);

    // Handle talabna:// scheme
    if (uri.scheme == 'talabna') {
      if (pathSegments.isNotEmpty) {
        if (pathSegments[0] == 'reels' || pathSegments[0] == 'service-post') {
          return pathSegments[0]; // Return the actual route type
        } else if (_isValidNumericId(pathSegments[0])) {
          // Default numeric IDs to service-post for backward compatibility
          return CONTENT_TYPE_POST;
        }
      }
    }
    // Handle https://talbna.cloud/api/deep-link/TYPE/ID format
    else if (uri.host == 'talbna.cloud' && pathSegments.length >= 4) {
      if (pathSegments[0] == 'api' && pathSegments[1] == 'deep-link') {
        if (pathSegments[2] == 'reels' || pathSegments[2] == 'service-post') {
          return pathSegments[2];
        }
      }
    }
    // Handle https://talbna.cloud/api/service_posts/ID format (legacy)
    else if (uri.host == 'talbna.cloud' && pathSegments.length >= 3) {
      if (pathSegments[0] == 'api' &&
          pathSegments[1] == 'service_posts' &&
          _isValidNumericId(pathSegments[2])) {
        return CONTENT_TYPE_POST; // Default to post view
      }
    }

    return null;
  }

  // Helper method to specifically extract content type
  String? _parseContentType(Uri uri) {
    final pathSegments = uri.pathSegments;

    // Handle talabna:// scheme
    if (uri.scheme == 'talabna') {
      if (pathSegments.isNotEmpty) {
        if (pathSegments[0] == 'reels') {
          return CONTENT_TYPE_REELS;
        } else if (pathSegments[0] == 'service-post') {
          return CONTENT_TYPE_POST;
        } else if (_isValidNumericId(pathSegments[0])) {
          return CONTENT_TYPE_POST; // Default
        }
      }
    }
    // Handle https://talbna.cloud/api/deep-link/TYPE/ID format
    else if (uri.host == 'talbna.cloud' && pathSegments.length >= 4) {
      if (pathSegments[0] == 'api' && pathSegments[1] == 'deep-link') {
        if (pathSegments[2] == 'reels') {
          return CONTENT_TYPE_REELS;
        } else if (pathSegments[2] == 'service-post') {
          return CONTENT_TYPE_POST;
        }
      }
    }
    // Handle https://talbna.cloud/api/service_posts/ID format (legacy)
    else if (uri.host == 'talbna.cloud' && pathSegments.length >= 3) {
      if (pathSegments[0] == 'api' && pathSegments[1] == 'service_posts') {
        return CONTENT_TYPE_POST;
      }
    }

    return CONTENT_TYPE_POST; // Default to post view for backward compatibility
  }

  String? _parseId(Uri uri) {
    final pathSegments = uri.pathSegments;

    // Handle talabna:// scheme
    if (uri.scheme == 'talabna') {
      if (pathSegments.isNotEmpty) {
        if (pathSegments.length >= 2 &&
            (pathSegments[0] == 'reels' || pathSegments[0] == 'service-post')) {
          return pathSegments[1];
        } else if (_isValidNumericId(pathSegments[0])) {
          return pathSegments[0];
        }
      }
    }
    // Handle https://talbna.cloud/api/deep-link/TYPE/ID format
    else if (uri.host == 'talbna.cloud' && pathSegments.length >= 4) {
      if (pathSegments[0] == 'api' && pathSegments[1] == 'deep-link' &&
          (pathSegments[2] == 'reels' || pathSegments[2] == 'service-post') &&
          _isValidNumericId(pathSegments[3])) {
        return pathSegments[3];
      }
    }
    // Handle https://talbna.cloud/api/service_posts/ID format (legacy)
    else if (uri.host == 'talbna.cloud' && pathSegments.length >= 3) {
      if (pathSegments[0] == 'api' && pathSegments[1] == 'service_posts' &&
          _isValidNumericId(pathSegments[2])) {
        return pathSegments[2];
      }
    }

    return null;
  }

  // Validate numeric ID
  bool _isValidNumericId(String segment) {
    return int.tryParse(segment) != null && int.parse(segment) > 0;
  }

  // Handle deep link navigation with authentication check
  Future<void> _handleDeepLinkNavigation(String route, String id) async {
    // Prevent concurrent or too-recent navigation attempts
    if (!_canNavigate()) return;

    // Mark as navigating
    _isNavigating = true;
    _currentlyNavigatingTo = '$route/$id';
    _lastNavigationTime = DateTime.now();
    DebugLogger.log('Starting navigation to: $_currentlyNavigatingTo', category: 'DEEPLINK');


    try {
      // Check if navigation context is available
      if (_navigatorKey.currentContext == null) {
        DebugLogger.log('No navigation context available', category: 'DEEPLINK');
        _isNavigating = false;
        return;
      }

      // Check authentication status
      bool isAuthenticated = false;
      int? userId;

      // First try to get from BLoC if context is available
      try {
        final authBloc = _navigatorKey.currentContext!.read<AuthenticationBloc>();
        final authState = authBloc.state;

        if (authState is AuthenticationSuccess) {
          isAuthenticated = true;
          userId = authState.userId;
          DebugLogger.log('User authenticated via BLoC: $userId', category: 'DEEPLINK');
        }

        if (route == CONTENT_TYPE_REELS) {
          if (isAuthenticated && userId != null) {
            DebugLogger.log('Navigating to reels view: $id for user: $userId', category: 'DEEPLINK');

            _navigatorKey.currentState?.pushNamed(
                Routes.reels, // New route for Reels
                arguments: {'postId': id, 'userId': userId}
            );
          } else {
            // Store deep link for after login
            await storePendingDeepLink(route, id);
            _navigatorKey.currentState?.pushReplacementNamed(Routes.login);
          }
        }
        else if (route == CONTENT_TYPE_POST || route == 'service-post') {
          if (isAuthenticated && userId != null) {
            DebugLogger.log('Navigating to service post view: $id for user: $userId', category: 'DEEPLINK');

            _navigatorKey.currentState?.pushNamed(
                Routes.servicePost,
                arguments: {'postId': id}
            );
          } else {
            // Store deep link for after login
            await storePendingDeepLink(route, id);
            _navigatorKey.currentState?.pushReplacementNamed(Routes.login);
          }
        }
        else {
          DebugLogger.log('Unhandled route: $route', category: 'DEEPLINK');
        }
      }  catch (e) {
        DebugLogger.log('Deep Link Navigation Error: $e', category: 'DEEPLINK');
      } finally {
        // Reset navigation state after a delay
        Future.delayed(const Duration(seconds: 2), () {
          _isNavigating = false;
          _currentlyNavigatingTo = null;
          DebugLogger.log('Navigation lock released', category: 'DEEPLINK');
        });
      }

      // If not authenticated via BLoC, check if pre-authenticated
      if (!isAuthenticated && _isPreAuthenticated && _preAuthenticatedUserId != null) {
        isAuthenticated = true;
        userId = _preAuthenticatedUserId;
        DebugLogger.log('User pre-authenticated: $userId', category: 'DEEPLINK');
      }

      // If still not authenticated, check SharedPreferences
      if (!isAuthenticated) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        final storedUserId = prefs.getInt('userId');

        if (token != null && token.isNotEmpty && storedUserId != null) {
          isAuthenticated = true;
          userId = storedUserId;
          DebugLogger.log('User authenticated via SharedPreferences: $userId', category: 'DEEPLINK');
        }
      }

      // Handle navigation based on authentication
      if (route == 'service-post') {
        if (isAuthenticated && userId != null) {
          DebugLogger.log('Navigating to service post: $id for user: $userId', category: 'DEEPLINK');

          // Navigate with proper context
          _navigatorKey.currentState?.pushNamed(
              Routes.servicePost,
              arguments: {'postId': id}
          );
        } else {
          DebugLogger.log('User not authenticated, redirecting to login and storing deep link',
              category: 'DEEPLINK');
          // Store the deep link for after login
          await storePendingDeepLink(route, id);

          _navigatorKey.currentState?.pushReplacementNamed(Routes.login);
        }
      } else {
        DebugLogger.log('Unhandled route: $route', category: 'DEEPLINK');
      }
    } catch (e) {
      DebugLogger.log('Deep Link Navigation Error: $e', category: 'DEEPLINK');
    } finally {
      // Reset navigation state after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _isNavigating = false;
        _currentlyNavigatingTo = null;
        DebugLogger.log('Navigation lock released', category: 'DEEPLINK');
      });
    }
  }

  // Store pending deep link
  Future<void> storePendingDeepLink(String? route, String? id) async {
    if (route == null || id == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_deep_link_route', route);
    await prefs.setString('pending_deep_link_id', id);
    DebugLogger.log('Stored pending deep link: $route/$id', category: 'DEEPLINK');
  }


  // Clear pending deep links
  Future<void> clearPendingDeepLinks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_deep_link_route');
    await prefs.remove('pending_deep_link_id');
    DebugLogger.log('Cleared pending deep links', category: 'DEEPLINK');
  }

  // Process any pending deep links
  Future<void> _processPendingDeepLinks() async {
    if (_isNavigating) {
      DebugLogger.log('Navigation in progress - deferring deep link processing',
          category: 'DEEPLINK');
      return;
    }

    DebugLogger.log('Checking for pending deep links', category: 'DEEPLINK');

    final prefs = await SharedPreferences.getInstance();
    final pendingRoute = prefs.getString('pending_deep_link_route');
    final pendingId = prefs.getString('pending_deep_link_id');

    if (pendingRoute != null && pendingId != null) {
      DebugLogger.log('Found pending deep link: $pendingRoute/$pendingId', category: 'DEEPLINK');

      // Clear the pending deep link BEFORE processing to prevent duplicate processing
      await clearPendingDeepLinks();

      // Add a small delay to ensure the app is fully initialized
      await Future.delayed(const Duration(milliseconds: 300));

      // Handle the stored deep link
      await _handleDeepLinkNavigation(pendingRoute, pendingId);
    } else {
      DebugLogger.log('No pending deep links found', category: 'DEEPLINK');
    }
  }

  // Public method to check for pending links - used by external components
  Future<void> checkPendingDeepLinks() async {
    if (!_isNavigating) {
      await _processPendingDeepLinks();
    } else {
      DebugLogger.log('Navigation in progress - skipping manual check',
          category: 'DEEPLINK');
    }
  }
}