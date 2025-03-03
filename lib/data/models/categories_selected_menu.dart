import 'dart:convert';
import 'package:talbna/data/models/photos.dart';

class SubCategoryMenu {
  final int id;
  final Map<String, String> name; // Store names as a map for multiple languages
  final int categoriesId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int servicePostsCount;
  final List<Photo> photos;
  final bool isSuspended; // Added isSuspended field

  SubCategoryMenu({
    required this.id,
    required this.name,
    required this.categoriesId,
    required this.createdAt,
    required this.updatedAt,
    required this.servicePostsCount,
    required this.photos,
    this.isSuspended = false, // Default to false
  });

  factory SubCategoryMenu.fromJson(Map<String, dynamic> json) {
    return SubCategoryMenu(
      id: json['id'],
      // Check if 'name' is a Map or a String and decode accordingly
      name: json['name'] is Map<String, dynamic>
          ? Map<String, String>.from(json['name'])  // Directly cast if it's already a Map
          : Map<String, String>.from(jsonDecode(json['name'])), // Decode if it's a String
      categoriesId: json['categories_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      servicePostsCount: json['service_posts_count'],
      photos: List<Photo>.from(
        json['photos'].map((photoJson) => Photo.fromJson(photoJson)),
      ),
      isSuspended: json['isSuspended'] == 1 || json['isSuspended'] == true, // Handle both int and bool
    );
  }
}