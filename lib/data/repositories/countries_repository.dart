import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:talbna/data/models/countries.dart';
import 'package:talbna/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountriesRepository {
  static const baseUrl = Constants.apiBaseUrl;

  CountriesRepository();

  Future<List<Country>> getCountries() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/api/countries_list'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = jsonDecode(response.body);
      final List<dynamic> countriesJson = responseJson['countries'];
      return countriesJson.map((json) => Country.fromJson(json)).toList();
    } else {
      throw Exception('فشل في تحميل الدول');
    }
  }


  Future<List<City>> getCities(int countryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/api/countries_list/$countryId/cities/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print(response.statusCode);
    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);
        final List<dynamic> citiesJson = responseJson['cities'];
        return citiesJson.map((json) => City.fromJson(json)).toList();
      } else {
        throw Exception('فشل في تحميل المدن للدولة $countryId');
      }
    } catch (e) {
      throw Exception('خطأ غير متوقع: $e');
    }
  }

}
