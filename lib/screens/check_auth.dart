import 'package:flutter/material.dart';


enum AuthErrorType {
  networkError,
  invalidCredentials,
  emailNotVerified,
  accountLocked,
  tooManyAttempts,
  serverError,
  unknownError,
  emailAlreadyExists,
  weakPassword,
  userCancelled,
}

class AuthSnackBar {
  static void show(
      BuildContext context, {
        required AuthErrorType errorType,
        required String customMessage,
        Function()? onRetry,
      }) {
    Color backgroundColor;
    IconData icon;

    switch (errorType) {
      case AuthErrorType.networkError:
        backgroundColor = Colors.orange.shade700;
        icon = Icons.wifi_off;
        break;
      case AuthErrorType.invalidCredentials:
        backgroundColor = Colors.red.shade700;
        icon = Icons.lock;
        break;
      case AuthErrorType.emailNotVerified:
        backgroundColor = Colors.blue.shade700;
        icon = Icons.mark_email_unread;
        break;
      case AuthErrorType.accountLocked:
        backgroundColor = Colors.red.shade800;
        icon = Icons.lock_clock;
        break;
      case AuthErrorType.tooManyAttempts:
        backgroundColor = Colors.orange.shade800;
        icon = Icons.timer;
        break;
      case AuthErrorType.serverError:
        backgroundColor = Colors.red.shade700;
        icon = Icons.cloud_off;
        break;
      case AuthErrorType.emailAlreadyExists:
        backgroundColor = Colors.purple.shade700;
        icon = Icons.email;
        break;
      case AuthErrorType.weakPassword:
        backgroundColor = Colors.amber.shade700;
        icon = Icons.password;
        break;
      case AuthErrorType.userCancelled:
        backgroundColor = Colors.grey.shade700;
        icon = Icons.cancel;
        break;
      case AuthErrorType.unknownError:
      backgroundColor = Colors.red.shade700;
        icon = Icons.error_outline;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                customMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}