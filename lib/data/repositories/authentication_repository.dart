import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:talbna/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationRepository {
  // ignore: constant_identifier_names
  static const API_BASE_URL = Constants.apiBaseUrl;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  Future<Map<String, dynamic>> _post(String url, dynamic data, {String? token}) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      final response = await http.post(
          Uri.parse('$API_BASE_URL/$url'),
          headers: headers,
          body: json.encode(data),
        );
      print(response.statusCode);

      if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          return responseData;
        } else {
          throw Exception('Status code error: ${response.statusCode}');
        }
    } catch (e) {
      throw Exception('Server error: $e');
    }
  }

  Future<Map<String, dynamic>> _get(String url) async {
    final authToken = await getAuthToken();
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final headers = {
      'Authorization': 'Bearer $authToken',
    };
    final response = await http.get(Uri.parse('$API_BASE_URL/$url'), headers: headers);
    final responseData = json.decode(jsonEncode(response.body));
    if (response.statusCode >= 400) {
      throw Exception(responseData['message']);
    }
    return responseData;
  }

  Future<Map<String, dynamic>> login({
    required String authProvider,
    required String email,
    required String password,
  }) async {
    final responseData = await _post('api/login', {
      'email': email,
      'password': password,
    });
    final authToken = responseData['access_token'];
    final int userId = responseData['user_id'];

    await saveAuthToken(authToken);
    await saveUserId(userId);
    return {'userId': userId, 'token': authToken};
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String authProvider,
  }) async {
    final response = await _post('api/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
    final String authToken = response['access_token'];
    final int userId = response['user_id'];
    await saveAuthToken(authToken);
    await saveUserId(userId);
    return {'userId': userId, 'token': authToken};
  }


  Future<Map<String, dynamic>> getUser() async {
    return await _get('user');
  }

  Future<bool> isSignedIn() async {
    final authToken = await getAuthToken();
    return authToken != null;
  }

  Future<void> logout() async {
    final authToken = await getAuthToken();

    if (authToken == null) {
      return;
    }

    final headers = {
      'Authorization': 'Bearer $authToken',
    };

    await http.post(Uri.parse('$API_BASE_URL/api/logout'), headers: headers);
    await removeAuthToken();
  }
  Future<
      bool> checkTokenValidity(String token) async {
    final response = await http.get(
      Uri.parse('$API_BASE_URL/api/user/check_token'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody['valid'] ?? false;
    } else {
      // The token is not valid
      return false;
    }
  }


  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId );
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> removeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> resetPassword({required String email}) async {
    try {
      final response = await http.post(
          Uri.parse('$API_BASE_URL/api/password/email'),
          body: {'email': email});
      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to send password reset link');
      }
    } catch (error) {
      throw Exception('Error sending password reset link: ${error.toString()}');
    }
  }

  Future<String> loginWithFacebook(String accessToken) async {
    final responseData = await _post('facebook', {
      'access_token': accessToken,
    });

    final authToken = responseData['token'];
    await saveAuthToken(authToken);

    return authToken;
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
        // Make a request to your API to authenticate the user
        final responseData = await _post('googleSignIn', {'id_token': googleAuth.idToken , 'id': googleSignInAccount.id});
        final authToken = responseData['id_token'];
        final userId = responseData['id'];
        await saveAuthToken(authToken);
        await saveUserId(userId);
        if (authToken != null) {
          return {'userId': userId, 'token': authToken};
        } else {
          throw Exception('Authentication token not found in response');
        }
      } else {
        throw Exception('Google sign in cancelled by user');
      }
    } catch (error) {
      throw Exception('Error signing in with Google: ${error.toString()}');
    }
  }
}
