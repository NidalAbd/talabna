import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:http/http.dart' as http;
import 'package:talbna/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/debug_logger.dart';

class ServicePostRepository {
  static const String _baseUrl = Constants.apiBaseUrl;
  Future<List<ServicePost>> getAllServicePosts() async {
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
    DebugLogger.log('Fetching service post with ID: $id', category: 'SERVICE_POST');

    try {
      final url = '$_baseUrl/api/service_posts/$id';
      DebugLogger.log('API URL: $url', category: 'SERVICE_POST');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      DebugLogger.log('API Response Status: ${response.statusCode}', category: 'SERVICE_POST');
      DebugLogger.log('API Response Body: ${response.body.substring(0, 200)}...', category: 'SERVICE_POST');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        DebugLogger.log('Parsed JSON keys: ${json.keys.toList()}', category: 'SERVICE_POST');

        if (json.containsKey('servicePostShow')) {
          return ServicePost.fromJson(json['servicePostShow']);
        } else {
          throw Exception('API response missing servicePostShow key');
        }
      } else if (response.statusCode == 404) {
        throw Exception('هذا المنشور غير موجود');
      } else {
        throw Exception('فشل في تحميل المنشةر: ${response.statusCode}');
      }
    } catch (e) {
      DebugLogger.log('Error fetching post: $e', category: 'SERVICE_POST');
      throw Exception('$eخطا الاتصال في الخادم - المنشورات ');
    }
  }
  Future<List<ServicePost>> getServicePostsForReals(
      { required int page}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/service_posts/reels?page=$page'),
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

  Future<List<ServicePost>> getServicePostsByCategory(
      {required int categories, required int page}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final uri = Uri.parse('$_baseUrl/api/service_posts/categories/$categories?page=$page');
      print('Requesting URL: $uri'); // Debugging line to check the URL

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}'); // Debugging line to check response

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
      print('Error: $e'); // This will print the specific error
      throw Exception('Failed to connect to server');
    }
  }


  Future<List<ServicePost>> getServicePostsByUserFavourite(
      {required int userId, required int page}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

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
        print('🔍 API Response: ${response.body}');

        return servicePosts;
      } else {
        throw Exception('Failed to load service posts for this category');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }


  Future<bool> updateServicePostBadge(ServicePost servicePost, int servicePostID) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

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
        return true;
      }else if (response.statusCode == 400) {
        throw Exception(response.body.toString());
        return true;

      }else {
        return false;
        throw Exception(
          'Error updating service post: ${response.reasonPhrase}. Response body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
  Future<bool> updateServicePostCategory(ServicePost servicePost, int servicePostID) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Create a Map object
    Map<String, String> formData = {
      'category': servicePost.category?.id.toString() ?? 'null', // ✅ Extract name instead of object
      'subCategory': servicePost.subCategory?.id.toString() ?? 'null',
    };

    // Encode formData as a query string
    String encodedFormData = Uri(queryParameters: formData).query;
    // Send the request
    try {
      final url = '$_baseUrl/api/service_posts/ChangeCategories/$servicePostID';
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      print('🔵 [HTTP PUT Request]');
      print('➡️ URL: $url');
      print('📩 Headers: $headers');
      print('📝 Body: $encodedFormData');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: encodedFormData,
      ).timeout(const Duration(seconds: 30));

      print('🔵 [Response Received]');
      print('✅ Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          '❌ Error updating service post: ${response.reasonPhrase}. Response body: ${response.body}',
        );
      }
    } catch (e) {
      return false;
      throw Exception('Error occurred: $e');
    }

  }

  Future<ServicePost> createServicePost(ServicePost servicePost, List<http.MultipartFile> imageFiles) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
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
    request.fields['badgeDuration'] = servicePost.badgeDuration.toString() ?? 'null';
    request.fields['categories_id'] = servicePost.category?.id.toString() ?? 'null';
    request.fields['sub_categories_id'] = servicePost.subCategory!.id.toString() ?? 'null';
    if (imageFiles.isNotEmpty) {
      request.files.addAll(imageFiles);
    }

    print(imageFiles);
    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseMap = jsonDecode(responseBody);
        final Map<String, dynamic> servicePostData = responseMap['data'];

        print('Response: $servicePostData');

        // Create ServicePost from the 'data' section
        ServicePost servicePost = ServicePost.fromJson(servicePostData);

        // Additional logging if needed
        print('categories_id: ${servicePostData['categories_id']}');
        print('Service Post Category: ${servicePostData['category']}');

        return servicePost;
      }else if (response.statusCode == 400 ) {
        print(  'error : $responseBody',);
        throw Exception(
          'error : $responseBody',

        );
      }  else {
        print( 'Error creating service post: ${response.reasonPhrase}. Response body: $responseBody');
        throw Exception(
            'Error creating service post: ${response.reasonPhrase}. Response body: $responseBody');
      }
    } catch (e) {
      print('Error occurred: $e');

      throw Exception('Error occurred: $e');
    }
  }

  Future<bool> updateServicePost(
      ServicePost servicePost, List<Photo> photos) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST', // Use POST method with _method field for PUT
        Uri.parse('$_baseUrl/api/service_posts/${servicePost.id}'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add form fields
      request.fields.addAll({
        '_method': 'PUT', // This simulates a PUT request
        'id': servicePost.id.toString(),
        'title': servicePost.title ?? '',
        'description': servicePost.description ?? '',
        'price': servicePost.price.toString(),
        'priceCurrency': servicePost.priceCurrency ?? '',
        'locationLatitudes': servicePost.locationLatitudes.toString(),
        'locationLongitudes': servicePost.locationLongitudes.toString(),
        'userId': servicePost.userId.toString(),
        'type': servicePost.type ?? '',
        'categories_id': servicePost.category?.id.toString() ?? '',
        'sub_categories_id': servicePost.subCategory?.id.toString() ?? '',
      });

      // Add image files
      for (var photo in photos) {
        // Only add new photos (ones without an ID)
        if (photo.id == null && photo.src != null) {
          final file = File(photo.src!);
          if (await file.exists()) {
            final filename = file.path.split('/').last;
            final stream = http.ByteStream(file.openRead());
            final length = await file.length();

            final multipartFile = http.MultipartFile(
              'images[]', // Make sure this matches your Laravel field name
              stream,
              length,
              filename: filename,
              // Set content type based on whether it's a video or image
              contentType: photo.isVideo ?? false
                  ? MediaType('video', 'mp4')
                  : MediaType('image', 'jpeg'),
            );

            request.files.add(multipartFile);
          }
        }
      }

      // Send the request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      // Get the response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(
          'Validation error: ${errorData['errors'] ?? response.body}',
        );
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
