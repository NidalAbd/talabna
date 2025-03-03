import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:talbna/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/debug_logger.dart';

class AuthenticationRepository {
  // ignore: constant_identifier_names
  static const API_BASE_URL = Constants.apiBaseUrl;
  static const String _dataSaverKey = 'data_saver_enabled';
  static const String _authTypeKey = 'auth_type';

  // Web Client ID from Firebase Console - replace with your actual Web Client ID
  static const String _webClientId = '808302489355-m69df866rpeoacp0p29ro61c1kpra2da.apps.googleusercontent.com'; // Add your Web Client ID from Firebase

  // Create Google Sign In instance with the right scopes and serverClientId
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    serverClientId: _webClientId, // This is critical for ID token retrieval
  );

  // Retry mechanism for Google authentication
  Future<GoogleSignInAuthentication> _getGoogleAuth(GoogleSignInAccount account, {int retries = 2}) async {
    for (int i = 0; i <= retries; i++) {
      try {
        DebugLogger.log('Requesting Google authentication tokens (attempt ${i+1})', category: 'AUTH');
        final auth = await account.authentication;

        // Verify we actually have the tokens
        if (auth.idToken == null) {
          DebugLogger.log('ID token is null on attempt ${i+1}', category: 'AUTH_ERROR');
          throw Exception('Failed to obtain Google ID token');
        }

        if (auth.accessToken == null) {
          DebugLogger.log('Access token is null on attempt ${i+1}', category: 'AUTH_ERROR');
          throw Exception('Failed to obtain Google access token');
        }

        return auth;
      } catch (e) {
        DebugLogger.log('Error getting authentication (attempt ${i+1}): $e', category: 'AUTH_ERROR');
        if (i == retries) rethrow;
        // Wait before retry
        await Future.delayed(Duration(seconds: 1));
      }
    }
    throw Exception('Failed to obtain Google authentication after retries');
  }

  Future<Map<String, dynamic>> _post(String url, dynamic data, {String? token}) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      DebugLogger.log('Making POST request to: $url', category: 'HTTP');

      final response = await http.post(
        Uri.parse('$API_BASE_URL/$url'),
        headers: headers,
        body: json.encode(data),
      );

      DebugLogger.log('Response status code: ${response.statusCode}', category: 'HTTP');
      // Only log a portion of the response body to avoid cluttering logs
      String responsePreview = response.body.length > 100
          ? '${response.body.substring(0, 100)}...'
          : response.body;
      DebugLogger.log('Response preview: $responsePreview', category: 'HTTP');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        try {
          final errorData = json.decode(response.body);
          String errorMessage = errorData['error'] ?? 'Status code error: ${response.statusCode}';
          DebugLogger.log('API error: $errorMessage', category: 'HTTP_ERROR');
          throw Exception(errorMessage);
        } catch (e) {
          DebugLogger.log('Cannot parse error response: $e', category: 'HTTP_ERROR');
          throw Exception('Status code error: ${response.statusCode}');
        }
      }
    } catch (e) {
      DebugLogger.log('Server error: $e', category: 'HTTP_ERROR');
      throw Exception('Server error: $e');
    }
  }

  Future<Map<String, dynamic>> _get(String url, {Map<String, String>? additionalHeaders}) async {
    try {
      final authToken = await getAuthToken();
      final headers = {
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
      };

      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      DebugLogger.log('Making GET request to: $url', category: 'HTTP');

      final response = await http.get(Uri.parse('$API_BASE_URL/$url'), headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        try {
          final errorData = json.decode(response.body);
          String errorMessage = errorData['error'] ?? 'Status code error: ${response.statusCode}';
          DebugLogger.log('API error: $errorMessage', category: 'HTTP_ERROR');
          throw Exception(errorMessage);
        } catch (e) {
          DebugLogger.log('Cannot parse error response: $e', category: 'HTTP_ERROR');
          throw Exception('Status code error: ${response.statusCode}');
        }
      }
    } catch (e) {
      DebugLogger.log('Server error: $e', category: 'HTTP_ERROR');
      throw Exception('Server error: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    DebugLogger.log('Attempting login with email', category: 'AUTH');

    final responseData = await _post('api/login', {
      'email': email,
      'password': password,
    });

    final authToken = responseData['access_token'];
    final int userId = responseData['user_id'];
    final String authType = 'email'; // Default auth type for email login

    await saveAuthToken(authToken);
    await saveUserId(userId);
    await saveAuthType(authType);

    DebugLogger.log('Login successful for user ID: $userId', category: 'AUTH');

    return {
      'userId': userId,
      'token': authToken,
      'authType': authType
    };
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    DebugLogger.log('Attempting registration with email', category: 'AUTH');

    final response = await _post('api/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });

    final String authToken = response['access_token'];
    final int userId = response['user_id'];
    final String authType = 'email'; // Default auth type for email registration

    await saveAuthToken(authToken);
    await saveUserId(userId);
    await saveAuthType(authType);

    DebugLogger.log('Registration successful for user ID: $userId', category: 'AUTH');

    return {
      'userId': userId,
      'token': authToken,
      'authType': authType
    };
  }

  Future<Map<String, dynamic>> getUser() async {
    return await _get('api/user');
  }

  Future<bool> isSignedIn() async {
    final authToken = await getAuthToken();
    return authToken != null;
  }

  Future<void> logout() async {
    try {
      final authToken = await getAuthToken();
      final authType = await getAuthType();

      if (authToken == null) {
        return;
      }

      DebugLogger.log('Logging out user', category: 'AUTH');

      // Call API to logout
      final headers = {
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
      };

      await http.post(
          Uri.parse('$API_BASE_URL/api/logout'),
          headers: headers
      );

      // If user was signed in with Google, sign out from Google as well
      if (authType == 'google') {
        try {
          DebugLogger.log('Signing out from Google', category: 'AUTH');
          await _googleSignIn.signOut();
        } catch (e) {
          DebugLogger.log('Error signing out from Google: $e', category: 'AUTH_ERROR');
        }
      }

      // Clear all stored authentication data
      await clearAuthData();
      DebugLogger.log('Logout successful', category: 'AUTH');
    } catch (e) {
      DebugLogger.log('Error during logout: $e', category: 'AUTH_ERROR');
      // Ensure we clear local auth data even if API call fails
      await clearAuthData();
    }
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('userId');
    await prefs.remove(_authTypeKey);
    // We don't clear data_saver_enabled here to preserve user preference
    DebugLogger.log('Auth data cleared from local storage', category: 'AUTH');
  }

  Future<bool> checkTokenValidity(String token) async {
    try {
      DebugLogger.logAuth(
          action: 'VALIDATING',
          source: 'AuthRepository',
          token: token
      );

      final response = await http.get(
        Uri.parse('$API_BASE_URL/api/user/check_token'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        DebugLogger.logAuth(
            action: responseBody['valid'] ? 'VALID' : 'INVALID',
            source: 'AuthRepository',
            token: token,
            details: {'responseCode': response.statusCode}
        );
        return responseBody['valid'] ?? false;
      } else {
        // The token is not valid
        DebugLogger.logAuth(
            action: 'INVALID',
            source: 'AuthRepository',
            token: token,
            details: {'responseCode': response.statusCode}
        );
        return false;
      }
    } catch (e) {
      DebugLogger.logAuth(
          action: 'ERROR',
          source: 'AuthRepository',
          token: token,
          error: e.toString()
      );
      return false;
    }
  }

  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    bool success = await prefs.setString('auth_token', token);

    if (success) {
      DebugLogger.logToken(
          token: token,
          action: 'SAVED',
          source: 'SharedPreferences'
      );
    } else {
      DebugLogger.log('Failed to save token', category: 'AUTH_ERROR');
    }
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    bool success = await prefs.setInt('userId', userId);
    if (success) {
      DebugLogger.log(
          'UserId saved: $userId',
          category: 'AUTH'
      );
    } else {
      DebugLogger.log('Failed to save User ID', category: 'AUTH_ERROR');
    }
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> saveAuthType(String authType) async {
    final prefs = await SharedPreferences.getInstance();
    bool success = await prefs.setString(_authTypeKey, authType);
    if (success) {
      DebugLogger.log(
          'Auth type saved: $authType',
          category: 'AUTH'
      );
    } else {
      DebugLogger.log('Failed to save auth type', category: 'AUTH_ERROR');
    }
  }

  Future<String?> getAuthType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTypeKey) ?? 'email'; // Default to email if not set
  }

  Future<void> resetPassword({required String email}) async {
    try {
      DebugLogger.log('Requesting password reset for email: $email', category: 'AUTH');

      final response = await http.post(
          Uri.parse('$API_BASE_URL/api/password/email'),
          headers: {'Accept': 'application/json'},
          body: {'email': email}
      );

      if (response.statusCode != 200) {
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body);
        } catch (_) {}

        DebugLogger.log('Password reset request failed: ${errorData['error'] ?? 'Unknown error'}', category: 'AUTH_ERROR');
        throw Exception(errorData['error'] ?? 'Failed to send password reset link');
      }

      DebugLogger.log('Password reset link sent successfully', category: 'AUTH');
    } catch (error) {
      DebugLogger.log('Error sending password reset link: $error', category: 'AUTH_ERROR');
      throw Exception('Error sending password reset link: ${error.toString()}');
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      DebugLogger.log('Starting Google Sign-In process', category: 'AUTH');

      // First, check if the user is already signed in with Google and sign out if needed
      bool isSignedIn = await _googleSignIn.isSignedIn();
      if (isSignedIn) {
        DebugLogger.log('User already signed in with Google, signing out first', category: 'AUTH');
        await _googleSignIn.signOut();
      }

      // Trigger the authentication flow with additional error handling
      DebugLogger.log('Showing Google Sign-In UI', category: 'AUTH');
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        DebugLogger.log('Google sign-in was cancelled by user', category: 'AUTH');
        throw Exception('Google sign in cancelled by user');
      }

      DebugLogger.log('Google account selected: ${googleSignInAccount.email}', category: 'AUTH');

      // Get authentication with retry mechanism
      try {
        final GoogleSignInAuthentication googleAuth = await _getGoogleAuth(googleSignInAccount);

        // Check if we have tokens
        final String? idToken = googleAuth.idToken;
        final String? accessToken = googleAuth.accessToken;

        DebugLogger.log('ID token received: ${idToken != null}', category: 'AUTH');
        DebugLogger.log('Access token received: ${accessToken != null}', category: 'AUTH');

        if (idToken == null) {
          DebugLogger.log('Failed to obtain Google ID token', category: 'AUTH_ERROR');
          throw Exception('Failed to obtain Google ID token');
        }

        if (accessToken == null) {
          DebugLogger.log('Failed to obtain Google access token', category: 'AUTH_ERROR');
          throw Exception('Failed to obtain Google access token');
        }

        // Create request data
        final Map<String, dynamic> requestData = {
          'id_token': idToken,
          'access_token': accessToken,
          'email': googleSignInAccount.email,
          'name': googleSignInAccount.displayName ?? '',
          'photo_url': googleSignInAccount.photoUrl ?? '',
        };

        DebugLogger.log('Sending Google auth data to server', category: 'AUTH');

        // Make a request to our API to authenticate with Google
        final responseData = await _post('api/auth/google', requestData);

        DebugLogger.log('Received response from server for Google auth', category: 'AUTH');

        // Extract data from response
        final String? authToken = responseData['token'];
        int? userId;

        // Handle different response formats
        if (responseData['user'] != null && responseData['user']['id'] != null) {
          userId = responseData['user']['id'];
        } else if (responseData['user_id'] != null) {
          userId = responseData['user_id'];
        }

        final bool isNewUser = responseData['is_new_user'] ?? false;
        final String authType = 'google';

        if (authToken == null) {
          DebugLogger.log('Server did not return an auth token', category: 'AUTH_ERROR');
          throw Exception('Authentication token not found in response');
        }

        if (userId == null) {
          DebugLogger.log('Server did not return a user ID', category: 'AUTH_ERROR');
          throw Exception('User ID not found in response');
        }

        // Save auth data to local storage
        DebugLogger.log('Saving auth data to local storage', category: 'AUTH');
        await saveAuthToken(authToken);
        await saveUserId(userId);
        await saveAuthType(authType);

        // Check and save data saver status if provided in response
        if (responseData['user'] != null && responseData['user']['data_saver_enabled'] != null) {
          final bool dataSaverEnabled = responseData['user']['data_saver_enabled'] == true;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_dataSaverKey, dataSaverEnabled);
        }

        DebugLogger.log('Google sign-in successful for user ID: $userId', category: 'AUTH');

        return {
          'userId': userId,
          'token': authToken,
          'authType': authType,
          'isNewUser': isNewUser
        };
      } catch (e) {
        DebugLogger.log('Error during Google authentication: $e', category: 'AUTH_ERROR');

        // Try to sign out from Google to reset the state
        try {
          await _googleSignIn.signOut();
        } catch (signOutError) {
          DebugLogger.log('Error signing out after authentication failure: $signOutError', category: 'AUTH_ERROR');
        }

        throw Exception('Error authenticating with Google: $e');
      }
    } catch (error) {
      DebugLogger.log('Error signing in with Google: $error', category: 'AUTH_ERROR');
      throw Exception('Error signing in with Google: ${error.toString()}');
    }
  }

  // Data Saver Mode functions

  Future<bool> getDataSaverStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dataSaverKey) ?? false;
  }

  Future<bool> setDataSaverStatus(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();

    // Try to sync with server if we're logged in
    final authToken = await getAuthToken();
    if (authToken != null) {
      try {
        // Call API to update data saver setting on server
        await _post('api/data-saver/toggle', {}, token: authToken);
      } catch (e) {
        DebugLogger.log('Error updating data saver on server: $e', category: 'AUTH_ERROR');
        // Continue anyway to update local setting
      }
    }

    // Update local setting
    return await prefs.setBool(_dataSaverKey, isEnabled);
  }

  Future<bool> toggleDataSaver() async {
    final currentStatus = await getDataSaverStatus();
    final newStatus = !currentStatus;

    final success = await setDataSaverStatus(newStatus);
    return success ? newStatus : currentStatus;
  }
}