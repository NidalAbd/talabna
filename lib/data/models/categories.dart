import 'dart:convert';

class Category {
  final int id;
  final Map<String, String> name;
  final bool isSuspended;

  Category({
    required this.id,
    required this.name,
    this.isSuspended = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: _parseNameField(json['name']),
      isSuspended: _parseBoolField(json['isSuspended']),
    );
  }

  // Helper method to parse name field
  static Map<String, String> _parseNameField(dynamic nameField) {
    if (nameField == null) return {};

    // If it's already a Map, convert to String values
    if (nameField is Map<String, dynamic>) {
      return Map<String, String>.from(nameField.map((key, value) =>
          MapEntry(key, value?.toString() ?? '')));
    }

    // If it's a JSON string, try to parse
    try {
      final parsedName = jsonDecode(nameField);
      if (parsedName is Map) {
        return Map<String, String>.from(parsedName.map((key, value) =>
            MapEntry(key.toString(), value?.toString() ?? '')));
      }
    } catch (e) {
      // If parsing fails, create a map with a single 'en' key
      return {'en': nameField.toString()};
    }

    // Fallback
    return {'en': nameField.toString()};
  }

  // Helper method to parse boolean fields
  static bool _parseBoolField(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    if (value is int) return value == 1;

    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }

    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isSuspended': isSuspended,
    };
  }
}

class SubCategory {
  final int id;
  final Map<String, String> name;
  final int categoryId;
  final bool isSuspended;

  SubCategory({
    required this.id,
    required this.name,
    required this.categoryId,
    this.isSuspended = false,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: Category._parseNameField(json['name']),
      categoryId: json['categories_id'] ?? json['categoryId'],
      isSuspended: Category._parseBoolField(json['isSuspended']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'isSuspended': isSuspended,
    };
  }
}

