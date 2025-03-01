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

  // Currently active navigation - prevents multiple navigations in progress
  bool _isNavigating = false;
  String? _currentlyNavigatingTo;

  // Store rejected/pending links to avoid lost clicks
  final Set<String> _processedUris = {};

  // Set app ready state - called after home screen is loaded
  void setAppReady() {
    if (_isAppReady) {
      DebugLogger.log('App already marked as ready, ignoring duplicate call', category: 'DEEPLINK');
      return;
    }

    DebugLogger.log('Setting app ready state = true', category: 'DEEPLINK');
    _isAppReady = true;

    // Delayed processing of pending links to ensure app is stable
    Future.delayed(const Duration(milliseconds: 800), () {
      _processPendingDeepLinks();
    });
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // Handle initial deep link on app launch - but store it, don't process yet
      final initialLink = await getInitialUri();
      if (initialLink != null) {
        final uriString = initialLink.toString();
        DebugLogger.log('Initial deep link received: $uriString', category: 'DEEPLINK');
        await storePendingDeepLink(_parseRoute(initialLink), _parseId(initialLink));
      }

      // Listen for runtime deep links - but don't process immediately
      _uriSubscription = uriLinkStream.listen(
            (Uri? uri) {
          if (uri != null) {
            final uriString = uri.toString();
            if (_processedUris.contains(uriString)) {
              DebugLogger.log('Ignoring already processed URI: $uriString', category: 'DEEPLINK');
              return;
            }

            _processedUris.add(uriString);
            DebugLogger.log('Runtime deep link received: $uriString', category: 'DEEPLINK');

            // Always store, only process if ready
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
    _processedUris.clear();
  }

  // Helper methods to parse URI components
  String? _parseRoute(Uri uri) {
    final pathSegments = uri.pathSegments;

    if (uri.scheme == 'talabna') {
      if (pathSegments.isNotEmpty) {
        if (pathSegments[0] == 'service-post') {
          return 'service-post';
        } else if (_isValidNumericId(pathSegments[0])) {
          return 'service-post';  // Default to service-post for numeric IDs
        }
      }
    }

    return null;
  }

  String? _parseId(Uri uri) {
    final pathSegments = uri.pathSegments;

    if (uri.scheme == 'talabna') {
      if (pathSegments.isNotEmpty) {
        if (pathSegments.length >= 2 && pathSegments[0] == 'service-post') {
          return pathSegments[1];
        } else if (_isValidNumericId(pathSegments[0])) {
          return pathSegments[0];
        }
      }
    }

    return null;
  }

  // Validate numeric ID
  bool _isValidNumericId(String segment) {
    return int.tryParse(segment) != null && int.parse(segment) > 0;
  }

  // Handle deep link navigation with authentication check - SIMPLIFIED
  Future<void> _handleDeepLinkNavigation(String route, String id) async {
    // Prevent concurrent navigation attempts
    if (_isNavigating) {
      DebugLogger.log('Navigation already in progress to $_currentlyNavigatingTo - skipping',
          category: 'DEEPLINK');
      return;
    }

    // Mark as navigating
    _isNavigating = true;
    _currentlyNavigatingTo = '$route/$id';
    DebugLogger.log('Starting navigation to: $_currentlyNavigatingTo', category: 'DEEPLINK');

    try {
      // Check if navigation context is available
      if (_navigatorKey.currentContext == null) {
        DebugLogger.log('No navigation context available', category: 'DEEPLINK');
        return;
      }

      // Get authentication state
      final authBloc = _navigatorKey.currentContext!.read<AuthenticationBloc>();
      final authState = authBloc.state;

      if (route == 'service-post') {
        if (authState is AuthenticationSuccess) {
          DebugLogger.log('Navigating to service post: $id', category: 'DEEPLINK');

          // Navigate with proper context
          _navigatorKey.currentState?.pushNamed(
              Routes.servicePost,
              arguments: {'postId': id}
          );
        } else {
          DebugLogger.log('User not authenticated, redirecting to login', category: 'DEEPLINK');
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

  // Process any pending deep links - SIMPLIFIED
  Future<void> _processPendingDeepLinks() async {
    // Don't process if app not ready or another navigation in progress
    if (!_isAppReady || _isNavigating) {
      DebugLogger.log('App not ready or navigation in progress - deferring deep link processing',
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
    if (_isAppReady && !_isNavigating) {
      await _processPendingDeepLinks();
    } else {
      DebugLogger.log('App not ready or navigation in progress - skipping manual check',
          category: 'DEEPLINK');
    }
  }
}