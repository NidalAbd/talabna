import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/data/models/comment.dart';

import '../../utils/constants.dart';

class CommentRepository {
  static const String _baseUrl = Constants.apiBaseUrl;

  Future<List<Comments>> fetchComments({required int postId, int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');


    final response = await http.get(
        Uri.parse('$_baseUrl/api/commentsForPost/$postId?page=$page'),
        headers: {'Authorization': 'Bearer $token'}
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<Comments> comments = (data["data"] as List)
          .map((e) => Comments.fromJson(e))
          .toList();
      return comments;
    } else if (response.statusCode == 404) {
      throw Exception('Post not found');
    } else {
      print('Failed to load comments. Status Code: ${response.statusCode}. Response body: ${response.body}');
      throw Exception('Failed to load comments');
    }
  }


  Future<Comments> addComment(Comments comment , int page) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/comments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(comment.toJson()),
    );
    print(response.statusCode);
    if (response.statusCode == 201) {
      // Assuming the response body is empty and only the status code indicates success
      return comment; // Return the original comment object
    } else {
      throw Exception('Failed to add comment. Status Code: ${response.statusCode}');
    }

  }

  Future<Comments> updateComment(Comments comment, int page) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.put(
      Uri.parse('$_baseUrl/api/comments/${comment.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(comment.toJson()),
    );

    if (response.statusCode == 200) {
      return Comments.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update comment. Status Code: ${response.statusCode}');
    }
  }

  Future<void> deleteComment(int commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/comments/$commentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      // Comment deleted successfully
    } else {
      throw Exception('Failed to delete comment. Status Code: ${response.statusCode}');
    }
  }

}
