import 'dart:convert';
class Category {
  final int id;
  final Map<String, String> name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final nameData = json['name'] is Map<String, dynamic>
        ? Map<String, String>.from(json['name'])
        : Map<String, String>.from(jsonDecode(json['name']));

    return Category(
      id: json['id'],
      name: nameData,
    );
  }
}



class SubCategory {
  final int id;
  final Map<String, String> name; // Store name in different languages
  final int categoryId;

  SubCategory({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'] is Map<String, dynamic>
          ? Map<String, String>.from(json['name'])  // Directly cast if it's already a Map
          : Map<String, String>.from(jsonDecode(json['name'])), // Decode if it's a String
      categoryId: json['categories_id'],
    );
  }
}



