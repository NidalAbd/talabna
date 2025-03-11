import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/data/datasources/category_data_source.dart';
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/models/categories_selected_menu.dart';
import 'package:talbna/data/models/category_menu.dart';
import 'package:talbna/utils/debug_logger.dart';

class LocalCategoryDataSource implements CategoryDataSource {
  final SharedPreferences sharedPreferences;

  LocalCategoryDataSource({required this.sharedPreferences});
  @override
  Future<List<Category>> getCategories() async {
    try {
      final jsonString = sharedPreferences.getString('cached_categories');
      if (jsonString != null) {
        final List<dynamic> categoriesJson = json.decode(jsonString);
        final categories = categoriesJson.map((json) {
          // Sanitize the JSON and then use fromJson method
          final sanitizedJson = _sanitizeCategoryJson(json);
          return Category.fromJson(sanitizedJson);
        }).toList();
        DebugLogger.log('Retrieved ${categories.length} categories from local storage',
            category: 'DATA_SOURCE');
        return categories;
      }
      return [];
    } catch (e) {
      DebugLogger.log('Error retrieving categories from local storage: $e',
          category: 'DATA_SOURCE');
      return [];
    }
  }
  @override
  Future<List<CategoryMenu>> getCategoryMenu() async {
    try {
      final jsonString = sharedPreferences.getString('cached_category_menu');
      if (jsonString != null) {
        final List<dynamic> categoriesJson = json.decode(jsonString);
        final categories = categoriesJson.map((json) {
          // Convert the sanitized JSON back to CategoryMenu
          final sanitizedJson = _sanitizeCategoryMenuJson(json);
          return CategoryMenu.fromJson(sanitizedJson);
        }).toList();
        DebugLogger.log('Retrieved ${categories.length} category menu items from local storage',
            category: 'DATA_SOURCE');
        return categories;
      }
      return [];
    } catch (e) {
      DebugLogger.log('Error retrieving category menu from local storage: $e',
          category: 'DATA_SOURCE');
      return [];
    }
  }

  @override
  Future<List<SubCategoryMenu>> getSubCategoriesMenu(int categoryId) async {
    try {
      final jsonString = sharedPreferences.getString('cached_subcategory_menu_$categoryId');
      if (jsonString != null) {
        final List<dynamic> subcategoriesJson = json.decode(jsonString);
        final subcategories = subcategoriesJson.map((json) {
          // Convert the sanitized JSON back to SubCategoryMenu
          final sanitizedJson = _sanitizeSubCategoryMenuJson(json);
          return SubCategoryMenu.fromJson(sanitizedJson);
        }).toList();
        DebugLogger.log('Retrieved ${subcategories.length} subcategory menu items for category $categoryId from local storage',
            category: 'DATA_SOURCE');
        return subcategories;
      }
      return [];
    } catch (e) {
      DebugLogger.log('Error retrieving subcategory menu from local storage: $e',
          category: 'DATA_SOURCE');
      return [];
    }
  }
  Future<void> cacheCategories(List<Category> categories) async {
    try {
      final sanitizedCategories = categories.map((c) {
        final jsonMap = c.toJson();
        return _sanitizeCategoryJson(jsonMap);
      }).toList();

      final String jsonString = json.encode(sanitizedCategories);
      await sharedPreferences.setString('cached_categories', jsonString);
      await sharedPreferences.setInt('cached_categories_timestamp',
          DateTime.now().millisecondsSinceEpoch);
      DebugLogger.log('Cached ${categories.length} categories to local storage',
          category: 'DATA_SOURCE');
    } catch (e) {
      DebugLogger.log('Error caching categories to local storage: $e',
          category: 'DATA_SOURCE');
    }
  }

  Future<void> cacheCategoryMenu(List<CategoryMenu> categories) async {
    try {
      final sanitizedCategories = categories.map((c) {
        // First convert to JSON
        final originalJson = c.toJson();
        // Then sanitize for storage
        final storableJson = _sanitizeForStorage(originalJson);
        // Finally, properly structure the data
        return _sanitizeCategoryMenuJson(storableJson);
      }).toList();

      final String jsonString = json.encode(sanitizedCategories);
      await sharedPreferences.setString('cached_category_menu', jsonString);
      await sharedPreferences.setInt('cached_category_menu_timestamp',
          DateTime.now().millisecondsSinceEpoch);
      DebugLogger.log('Cached ${categories.length} category menu items to local storage',
          category: 'DATA_SOURCE');
    } catch (e) {
      DebugLogger.log('Error caching category menu to local storage: $e',
          category: 'DATA_SOURCE');
    }
  }

  @override
  @override
  Future<List<SubCategory>> getSubCategories(int categoryId) async {
    try {
      final jsonString = sharedPreferences.getString('cached_subcategories_$categoryId');
      if (jsonString != null) {
        final List<dynamic> subcategoriesJson = json.decode(jsonString);
        final subcategories = subcategoriesJson.map((json) {
          // Sanitize the JSON and then use fromJson method
          final sanitizedJson = _sanitizeSubCategoryJson(json);
          return SubCategory.fromJson(sanitizedJson);
        }).toList();
        DebugLogger.log('Retrieved ${subcategories.length} subcategories for category $categoryId from local storage',
            category: 'DATA_SOURCE');
        return subcategories;
      }
      return [];
    } catch (e) {
      DebugLogger.log('Error retrieving subcategories from local storage: $e',
          category: 'DATA_SOURCE');
      return [];
    }
  }

  Future<void> cacheSubCategories(int categoryId, List<SubCategory> subcategories) async {
    try {
      final sanitizedSubcategories = subcategories.map((s) {
        final jsonMap = s.toJson();
        return _sanitizeSubCategoryJson(jsonMap);
      }).toList();

      final String jsonString = json.encode(sanitizedSubcategories);
      await sharedPreferences.setString('cached_subcategories_$categoryId', jsonString);
      await sharedPreferences.setInt('cached_subcategories_${categoryId}_timestamp',
          DateTime.now().millisecondsSinceEpoch);
      DebugLogger.log('Cached ${subcategories.length} subcategories for category $categoryId to local storage',
          category: 'DATA_SOURCE');
    } catch (e) {
      DebugLogger.log('Error caching subcategories to local storage: $e',
          category: 'DATA_SOURCE');
    }
  }

  Future<void> cacheSubCategoriesMenu(int categoryId, List<SubCategoryMenu> subcategories) async {
    try {
      final sanitizedSubcategories = subcategories.map((s) {
        // First convert to JSON
        final originalJson = s.toJson();
        // Then sanitize for storage
        final storableJson = _sanitizeForStorage(originalJson);
        // Finally, properly structure the data
        return _sanitizeSubCategoryMenuJson(storableJson);
      }).toList();

      final String jsonString = json.encode(sanitizedSubcategories);
      await sharedPreferences.setString('cached_subcategory_menu_$categoryId', jsonString);
      await sharedPreferences.setInt('cached_subcategory_menu_${categoryId}_timestamp',
          DateTime.now().millisecondsSinceEpoch);
      DebugLogger.log('Cached ${subcategories.length} subcategory menu items for category $categoryId to local storage',
          category: 'DATA_SOURCE');
    } catch (e) {
      DebugLogger.log('Error caching subcategory menu to local storage: $e',
          category: 'DATA_SOURCE');
    }
  }

  bool isCacheValid(String key, {int maxAgeMinutes = 60}) {
    final timestamp = sharedPreferences.getInt('${key}_timestamp');
    if (timestamp == null) return false;

    final lastUpdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return now.difference(lastUpdate).inMinutes <= maxAgeMinutes;
  }
  // Helper method to ensure all objects are JSON-serializable
  Map<String, dynamic> _sanitizeForStorage(Map<String, dynamic> json) {
    // Create a new map to hold the sanitized values
    final sanitized = <String, dynamic>{};

    // Process each entry in the JSON map
    json.forEach((key, value) {
      if (value == null) {
        // Null values are fine
        sanitized[key] = null;
      } else if (value is DateTime) {
        // Convert DateTime to ISO string
        sanitized[key] = value.toIso8601String();
      } else if (value is List) {
        // Recursively process lists
        sanitized[key] = _sanitizeListForStorage(value);
      } else if (value is Map) {
        // Recursively process maps
        sanitized[key] = _sanitizeForStorage(Map<String, dynamic>.from(value));
      } else {
        // Primitive values like String, int, bool are already serializable
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  // Helper method to sanitize lists
  List _sanitizeListForStorage(List list) {
    return list.map((item) {
      if (item == null) {
        return null;
      } else if (item is DateTime) {
        return item.toIso8601String();
      } else if (item is List) {
        return _sanitizeListForStorage(item);
      } else if (item is Map) {
        return _sanitizeForStorage(Map<String, dynamic>.from(item));
      } else {
        return item;
      }
    }).toList();
  }

  // Sanitization methods to handle potential serialization issues
  Map<String, dynamic> _sanitizeCategoryJson(Map<String, dynamic> json) {
    return _sanitizeJson(json, ['name', 'isSuspended']);
  }

  Map<String, dynamic> _sanitizeCategoryMenuJson(Map<String, dynamic> json) {
    final sanitized = _sanitizeJson(json, ['name', 'isSuspended', 'createdAt', 'updatedAt', 'photos']);

    // Ensure datetime fields are handled properly
    if (sanitized['createdAt'] is DateTime) {
      sanitized['createdAt'] = (sanitized['createdAt'] as DateTime).toIso8601String();
    }
    if (sanitized['updatedAt'] is DateTime) {
      sanitized['updatedAt'] = (sanitized['updatedAt'] as DateTime).toIso8601String();
    }

    return sanitized;
  }

  Map<String, dynamic> _sanitizeSubCategoryJson(Map<String, dynamic> json) {
    return _sanitizeJson(json, ['name', 'categoryId', 'isSuspended']);
  }

  Map<String, dynamic> _sanitizeSubCategoryMenuJson(Map<String, dynamic> json) {
    final sanitized = _sanitizeJson(json, [
      'name', 'categoriesId', 'createdAt', 'updatedAt',
      'servicePostsCount', 'photos', 'isSuspended'
    ]);

    // Ensure datetime fields are converted to strings
    if (sanitized['createdAt'] is DateTime) {
      sanitized['createdAt'] = (sanitized['createdAt'] as DateTime).toIso8601String();
    }
    if (sanitized['updatedAt'] is DateTime) {
      sanitized['updatedAt'] = (sanitized['updatedAt'] as DateTime).toIso8601String();
    }

    return sanitized;
  }

  Future<void> clearAllCache() async {
    try {
      DebugLogger.log('Clearing all cache data...', category: 'DATA_SOURCE');

      // Get all keys from SharedPreferences
      final keys = sharedPreferences.getKeys();

      // Filter cache-related keys
      final cacheKeys = keys.where((key) =>
      key.startsWith('cached_') ||
          key.endsWith('_timestamp') ||
          key.contains('category') ||
          key.contains('service_post')
      ).toList();

      // Remove each key
      for (final key in cacheKeys) {
        await sharedPreferences.remove(key);
      }

      DebugLogger.log('Cleared ${cacheKeys.length} cache entries', category: 'DATA_SOURCE');
    } catch (e) {
      DebugLogger.log('Error clearing cache: $e', category: 'DATA_SOURCE');
    }
  }


  // Generic JSON sanitization method
  Map<String, dynamic> _sanitizeJson(
      Map<String, dynamic> json,
      List<String> keysToPreserve
      ) {
    final sanitizedJson = <String, dynamic>{};

    json.forEach((key, value) {
      if (keysToPreserve.contains(key)) {
        // Handle specific type conversions
        if (value is double) {
          sanitizedJson[key] = value.toString();
        } else if (value is List) {
          sanitizedJson[key] = value.map((item) {
            if (item is double) return item.toString();
            if (item is DateTime) return item.toIso8601String();
            return item;
          }).toList();
        } else if (value is DateTime) {
          sanitizedJson[key] = value.toIso8601String();
        } else {
          sanitizedJson[key] = value;
        }
      }
    });

    return sanitizedJson;
  }
}