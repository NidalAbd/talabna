import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/data/models/notifications.dart';
import 'package:talbna/utils/constants.dart';

class NotificationRepository {
  static const baseUrl = Constants.apiBaseUrl;

  NotificationRepository();

  Future<List<Notifications>> getUserNotifications({required int userId ,int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId/notifications?page=$page'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<Notifications> notifications = (data["data"] as List)
          .map((e) => Notifications.fromJson(e))
          .toList();
      print(notifications);
      return notifications;
      }else {
        throw Exception('JSON response does not contain Notification');
      }
  }

  Future<void> markNotificationAsRead({required int notificationId ,required int userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId/notifications/$notificationId/mark_read/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('فشل في تحديث الإشعار');
    }
  }

  Future<int> countNotification({required int userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId/CountNotifications'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final int = jsonDecode(response.body);
      return int;
    } else {
      throw Exception('فشل في سحب البيانات');
    }
  }
}
