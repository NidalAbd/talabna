import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/models/categories_selected_menu.dart';
import 'package:talbna/data/models/category_menu.dart';
import 'package:talbna/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesRepository {
  static const baseUrl = Constants.apiBaseUrl;

  CategoriesRepository();

  Future<List<Category>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/api/categories_list'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = jsonDecode(response.body);
      final List<dynamic> categoriesJson = responseJson['categories'];
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('فشل في تحميل الفئات الرئيسية');
    }
  }
  Future<List<CategoryMenu>> getCategoryMenu() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/categories_menu'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = jsonDecode(response.body);
      final List<dynamic> categoriesJson = responseJson['categories'];

      return categoriesJson.map((json) => CategoryMenu.fromJson(json)).toList();
    } else {
      throw Exception('فشل في تحميل الفئات الرئيسية');
    }
  }

  Future<List<SubCategory>> getSubCategories(int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/api/categories_list/$categoryId/sub_categories/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = jsonDecode(response.body);
      final List<dynamic> subcategoriesJson = responseJson['subcategories'];
      return subcategoriesJson
          .map((json) => SubCategory.fromJson(json))
          .toList();
    } else {
      throw Exception(' فشل في تحميل الفئات الفرعية $categoryId');
    }
  }
  Future<List<SubCategoryMenu>> getSubCategoriesMenu(int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/api/categories_list/$categoryId/sub_categories/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = jsonDecode(response.body);
      final List<dynamic> subcategoriesJson = responseJson['subcategories'];
      return subcategoriesJson
          .map((json) => SubCategoryMenu.fromJson(json))
          .toList();
    } else {
      throw Exception('فشل في تحميل الفئات الفرعية $categoryId');
    }
  }


}
