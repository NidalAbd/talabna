import 'package:http/http.dart' as http;
import 'package:talbna/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportRepository {
  static const String _baseUrl = Constants.apiBaseUrl;
  Future<bool> makeReport({required int id , required String type , required String reason}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.post(Uri.parse('$_baseUrl/api/reports/reported/$type/reportedId/$id/reason/$reason'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
    } else if (response.statusCode == 404) {
      throw Exception('هذا الملف الشخصي غير موجود');
    } else {
      throw Exception('فشل في تحميل الملف الشخصي');
    }
  }

}