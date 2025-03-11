import 'dart:convert';
import 'package:talbna/data/models/photos.dart';

class CategoryMenu {
  final int id;
  final dynamic name; // Changed to dynamic to handle both String and Map
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSuspended;
  final List<Photo> photos;

  CategoryMenu({
    required this.id,
    required this.name,
    this.isSuspended = false,
    required this.createdAt,
    required this.updatedAt,
    required this.photos,
  });

  factory CategoryMenu.fromJson(Map<String, dynamic> json) {
    return CategoryMenu(
      id: json['id'],
      name: parseNameField(json['name']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      isSuspended: parseBoolField(json['isSuspended']),
      photos: parsePhotos(json['photos']),
    );
  }

  // Helper method to parse name field - now returns dynamic to handle both string and map cases
  static dynamic parseNameField(dynamic nameField) {
    if (nameField == null) return '';

    // If it's a map, return it as is
    if (nameField is Map) {
      return nameField;
    }

    // If it's a JSON string, try to parse
    if (nameField is String) {
      try {
        final parsedName = jsonDecode(nameField);
        if (parsedName is Map) {
          return parsedName;
        }
      } catch (e) {
        // If parsing fails, return the original string
        return nameField;
      }
    }

    return nameField.toString();
  }

  // Helper method to parse date time
  static DateTime parseDateTime(dynamic dateField) {
    if (dateField == null) return DateTime.now();

    try {
      return dateField is DateTime
          ? dateField
          : DateTime.parse(dateField.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  // Helper method to parse boolean fields
  static bool parseBoolField(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    if (value is int) return value == 1;

    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }

    return false;
  }

  // Helper method to parse photos
  static List<Photo> parsePhotos(dynamic photosField) {
    if (photosField == null) return [];

    try {
      if (photosField is List) {
        return photosField
            .map((photoJson) => Photo.fromJson(photoJson))
            .toList()
            .cast<Photo>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // Convert DateTime to string before JSON encoding
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSuspended': isSuspended,
      'photos': photos.map((photo) => photo.toJson()).toList(),
    };
  }

  // Get display name that works with both String and Map
  String getDisplayName({String locale = 'en'}) {
    // If name is a Map
    if (name is Map) {
      // First try to get the requested locale
      final Map nameMap = name as Map;
      if (nameMap.containsKey(locale) && nameMap[locale] != null) {
        return nameMap[locale].toString();
      }

      // Then try English as fallback
      if (nameMap.containsKey('en') && nameMap['en'] != null) {
        return nameMap['en'].toString();
      }

      // Lastly, use first available value
      if (nameMap.isNotEmpty) {
        for (final value in nameMap.values) {
          if (value != null) {
            return value.toString();
          }
        }
      }

      // Nothing found
      return "Category $id";
    }

    // If name is already a simple string, return it
    return name.toString();
  }
}

// Helper method to create a CategoryMenu with minimal parameters
CategoryMenu createSimpleCategoryMenu(int id, dynamic name) {
  return CategoryMenu(
    id: id,
    name: name,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    photos: [],
  );
}