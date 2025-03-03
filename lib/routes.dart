import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/screens/auth/login_screen_new.dart';
import 'package:talbna/screens/auth/register_screen_new.dart';
import 'package:talbna/screens/auth/reset_password.dart';
import 'package:talbna/screens/home/home_screen.dart';
import 'package:talbna/screens/home/select_language.dart';
import 'package:talbna/screens/service_post/service_post_view.dart';
import 'package:talbna/utils/debug_logger.dart';
import 'package:talbna/services/deep_link_service.dart';


class Routes {
  // Centralized route names
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String language = '/language';
  static const String resetPassword = '/reset-password';
  static const String servicePost = '/service-post';

  // Global navigation tracking to prevent duplicate service post loads
  static final Map<String, DateTime> _navigationHistory = {};
  static bool _isCurrentlyLoadingServicePost = false;

  // Route generation method with enhanced logging and error handling
  static Route<dynamic> generateRoute(RouteSettings settings) {
    DebugLogger.log('Routing to: ${settings.name}', category: 'NAVIGATION');

    final args = settings.arguments as Map<String, dynamic>?;
    _logRouteArguments(args);

    try {
      // Handle direct URL schemes
      if (settings.name != null) {
        // Direct numeric ID handling
        if (settings.name!.startsWith('/') && _isNumeric(settings.name!.substring(1))) {
          final postId = settings.name!.substring(1);
          DebugLogger.log('Detected direct post ID navigation: $postId', category: 'NAVIGATION');
          return _handleServicePostRoute({'postId': postId});
        }

        // Talabna scheme handling
        if (settings.name!.startsWith('talabna://')) {
          final uri = Uri.parse(settings.name!);
          final pathSegments = uri.pathSegments;

          if (pathSegments.isNotEmpty) {
            String postId;
            if (pathSegments.length >= 2 && pathSegments[0] == 'service-post') {
              postId = pathSegments[1];
            } else if (pathSegments.length == 1 && _isNumeric(pathSegments[0])) {
              postId = pathSegments[0];
            } else {
              return _errorRoute('Invalid deep link format');
            }

            DebugLogger.log('Detected talabna:// scheme with ID: $postId', category: 'NAVIGATION');
            return _handleServicePostRoute({'postId': postId});
          }
        }

        // Navigation guard to prevent rapid duplicate navigations
        if (!_shouldAllowNavigation(settings.name!)) {
          DebugLogger.log('Blocking duplicate navigation to: ${settings.name}', category: 'NAVIGATION');
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            settings: settings,
          );
        }
      }

      // Standard route handling
      switch (settings.name) {
        case initial:
        case login:
          return _buildRoute((context) => const LoginScreenNew());

        case register:
          return _buildRoute((context) => RegisterScreenNew(
          ));

        case home:
          return _handleHomeRoute(args);

        case language:
          return _buildRoute((context) => const LanguageSelectionScreen());

        case resetPassword:
          return _buildRoute((context) => const ResetPasswordScreen());

        case servicePost:
          return _handleServicePostRoute(args);

        default:
          return _errorRoute('Route not found: ${settings.name}');
      }
    } catch (e) {
      DebugLogger.log('Route generation error: $e', category: 'NAVIGATION');
      return _errorRoute('Error processing route: ${settings.name}');
    }
  }

  // Navigation guard to prevent rapid navigation to the same route
  static bool _shouldAllowNavigation(String route) {
    final now = DateTime.now();
    final routeKey = route.split('?').first;

    if (_navigationHistory.containsKey(routeKey)) {
      final lastNavigation = _navigationHistory[routeKey]!;
      if (now.difference(lastNavigation).inMilliseconds < 1000) {
        return false;
      }
    }

    _navigationHistory[routeKey] = now;
    return true;
  }

  // Helper method to check if a string is numeric
  static bool _isNumeric(String str) {
    if (str.isEmpty) return false;
    return int.tryParse(str) != null;
  }

  // Specialized route handler for home screen
  static Route<dynamic> _handleHomeRoute(Map<String, dynamic>? args) {
    final userId = args?['userId'] as int?;
    if (userId == null) {
      DebugLogger.log('❌ UserId is required for HomeScreen', category: 'NAVIGATION');
      return _errorRoute('UserId is required for HomeScreen');
    }

    // Reset service post loading state when going to home
    _isCurrentlyLoadingServicePost = false;
    _navigationHistory.clear();

    return _buildRoute((context) {
      // Clear any pending deep links when explicitly going to home
      DeepLinkService().clearPendingDeepLinks();
      return HomeScreen(userId: userId);
    });
  }

  // Simplified service post route handler
  static Route<dynamic> _handleServicePostRoute(Map<String, dynamic>? args) {
    final postId = args?['postId'] as String?;
    if (postId == null) {
      return _errorRoute('postId is required for ServicePost route');
    }

    // Prevent concurrent loads of the same service post
    final now = DateTime.now();
    final routeKey = 'service-post-$postId';

    if (_navigationHistory.containsKey(routeKey)) {
      final lastNavigation = _navigationHistory[routeKey]!;
      if (now.difference(lastNavigation).inMilliseconds < 1500) {
        DebugLogger.log('Debouncing service post navigation for ID: $postId', category: 'NAVIGATION');
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      }
    }

    // If already loading a service post, show loading
    if (_isCurrentlyLoadingServicePost) {
      DebugLogger.log('Another service post is already loading, showing loader', category: 'NAVIGATION');
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    _navigationHistory[routeKey] = now;
    _isCurrentlyLoadingServicePost = true;

    DebugLogger.log('Creating route for service post ID: $postId', category: 'NAVIGATION');

    return MaterialPageRoute(
      builder: (context) {
        // First check authentication
        final authState = BlocProvider.of<AuthenticationBloc>(context).state;
        if (authState is! AuthenticationSuccess) {
          _isCurrentlyLoadingServicePost = false;
          DebugLogger.log('User not authenticated for service post', category: 'NAVIGATION');

          // Store the deep link before redirecting to login
          DeepLinkService().storePendingDeepLink('service-post', postId);
          return const LoginScreenNew();
        }

        final userId = authState.userId!;

        // Load the data only once per route creation
        DebugLogger.log('Loading service post data for ID: $postId', category: 'NAVIGATION');

        // Clear any pending deep links to avoid duplicate processing
        DeepLinkService().clearPendingDeepLinks();

        // Load the data via BLoCs
        context.read<UserProfileBloc>().add(UserProfileRequested(id: userId));
        context.read<ServicePostBloc>().add(GetServicePostByIdEvent(id: int.parse(postId)));

        // Return the service post view with loading state
        return BlocListener<ServicePostBloc, ServicePostState>(
          listener: (context, state) {
            if (state is ServicePostLoadSuccess || state is ServicePostLoadFailure) {
              // Reset loading flag when load completes (success or failure)
              _isCurrentlyLoadingServicePost = false;
            }
          },
          child: _buildServicePostView(context, userId, int.parse(postId)),
        );
      },
    );
  }

  // Simplified service post view builder
  static Widget _buildServicePostView(BuildContext context, int userId, int postId) {
    return BlocBuilder<ServicePostBloc, ServicePostState>(
      builder: (context, servicePostState) {
        return BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, userProfileState) {
            if (servicePostState is ServicePostLoadSuccess &&
                userProfileState is UserProfileLoadSuccess) {

              final servicePost = _findServicePost(servicePostState.servicePosts, postId);
              final user = userProfileState.user;

              if (servicePost != null) {
                DebugLogger.log('Successfully loaded service post ID: $postId', category: 'NAVIGATION');
                return ServicePostCardView(
                  userProfileId: userId,
                  servicePost: servicePost,
                  canViewProfile: true,
                  user: user,
                  onPostDeleted: () {
                    _isCurrentlyLoadingServicePost = false;
                    Navigator.of(context).pop();
                  },
                );
              }
            }

            // Handle loading or error states
            return _buildLoadingOrErrorState(servicePostState, userProfileState);
          },
        );
      },
    );
  }

  // Helper to find specific service post
  static ServicePost? _findServicePost(List<ServicePost> posts, int postId) {
    try {
      return posts.firstWhere((post) => post.id == postId);
    } catch (e) {
      DebugLogger.log('Service post not found for ID: $postId', category: 'NAVIGATION');
      return null;
    }
  }

  // Builds loading or error state widget
  static Widget _buildLoadingOrErrorState(
      ServicePostState servicePostState,
      UserProfileState userProfileState
      ) {
    // Check service post load failure first
    if (servicePostState is ServicePostLoadFailure) {
      return _buildErrorScaffold(servicePostState.errorMessage);
    }

    // Then check user profile load failure
    if (userProfileState is UserProfileLoadFailure) {
      return _buildErrorScaffold(userProfileState.error);
    }

    // Default to loading state
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  // Builds error scaffold
  static Widget _buildErrorScaffold(String errorMessage) {
    return Scaffold(
      appBar: AppBar(title: const Text('خطأ')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  // Centralized route builder with error handling
  static Route<dynamic> _buildRoute(WidgetBuilder builder) {
    return MaterialPageRoute(builder: builder);
  }

  // Error route with logging and debug information
  static Route<dynamic> _errorRoute(String message) {
    DebugLogger.log('Route Error: $message', category: 'NAVIGATION');

    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // Print all logs when the button is pressed
                  await DebugLogger.printAllLogs();
                },
                child: const Text('عرض سجلات التصحيح'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Logging utility for route arguments
  static void _logRouteArguments(Map<String, dynamic>? args) {
    if (args != null) {
      DebugLogger.log('Route Arguments: $args', category: 'NAVIGATION');
    }
  }

  // Navigation Helpers
  static void navigateToHome(BuildContext context, int userId) {
    // Reset service post loading state
    _isCurrentlyLoadingServicePost = false;

    // Clear any pending deep links
    DeepLinkService().clearPendingDeepLinks();

    Navigator.pushReplacementNamed(
      context,
      home,
      arguments: {'userId': userId},
    );
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, login);
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.pushReplacementNamed(context, register);
  }

  static void navigateToLanguage(BuildContext context) {
    Navigator.pushNamed(context, language);
  }

  static void navigateToResetPassword(BuildContext context) {
    Navigator.pushNamed(context, resetPassword);
  }

  static void navigateToServicePost(BuildContext context, String postId) {
    // Check for duplicate navigation
    final routeKey = 'service-post-$postId';
    final now = DateTime.now();

    if (_navigationHistory.containsKey(routeKey)) {
      final lastNavigation = _navigationHistory[routeKey]!;
      if (now.difference(lastNavigation).inMilliseconds < 1000) {
        DebugLogger.log('Skipping duplicate navigation to service post: $postId', category: 'NAVIGATION');
        return;
      }
    }

    // If already loading another service post, skip this navigation
    if (_isCurrentlyLoadingServicePost) {
      DebugLogger.log('Already loading a service post, skipping navigation', category: 'NAVIGATION');
      return;
    }

    _navigationHistory[routeKey] = now;

    Navigator.pushNamed(
      context,
      servicePost,
      arguments: {'postId': postId},
    );
  }
}