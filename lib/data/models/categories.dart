import 'dart:convert';

class Category {
  late int id;
  late String name;
  Category({required this.id, required this.name});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
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
      name: json['name'] is String
          ? Map<String, String>.from(jsonDecode(json['name'])) // Decode only if it's a String
          : Map<String, String>.from(json['name']), // Directly cast if already a Map
      categoryId: json['categories_id'],
    );
  }
}


