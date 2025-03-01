import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:talbna/data/models/point_balance.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/service_post.dart';

class UserProfileRepository {
  static const String _baseUrl = Constants.apiBaseUrl;


  Future<User> getUserProfileById(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$_baseUrl/api/user/profile/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("HTTP Response Status: ${response.statusCode}");
      print("HTTP Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);

        if (!jsonData.containsKey('userData') || jsonData['userData'] == null) {
          print("Error: JSON response does not contain 'userData'");
          throw Exception('JSON response does not contain userData');
        }

        try {
          return User.fromJson(jsonData['userData']);
        } catch (e) {
          print("Error parsing userData: $e");
          throw Exception('Failed to parse userData: $e');
        }
      } else if (response.statusCode == 404) {
        print("Error: User profile not found (404)");
        throw Exception('هذا الملف الشخصي غير موجود');
      } else {
        print("Error: Failed to load profile, status code: ${response.statusCode}");
        throw Exception('فشل في تحميل الملف الشخصي');
      }
    } catch (e) {
      print("Unexpected error: $e");
      throw Exception('خطأ غير متوقع: $e');
    }
  }


  Future<List<User>> getFollowerByUserId(
      {required int userId, int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

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



  Future<User> updateUserProfile(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/users/${user.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(user.toJson()),
      );

      try{
      if (response.statusCode == 200 || response.statusCode == 201) {
        return User.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('هذا الملف الشخصي غير موجود');
      } else {
        throw Exception('خطا في تحديث الملف الشخصي');
      }
    }catch (e) {
      print('Failed to update user profile first Try: $e');
      throw Exception('خطا الاتصال');
    }
    } catch (e) {
      print('Failed to update user profile Second Try: $e');
      throw Exception('خطا الاتصال في الخادم - الملف الشخصي');
    }
  }
  Future<void> updateUserEmail(User user, String newEmail , String password) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/user/${user.id}/change-email'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'email': newEmail ,'password': password}),
      );
      print(jsonEncode({'email': newEmail,'password': password}));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }else if (response.statusCode == 401) {
        throw Exception('password is incorrect.');
      } else {
        throw Exception('Failed to update email.');
      }
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  Future<void> updateUserPassword(User user, String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/user/${user.id}/change-password'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'old_password': oldPassword, 'new_password': newPassword}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Old password is incorrect.');
      } else {
        throw Exception('Failed to update password , status code error.');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

// Update profile photo
  Future<void> updateUserProfilePhoto(User user, File photo) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    try {
      final stream = http.ByteStream(photo.openRead());
      final length = await photo.length();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/user/${user.id}/update-profile-photo'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      final multipartFile = http.MultipartFile('photo', stream, length, filename: basename(photo.path));
      request.files.add(multipartFile);
      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(await response.stream.bytesToString());
        print('dwd ${responseBody['photo']}');

        if (responseBody['photo'] != null) {
          Photo updatedPhoto = Photo.fromJson(responseBody['photo']);
          user.photos?.add(updatedPhoto);
        }
        return;
      } else {
        throw Exception('Failed to update profile photo.');
      }
    } catch (e) {
      throw Exception('Failed to update profile photo.');
    }
  }

}
