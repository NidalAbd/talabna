import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum AuthErrorType {
  invalidCredentials,
  networkError,
  serverError,
  unknownError,
  emailNotVerified,
  accountLocked,
  tooManyAttempts,
}

class AuthErrorWidget extends StatelessWidget {
  final AuthErrorType errorType;
  final String? customMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onAlternativeAction;

  const AuthErrorWidget({
    Key? key,
    required this.errorType,
    this.customMessage,
    this.onRetry,
    this.onAlternativeAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated Error Illustration
            _getErrorIllustration(),

            const SizedBox(height: 24),

            // Error Title
            Text(
              _getErrorTitle(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Error Description
            Text(
              customMessage ?? _getErrorDescription(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Column(
              children: [
                // Retry Button
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                // Alternative Action Button
                if (onAlternativeAction != null) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: onAlternativeAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_getAlternativeActionText()),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getErrorIllustration() {
    String animationPath;
    switch (errorType) {
      case AuthErrorType.invalidCredentials:
        animationPath = 'assets/animations/error_credentials.json';
        break;
      case AuthErrorType.networkError:
        animationPath = 'assets/animations/error_network.json';
        break;
      case AuthErrorType.serverError:
        animationPath = 'assets/animations/error_server.json';
        break;
      case AuthErrorType.emailNotVerified:
        animationPath = 'assets/animations/error_email_verification.json';
        break;
      case AuthErrorType.accountLocked:
        animationPath = 'assets/animations/error_account_locked.json';
        break;
      case AuthErrorType.tooManyAttempts:
        animationPath = 'assets/animations/error_too_many_attempts.json';
        break;
      default:
        animationPath = 'assets/animations/error_generic.json';
    }

    return Lottie.asset(
      animationPath,
      width: 250,
      height: 250,
      fit: BoxFit.contain,
      frameRate: FrameRate.max,
    );
  }

  String _getErrorTitle() {
    switch (errorType) {
      case AuthErrorType.invalidCredentials:
        return 'Invalid Credentials';
      case AuthErrorType.networkError:
        return 'Connection Error';
      case AuthErrorType.serverError:
        return 'Server Error';
      case AuthErrorType.emailNotVerified:
        return 'Email Not Verified';
      case AuthErrorType.accountLocked:
        return 'Account Locked';
      case AuthErrorType.tooManyAttempts:
        return 'Too Many Attempts';
      default:
        return 'Authentication Failed';
    }
  }

  String _getErrorDescription() {
    switch (errorType) {
      case AuthErrorType.invalidCredentials:
        return 'The email or password you entered is incorrect. Please try again.';
      case AuthErrorType.networkError:
        return 'Unable to connect. Please check your internet connection and try again.';
      case AuthErrorType.serverError:
        return 'Our servers are experiencing issues. Please try again later.';
      case AuthErrorType.emailNotVerified:
        return 'Please verify your email address to continue.';
      case AuthErrorType.accountLocked:
        return 'Your account has been temporarily locked. Please contact support.';
      case AuthErrorType.tooManyAttempts:
        return 'Too many login attempts. Please try again later.';
      default:
        return 'An unexpected error occurred during authentication. Please try again.';
    }
  }

  String _getAlternativeActionText() {
    switch (errorType) {
      case AuthErrorType.emailNotVerified:
        return 'Resend Verification Email';
      case AuthErrorType.accountLocked:
        return 'Contact Support';
      case AuthErrorType.tooManyAttempts:
        return 'Reset Password';
      default:
        return 'Need Help?';
    }
  }
}

// Enhanced SnackBar for authentication messages
class AuthSnackBar {
  static void show(
      BuildContext context, {
        required AuthErrorType errorType,
        String? customMessage,
        VoidCallback? onRetry,
        VoidCallback? onAlternativeAction,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getErrorTitle(errorType),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              customMessage ?? _getErrorDescription(errorType),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(errorType),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: onRetry != null
            ? SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: onRetry,
        )
            : null,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static String _getErrorTitle(AuthErrorType errorType) {
    switch (errorType) {
      case AuthErrorType.invalidCredentials:
        return 'Invalid Credentials';
      case AuthErrorType.networkError:
        return 'Connection Error';
      case AuthErrorType.serverError:
        return 'Server Error';
      case AuthErrorType.emailNotVerified:
        return 'Email Not Verified';
      case AuthErrorType.accountLocked:
        return 'Account Locked';
      case AuthErrorType.tooManyAttempts:
        return 'Too Many Attempts';
      default:
        return 'Authentication Failed';
    }
  }

  static String _getErrorDescription(AuthErrorType errorType) {
    switch (errorType) {
      case AuthErrorType.invalidCredentials:
        return 'The email or password you entered is incorrect.';
      case AuthErrorType.networkError:
        return 'Unable to connect. Please check your internet connection.';
      case AuthErrorType.serverError:
        return 'Our servers are experiencing issues.';
      case AuthErrorType.emailNotVerified:
        return 'Please verify your email address to continue.';
      case AuthErrorType.accountLocked:
        return 'Your account has been temporarily locked.';
      case AuthErrorType.tooManyAttempts:
        return 'Too many login attempts. Please try again later.';
      default:
        return 'An unexpected error occurred during authentication.';
    }
  }

  static Color _getErrorColor(AuthErrorType errorType) {
    switch (errorType) {
      case AuthErrorType.invalidCredentials:
        return Colors.orange;
      case AuthErrorType.networkError:
        return Colors.red;
      case AuthErrorType.serverError:
        return Colors.deepPurple;
      case AuthErrorType.emailNotVerified:
        return Colors.amber;
      case AuthErrorType.accountLocked:
        return Colors.red.shade700;
      case AuthErrorType.tooManyAttempts:
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }
}