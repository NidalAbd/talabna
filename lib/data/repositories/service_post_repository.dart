import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http_parser/http_parser.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:http/http.dart' as http;
import 'package:talbna/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicePostRepository {
  static const String _baseUrl = Constants.apiBaseUrl;

  Future<List<ServicePost>> getAllServicePosts() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/service_posts'));

      if (response.statusCode == 200) {
        final List<ServicePost> servicePosts = [];
        final List<dynamic> data = jsonDecode(response.body);
        for (var element in data) {
          servicePosts.add(ServicePost.fromJson(element));
        }

        return servicePosts;
      } else {
        throw Exception('فشل في تحميل المنشورات');
      }
    } catch (e) {
      throw Exception('خطا الاتصال في الخادم - المنشورات');
    }
  }

  Future<ServicePost> getServicePostById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/service_posts/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServicePost.fromJson(jsonDecode(response.body)['servicePostShow']);
      } else if (response.statusCode == 404) {
        throw Exception('هذا المنشور غير موجود');
      } else {
        throw Exception('فشل في تحميل المنشةر');
      }
    } catch (e) {
      throw Exception('$eخطا الاتصال في الخادم - المنشورات ');
    }
  }

  Future<List<ServicePost>> getServicePostsByCategory(
      {required int categories, required int page}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/service_posts/categories/$categories?page=$page'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody['servicePosts']['data'];
        final List<ServicePost> servicePosts =
            data.map((e) => ServicePost.fromJson(e)).toList();
        return servicePosts;
      } else {
        throw Exception('Failed to load service posts for this category');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to connect to server ');
    }
  }

  Future<List<ServicePost>> getServicePostsByUserFavourite(
      {required int userId, required int page}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/service_posts/users/$userId/favorite?page=$page'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody['servicePosts']['data'];
        final List<ServicePost> servicePosts =
        data.map((e) => ServicePost.fromJson(e)).toList();
        return servicePosts;
      } else {
        throw Exception('Failed to load favorite service posts for this user');
      }
    } catch (e) {
      print(e);

      throw Exception('Failed to connect to server');
    }
  }

  Future<List<ServicePost>> getServicePostsByUserId(
      {required int userId, required int page}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/service_posts/user/$userId?page=$page'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody['servicePosts']['data'];
        final List<ServicePost> servicePosts =
            data.map((e) => ServicePost.fromJson(e)).toList();
        return servicePosts;
      } else {
        throw Exception('Failed to load service posts for this user');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }

  Future<List<ServicePost>> getServicePostsByCategorySubCategory({required int categories, required int subCategories,
      required int page}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/service_posts/categories/$categories/sub_categories/$subCategories?page=$page'),
             headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody['servicePosts']['data'];
        final List<ServicePost> servicePosts =
        data.map((e) => ServicePost.fromJson(e)).toList();

        return servicePosts;
      } else {
        throw Exception('Failed to load service posts for this category');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }


  Future<ServicePost> updateServicePostBadge(ServicePost servicePost, int servicePostID) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    // Create a Map object
    Map<String, String> formData = {
      'haveBadge': servicePost.haveBadge?? 'null',
      'badgeDuration': servicePost.badgeDuration.toString(),
    };
    // Encode formData as a query string
    String encodedFormData = Uri(queryParameters: formData).query;
    // Send the request
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/service_posts/ChangeBadge/$servicePostID'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: encodedFormData,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServicePost.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Error updating service post: ${response.reasonPhrase}. Response body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
  Future<ServicePost> updateServicePostCategory(ServicePost servicePost, int servicePostID) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    // Create a Map object
    Map<String, String> formData = {
      'category': servicePost.category ?? 'null',
      'subCategory': servicePost.subCategory ?? 'null',
    };
    // Encode formData as a query string
    String encodedFormData = Uri(queryParameters: formData).query;
    // Send the request
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/service_posts/ChangeCategories/$servicePostID'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: encodedFormData,
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServicePost.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Error updating service post: ${response.reasonPhrase}. Response body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<ServicePost> createServicePost(ServicePost servicePost, List<http.MultipartFile> imageFiles) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    final request =
    http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/service_posts'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    request.fields['title'] = servicePost.title?? 'null';
    request.fields['description'] = servicePost.description?? 'null';
    request.fields['price'] = servicePost.price.toString();
    request.fields['priceCurrency'] = servicePost.priceCurrency?? 'null';
    request.fields['locationLatitudes'] =
        servicePost.locationLatitudes.toString();
    request.fields['locationLongitudes'] =
        servicePost.locationLongitudes.toString();
    request.fields['userId'] = servicePost.userId.toString();
    request.fields['type'] = servicePost.type ?? 'null';
    request.fields['haveBadge'] = servicePost.haveBadge?? 'null';
    request.fields['badgeDuration'] = servicePost.badgeDuration.toString();
    request.fields['category'] = servicePost.category ?? 'null';
    request.fields['subCategory'] = servicePost.subCategory ?? 'null';
    if (imageFiles.isNotEmpty) {
      request.files.addAll(imageFiles);
    }
    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServicePost.fromJson(jsonDecode(responseBody));
      } else {
        throw Exception(
            'Error creating service post: ${response.reasonPhrase}. Response body: $responseBody');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<ServicePost> updateServicePost(
      ServicePost servicePost, List<http.MultipartFile> imageFiles) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    // Create a Map object
    Map<String, String> formData = {
      'id': servicePost.id.toString(),
      'title': servicePost.title?? 'null',
      'description': servicePost.description?? 'null',
      'price': servicePost.price.toString(),
      'priceCurrency': servicePost.priceCurrency?? 'null',
      'locationLatitudes': servicePost.locationLatitudes.toString(),
      'locationLongitudes': servicePost.locationLongitudes.toString(),
      'userId': servicePost.userId.toString(),
      'type': servicePost.type?? 'null',
      'category': servicePost.category ?? 'null',
      'subCategory': servicePost.subCategory ?? 'null',
    };
    // Encode formData as a query string
    String encodedFormData = Uri(queryParameters: formData).query;
    // Send the request

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/service_posts/${servicePost.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: encodedFormData,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServicePost.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Error updating service post: ${response.reasonPhrase}. Response body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<void> deleteServicePost({required int servicePostId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token not found in shared preferences');
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/service_posts/$servicePostId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('هذا المنشور غير موجود');
      } else {
        throw Exception('خطا في حذف المنشور');
      }
    } catch (e) {
      throw Exception('خطا الاتصال في الخادم - المنشورات');
    }
  }

  Future<void> viewIncrementServicePost({required int servicePostId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token not found in shared preferences');
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/service_posts/incrementView/$servicePostId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('هذا المنشور غير موجود');
      } else {
        throw Exception('خطا في حذف المنشور');
      }
    } catch (e) {
      throw Exception('خطا الاتصال في الخادم - المنشورات');
    }
  }
  Future<bool> toggleFavoriteServicePost({required int servicePostId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token not found in shared preferences');
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/doFavourite/$servicePostId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_favorited'];
      } else {
        throw Exception('Error toggling favorite state');
      }
    } catch (e) {
      throw Exception('Server connection error - Posts');
    }
  }

  Future<bool> getFavourite({required int servicePostId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    if (token == null) {
      throw Exception('Token not found in shared preferences');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/getFavourite/$servicePostId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Return true if the response indicates that the post is favorited
        return true;
      } else if (response.statusCode == 404) {
        // Return false if the response indicates that the post is not favorited
        return false;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('خطا الاتصال في الخادم - المنشورات');
    }
  }

  Future<bool> updateServicePostImage(List<http.MultipartFile> imageFiles, {required int servicePostImageId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token not found in shared preferences');
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/service_posts/updatePhoto/$servicePostImageId'));

      request.headers['Authorization'] = 'Bearer $token';

      if (imageFiles.isNotEmpty) {
        request.files.addAll(imageFiles);
      }

      final response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 204) {

        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('خطا الاتصال في الخادم - المنشورات');
    }
  }


  Future<void> deleteServicePostImage({required int servicePostImageId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token not found in shared preferences');
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/service_posts/deletePhoto/$servicePostImageId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }else {
        throw Exception('خطا في حذف الصورة');
      }
    } catch (e) {
      throw Exception('خطا الاتصال في الخادم - المنشورات');
    }
  }
}
