import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:talbna/data/models/point_balance.dart';
import 'package:talbna/data/models/purchase_request.dart';
import 'package:talbna/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseRequestRepository {
  static const baseUrl = Constants.apiBaseUrl;

  Future<List<PurchaseRequest>> fetchPurchaseRequests(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/api/purchase-requests/user/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as List<dynamic>;
      final purchaseRequests = jsonResponse
          .map((json) => PurchaseRequest.fromJson(json))
          .toList(growable: false);
      return purchaseRequests;
    } else {
      throw Exception('حدث خطأ أثناء جلب طلبات الشراء');
    }
  }

  Future<void> createPurchaseRequest(PurchaseRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.post(
      Uri.parse('$baseUrl/api/purchase-requests'),
      body: jsonEncode(request.toJson()),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return;
    } else {
      throw Exception('حدث خطأ أثناء إرسال طلب الشراء');
    }
  }

  Future<PointBalance> getUserPointsBalance({required int userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/api/user/point/$userId'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      int pointBalance = 0;
      if (json['pointBalance'] != null) {
        if (json['pointBalance'] is int) {
          pointBalance = json['pointBalance'];
        } else if (json['pointBalance'] is String) {
          pointBalance = int.parse(json['pointBalance']);
        }
      }

      return PointBalance(userId: userId, totalPoint: pointBalance);
    } else {
      throw Exception("Failed to fetch user points balance");
    }
  }

  Future<void> cancelPurchaseRequest(int requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/purchase-requests/$requestId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('حدث خطأ أثناء إلغاء طلب الشراء');
      }
    } catch (e) {
      throw Exception('حدث خطأ ');
    }
  }
}
