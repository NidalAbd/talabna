// lib/data/repositories/categories_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/data/datasources/category_data_source.dart';
import 'package:talbna/data/datasources/local/local_category_data_source.dart';
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/models/categories_selected_menu.dart';
import 'package:talbna/data/models/category_menu.dart';
import 'package:talbna/utils/debug_logger.dart';

import '../datasources/remote/remote_category_data_source.dart';

class CategoriesRepository {
  final CategoryDataSource remoteDataSource;
  final LocalCategoryDataSource localDataSource;

  CategoriesRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  static Future<CategoriesRepository> legacy() async {
    // Create direct instances of dependencies without service locator
    return CategoriesRepository(
      remoteDataSource: RemoteCategoryDataSource(),
      localDataSource: LocalCategoryDataSource(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
    );
  }

  Future<List<Category>> getCategories({bool forceRefresh = false}) async {
    try {
      // Check if we have valid cache and forceRefresh is false
      if (!forceRefresh && localDataSource.isCacheValid('cached_categories')) {
        final cachedCategories = await localDataSource.getCategories();
        if (cachedCategories.isNotEmpty) {
          DebugLogger.log('Returning cached categories', category: 'REPOSITORY');
          return cachedCategories;
        }
      }

      // Fetch fresh data from remote
      DebugLogger.log('Fetching categories from API', category: 'REPOSITORY');
      final remoteCategories = await remoteDataSource.getCategories();

      // Cache the new data
      await localDataSource.cacheCategories(remoteCategories);

      return remoteCategories;
    } catch (e) {
      DebugLogger.log('Error fetching categories from API: $e', category: 'REPOSITORY');

      // If remote fetch fails, try to return cached data
      final cachedCategories = await localDataSource.getCategories();
      if (cachedCategories.isNotEmpty) {
        DebugLogger.log('Returning cached categories after API error', category: 'REPOSITORY');
        return cachedCategories;
      }

      // If no cache, rethrow the error
      rethrow;
    }
  }

  Future<List<CategoryMenu>> getCategoryMenu({bool forceRefresh = false}) async {
    try {
      // Check if we have valid cache and forceRefresh is false
      if (!forceRefresh && localDataSource.isCacheValid('cached_category_menu')) {
        final cachedMenu = await localDataSource.getCategoryMenu();
        if (cachedMenu.isNotEmpty) {
          DebugLogger.log('Returning cached category menu', category: 'REPOSITORY');
          return cachedMenu;
        }
      }

      // Fetch fresh data from remote
      DebugLogger.log('Fetching category menu from API', category: 'REPOSITORY');
      final remoteMenu = await remoteDataSource.getCategoryMenu();

      // Cache the new data
      await localDataSource.cacheCategoryMenu(remoteMenu);

      return remoteMenu;
    } catch (e) {
      DebugLogger.log('Error fetching category menu from API: $e', category: 'REPOSITORY');

      // If remote fetch fails, try to return cached data
      final cachedMenu = await localDataSource.getCategoryMenu();
      if (cachedMenu.isNotEmpty) {
        DebugLogger.log('Returning cached category menu after API error', category: 'REPOSITORY');
        return cachedMenu;
      }

      // If no cache, rethrow the error
      rethrow;
    }
  }

  Future<List<SubCategory>> getSubCategories(int categoryId, {bool forceRefresh = false}) async {
    try {
      // Check if we have valid cache and forceRefresh is false
      if (!forceRefresh && localDataSource.isCacheValid('cached_subcategories_$categoryId')) {
        final cachedSubcategories = await localDataSource.getSubCategories(categoryId);
        if (cachedSubcategories.isNotEmpty) {
          DebugLogger.log('Returning cached subcategories for category $categoryId',
              category: 'REPOSITORY');
          return cachedSubcategories;
        }
      }

      // Fetch fresh data from remote
      DebugLogger.log('Fetching subcategories for category $categoryId from API',
          category: 'REPOSITORY');
      final remoteSubcategories = await remoteDataSource.getSubCategories(categoryId);

      // Cache the new data
      await localDataSource.cacheSubCategories(categoryId, remoteSubcategories);

      return remoteSubcategories;
    } catch (e) {
      DebugLogger.log('Error fetching subcategories from API: $e', category: 'REPOSITORY');

      // If remote fetch fails, try to return cached data
      final cachedSubcategories = await localDataSource.getSubCategories(categoryId);
      if (cachedSubcategories.isNotEmpty) {
        DebugLogger.log('Returning cached subcategories after API error',
            category: 'REPOSITORY');
        return cachedSubcategories;
      }

      // If no cache, rethrow the error
      rethrow;
    }
  }

  Future<List<SubCategoryMenu>> getSubCategoriesMenu(int categoryId, {bool forceRefresh = false}) async {
    try {
      // Check if we have valid cache and forceRefresh is false
      if (!forceRefresh && localDataSource.isCacheValid('cached_subcategory_menu_$categoryId')) {
        final cachedMenu = await localDataSource.getSubCategoriesMenu(categoryId);
        if (cachedMenu.isNotEmpty) {
          DebugLogger.log('Returning cached subcategory menu for category $categoryId',
              category: 'REPOSITORY');
          return cachedMenu;
        }
      }

      // Fetch fresh data from remote
      DebugLogger.log('Fetching subcategory menu for category $categoryId from API',
          category: 'REPOSITORY');
      final remoteMenu = await remoteDataSource.getSubCategoriesMenu(categoryId);

      // Cache the new data
      await localDataSource.cacheSubCategoriesMenu(categoryId, remoteMenu);

      return remoteMenu;
    } catch (e) {
      DebugLogger.log('Error fetching subcategory menu from API: $e', category: 'REPOSITORY');

      // If remote fetch fails, try to return cached data
      final cachedMenu = await localDataSource.getSubCategoriesMenu(categoryId);
      if (cachedMenu.isNotEmpty) {
        DebugLogger.log('Returning cached subcategory menu after API error',
            category: 'REPOSITORY');
        return cachedMenu;
      }

      // If no cache, rethrow the error
      rethrow;
    }
  }
}