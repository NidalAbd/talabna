import 'dart:convert';

import 'package:talbna/utils/constants.dart';
import 'package:http/http.dart' as http;

import '../models/service_post.dart';
import '../models/user.dart';

class UserProfileService {
  static const String _baseUrl = Constants.apiBaseUrl;

  Future<List<ServicePost>> getServicePostsByUserId(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/user-profiles/$userId/service-posts'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<ServicePost> servicePosts =
            data.map((e) => ServicePost.fromJson(e)).toList();

        return servicePosts;
      } else if (response.statusCode == 404) {
        throw Exception('هذا الملف الشخصي غير موجود');
      } else {
        throw Exception('فشل في تحميل المنشورات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم - المنشورات');
    }
  }
  Future<List<User>> getFollowerByUserId(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/follower/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<User> userFollower =
        data.map((e) => User.fromJson(e)).toList();

        return userFollower;
      } else if (response.statusCode == 404) {
        throw Exception('هذا الملف الشخصي غير موجود');
      } else {
        throw Exception('فشل في تحميل المتابعين');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم - المتابعين');
    }
  }

  Future<List<User>> getFollowingByUserId(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/following/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<User> userFollower =
        data.map((e) => User.fromJson(e)).toList();

        return userFollower;
      } else if (response.statusCode == 404) {
        throw Exception('هذا الملف الشخصي غير موجود');
      } else {
        throw Exception('فشل في تحميل المتابعين');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم - المتابعين');
    }
  }

  Future<User> updateUserProfile(User user) async {
    try {
      final response = await http.put(Uri.parse('$_baseUrl/users/${user.id}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(user.toJson()));

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to update user profile');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }
}
