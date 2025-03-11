import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/category/subcategory_bloc.dart';
import 'package:talbna/blocs/category/subcategory_event.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/data/repositories/categories_repository.dart';
import 'package:talbna/data/datasources/local/local_category_data_source.dart';
import 'package:talbna/utils/debug_logger.dart';
import 'service_locator.dart';

/// Helper class to manage initialization of home screen data
/// Ensures cached data is loaded first, then refreshed in background
class HomeScreenInitializer {
  final BuildContext context;
  bool _isDisposed = false;

  HomeScreenInitializer(this.context);

  /// Initialize data for home screen with emphasis on loading categories first
  Future<void> initialize() async {
    final stopwatch = Stopwatch()..start();

    try {
      // Get necessary blocs
      final subcategoryBloc = BlocProvider.of<SubcategoryBloc>(context);

      // First priority: Load categories from cache - this is critical
      await _loadCategoriesFromStorage(subcategoryBloc);

      // Second priority: Load subcategories for main categories
      _preloadCommonSubcategories(subcategoryBloc);

      stopwatch.stop();
      DebugLogger.log('HomeScreenInitializer completed in ${stopwatch.elapsedMilliseconds}ms',
          category: 'INIT');
    } catch (e, stacktrace) {
      DebugLogger.log('Error initializing home screen: $e\n$stacktrace',
          category: 'INIT_ERROR');
    }
  }

  Future<void> _loadCategoriesFromStorage(SubcategoryBloc subcategoryBloc) async {
    if (_isDisposed) return;

    try {
      // Try to load from cache with high priority
      subcategoryBloc.add(FetchCategories(
        showLoadingState: false,
        forceRefresh: false, // Prioritize cache
      ));

      // Wait a bit to let the storage fetch complete
      await Future.delayed(const Duration(milliseconds: 100));

      DebugLogger.log('Requested categories from storage', category: 'INIT');
    } catch (e) {
      DebugLogger.log('Error requesting categories from storage: $e', category: 'INIT_ERROR');
    }
  }

  /// Alternative approach: Try to load directly from repository
  Future<void> _loadCategoriesDirectly() async {
    if (_isDisposed) return;

    try {
      // Get the repository directly
      final repository = serviceLocator<CategoriesRepository>();
      final localDataSource = serviceLocator<LocalCategoryDataSource>();

      // Check if we have valid cache first
      if (localDataSource.isCacheValid('cached_category_menu')) {
        final cachedCategories = await localDataSource.getCategories();
        DebugLogger.log('Loaded ${cachedCategories.length} categories directly from cache',
            category: 'INIT');
      } else {
        // Load categories from API and cache them
        final categories = await repository.getCategories(forceRefresh: true);
        DebugLogger.log('Loaded ${categories.length} categories directly from API',
            category: 'INIT');
      }
    } catch (e) {
      DebugLogger.log('Error directly loading categories: $e',
          category: 'INIT_ERROR');
    }
  }

  void _preloadCommonSubcategories(SubcategoryBloc subcategoryBloc) {
    if (_isDisposed) return;

    try {
      // Preload subcategories for the most common categories (1-4)
      for (int i = 1; i <= 4; i++) {
        subcategoryBloc.add(FetchSubcategories(
          categoryId: i,
          showLoadingState: false,
          forceRefresh: false, // Prioritize cache
        ));
      }

      DebugLogger.log('Preloading subcategories for common categories', category: 'INIT');
    } catch (e) {
      DebugLogger.log('Error preloading subcategories: $e', category: 'INIT_ERROR');
    }
  }

  /// Refresh data in background (call this after UI is visible)
  Future<void> refreshDataInBackground() async {
    try {
      if (_isDisposed) return;

      // Get necessary blocs
      final subcategoryBloc = BlocProvider.of<SubcategoryBloc>(context);
      final servicePostBloc = BlocProvider.of<ServicePostBloc>(context);

      // Refresh categories in background
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_isDisposed) return;

        subcategoryBloc.add(FetchCategories(
          showLoadingState: false,
          forceRefresh: true, // Now refresh from API
        ));
      });

      DebugLogger.log('Started background refresh of data', category: 'BACKGROUND_REFRESH');
    } catch (e) {
      DebugLogger.log('Error refreshing data in background: $e',
          category: 'BACKGROUND_REFRESH_ERROR');
    }
  }

  void dispose() {
    _isDisposed = true;
  }
}