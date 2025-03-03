import 'dart:convert';
import 'dart:convert';

class Category {
  final int id;
  final Map<String, String> name;
  final bool isSuspended; // Added isSuspended field

  Category({
    required this.id,
    required this.name,
    this.isSuspended = false, // Default to false
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final nameData = json['name'] is Map<String, dynamic>
        ? Map<String, String>.from(json['name'])
        : Map<String, String>.from(jsonDecode(json['name']));

    return Category(
      id: json['id'],
      name: nameData,
      isSuspended: json['isSuspended'] == 1 || json['isSuspended'] == true, // Handle both int and bool
    );
  }
}



class SubCategory {
  final int id;
  final Map<String, String> name; // Store name in different languages
  final int categoryId;
  final bool isSuspended; // Added isSuspended field

  SubCategory({
    required this.id,
    required this.name,
    required this.categoryId,
    this.isSuspended = false, // Default to false
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'] is Map<String, dynamic>
          ? Map<String, String>.from(json['name'])  // Directly cast if it's already a Map
          : Map<String, String>.from(jsonDecode(json['name'])), // Decode if it's a String
      categoryId: json['categories_id'],
      isSuspended: json['isSuspended'] == 1 || json['isSuspended'] == true, // Handle both int and bool
    );
  }
}


