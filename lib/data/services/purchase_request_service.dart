import 'dart:convert';

import 'package:talbna/data/models/purchase_request.dart';
import 'package:http/http.dart' as http;

class PurchaseRequestService {
  final String _baseUrl;

  PurchaseRequestService({required String baseUrl}) : _baseUrl = baseUrl;

  Future<void> createPurchaseRequest(PurchaseRequest purchaseRequest) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/purchase_requests'),
      body: jsonEncode(purchaseRequest.toJson()),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 201) {
      throw Exception('حدث خطأ أثناء إرسال طلب الشراء');
    }
  }
}
