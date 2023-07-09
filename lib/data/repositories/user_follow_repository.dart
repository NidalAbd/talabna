import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:talbna/data/models/report.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserFollowRepository {
  static const String _baseUrl = Constants.apiBaseUrl;

  Future<List<User>> getFollowerByUserId(
      {required int userId, int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.get(
        Uri.parse('$_baseUrl/api/user/follower/$userId?page=$page'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<User> userFollower = (data["data"] as List)
          .map((e) => User.fromJson(e))
          .toList();
      return userFollower;
    } else if (response.statusCode == 404) {
      throw Exception('هذا الملف الشخصي غير موجود');
    } else {
      throw Exception('فشل في تحميل المتابعين');
    }
  }

  Future<List<User>> getFollowingByUserId(
      {required int userId, int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.get(
          Uri.parse('$_baseUrl/api/user/following/$userId?page=$page'),
          headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<User> userFollowing = (data["data"] as List)
            .map((e) => User.fromJson(e))
            .toList();
        return userFollowing;
      } else if (response.statusCode == 404) {
        throw Exception('هذا الملف الشخصي غير موجود');
      } else {
        throw Exception('فشل في تحميل المتابعين');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم - المتابعين');
    }
  }
  Future<List<User>> getUserSeller(
      {int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.get(
          Uri.parse('$_baseUrl/api/user/UserSeller?page=$page'),
          headers: {'Authorization': 'Bearer $token'});
      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<User> userFollowing = (data["data"] as List)
            .map((e) => User.fromJson(e))
            .toList();
        return userFollowing;
      } else if (response.statusCode == 404) {
        throw Exception('هذا الملف الشخصي غير موجود');
      } else {
        throw Exception('فشل في تحميل المتابعين');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم - المتابعين');
    }
  }
  Future<Reports> makeReport({required int id , required String type , required String reason}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.post(Uri.parse('$_baseUrl/api/reports/reported/$type/reportedId/$id/reason/$reason'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      if (jsonData.containsKey('report') && jsonData['report'] != null) {
        print(jsonData['report']);

        return Reports.fromJson(jsonData['report']);
      } else {
        throw Exception('JSON response does not contain userData');
      }
    } else if (response.statusCode == 404) {
      throw Exception('هذا الملف الشخصي غير موجود');
    } else {
      throw Exception('فشل في تحميل الملف الشخصي');
    }
  }

  Future<bool> toggleFollowSubcategories(int subCategoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/api/subcategories/$subCategoryId/toggle-follow'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      final isFollowing = jsonResponse['isFollowSubcategory'] ?? false;
      return isFollowing;
    } else {
      return false;
    }
  }
  Future<bool> getUserFollow(int user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/$user/is-following'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      final isFollowing = jsonResponse['is_follower'] ?? false;
      return isFollowing;
    } else {
      return false;
    }
  }
  Future<bool> getUserFollowSubcategories(int subCategoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/api/subcategories/$subCategoryId/is-following'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      final isFollowing = jsonResponse['isFollowSubcategory'] ?? false;
      return isFollowing;
    } else {
      return false;
    }
  }
  Future<bool> toggleUserActionFollow({required int userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token not found in shared preferences');
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/$userId/follower'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data['is_follower']);
        return data['is_follower'];
      } else {
        throw Exception('Error toggling follower state');
      }
    } catch (e) {
      throw Exception('Server connection error - Posts');
    }
  }

  Future<Map<String, dynamic>> searchUserOrPost({required String searchAction,int page = 1,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final Map<String, dynamic> requestBody = {
      'search': searchAction,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/api/search?page=$page'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<User> userResult = (data["users"]["data"] as List)
          .map((e) => User.fromJson(e))
          .toList();
      final List postsResult = (data["posts"]["data"] as List)
          .map((e) => ServicePost.fromJson(e))
          .toList();
      return {'users': userResult, 'posts': postsResult};
    } else if (response.statusCode == 404) {
      throw Exception('هذا الملف الشخصي غير موجود');
    } else {
      throw Exception('فشل في تحميل نتائج البحث');
    }
  }

}