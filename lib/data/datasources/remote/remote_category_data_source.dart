// lib/data/datasources/remote/remote_category_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/data/datasources/category_data_source.dart';
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/models/categories_selected_menu.dart';
import 'package:talbna/data/models/category_menu.dart';
import 'package:talbna/utils/constants.dart';
import 'package:talbna/utils/debug_logger.dart';

class RemoteCategoryDataSource implements CategoryDataSource {
  static const baseUrl = Constants.apiBaseUrl;

  @override
  Future<List<Category>> getCategories() async {
    DebugLogger.log('RemoteCategoryDataSource: getCategories() started', category: 'DATA_SOURCE');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      DebugLogger.log('Error: Auth token is null', category: 'DATA_SOURCE');
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/categories_list'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);

        if (decodedResponse is! Map<String, dynamic>) {
          throw Exception('Invalid API response format');
        }

        if (!decodedResponse.containsKey('categories')) {
          throw Exception('Missing "categories" key in API response');
        }

        final categoriesJson = decodedResponse['categories'];
        if (categoriesJson is! List) {
          throw Exception('"categories" field must be a list');
        }

        final categories = categoriesJson.map((json) {
          try {
            return Category.fromJson(json);
          } catch (e) {
            throw Exception('Failed to parse category');
          }
        }).toList();

        DebugLogger.log('Fetched ${categories.length} categories from API', category: 'DATA_SOURCE');
        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      DebugLogger.log('Exception in getCategories: $e', category: 'DATA_SOURCE');
      throw Exception('Error fetching categories');
    }
  }

  @override
  Future<List<CategoryMenu>> getCategoryMenu() async {
    // Implement existing logic
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

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

  @override
  Future<List<SubCategory>> getSubCategories(int categoryId) async {
    // Implement existing logic
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/api/categories_list/$categoryId/sub_categories/'),
      headers: {'Authorization': 'Bearer $token'},
    );

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

  @override
  Future<List<SubCategoryMenu>> getSubCategoriesMenu(int categoryId) async {
    // Implement existing logic
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/api/categories_list/$categoryId/sub_categories/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);

        if (!responseJson.containsKey('subcategories') || responseJson['subcategories'] == null) {
          throw Exception('⚠️ خطأ: لا توجد بيانات للفئات الفرعية');
        }

        final subcategoriesData = responseJson['subcategories'];

        if (subcategoriesData is List) {
          return subcategoriesData
              .map((json) => SubCategoryMenu.fromJson(json))
              .toList();
        } else {
          throw Exception('⚠️ خطأ: استجابة غير صحيحة من الخادم، البيانات ليست قائمة.');
        }
      } catch (e) {
        throw Exception('⚠️ خطأ أثناء معالجة الاستجابة: ${e.toString()}');
      }
    } else {
      throw Exception('⚠️ خطأ غير معروف: ${response.statusCode}');
    }
  }
}