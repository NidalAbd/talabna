import 'dart:convert';
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

    final response = await http.get(
      Uri.parse('$baseUrl/api/categories_list/$categoryId/sub_categories/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);

        // Debugging: Print the structure of responseJson
        print('Response JSON: $responseJson');

        // ✅ Case 1: Check if 'subcategories' exists and is a List
        if (!responseJson.containsKey('subcategories') || responseJson['subcategories'] == null) {
          throw Exception('⚠️ خطأ: لا توجد بيانات للفئات الفرعية');
        }

        final subcategoriesData = responseJson['subcategories'];

        // ✅ Case 2: Check if subcategoriesData is a List
        if (subcategoriesData is List) {
          return subcategoriesData
              .map((json) => SubCategoryMenu.fromJson(json))
              .toList();
        } else {
          // If it's not a List, try printing its type for debugging
          throw Exception('⚠️ خطأ: استجابة غير صحيحة من الخادم، البيانات ليست قائمة. هي من النوع: ${subcategoriesData.runtimeType}');
        }
      } catch (e) {
        throw Exception('⚠️ خطأ أثناء معالجة الاستجابة: ${e.toString()}');
      }
    }else if (response.statusCode == 400) {
      throw Exception('❌ طلب غير صالح (400): تحقق من بيانات الإدخال.');
    } else if (response.statusCode == 401) {
      throw Exception('🔒 غير مصرح لك بالوصول (401): يرجى تسجيل الدخول.');
    } else if (response.statusCode == 403) {
      throw Exception('🚫 لا تملك الصلاحية (403): لا يمكنك الوصول إلى هذه البيانات.');
    } else if (response.statusCode == 404) {
      throw Exception('🔍 لم يتم العثور على الفئات الفرعية (404): تحقق من ID الفئة.');
    } else if (response.statusCode == 500) {
      throw Exception('🔥 خطأ في الخادم (500): يرجى المحاولة لاحقًا.');
    } else {
      throw Exception('⚠️ خطأ غير معروف: ${response.statusCode}');
    }
  }


}
