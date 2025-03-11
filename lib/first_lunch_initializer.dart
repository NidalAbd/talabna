import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/data/repositories/categories_repository.dart';
import 'package:talbna/data/repositories/service_post_repository.dart';
import 'package:talbna/utils/debug_logger.dart';

import 'core/service_locator.dart';
import 'data/datasources/local/local_category_data_source.dart';
import 'data/datasources/local/local_service_post_data_source.dart';

class FirstLaunchInitializer {
  final SharedPreferences prefs;
  final CategoriesRepository categoriesRepository;
  final ServicePostRepository servicePostRepository;

  FirstLaunchInitializer({
    required this.prefs,
    required this.categoriesRepository,
    required this.servicePostRepository,
  });

  Future<void> initializeWithCacheClear() async {
    try {
      // Get repositories
      final localCategoryDataSource = serviceLocator<LocalCategoryDataSource>();

      // Clear cache if needed
      final prefs = await SharedPreferences.getInstance();
      final lastCacheClear = prefs.getInt('last_cache_clear');
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check if we need to clear cache (uncomment if you want to clear automatically)
      /*
    if (lastCacheClear == null ||
        DateTime.fromMillisecondsSinceEpoch(lastCacheClear)
            .difference(DateTime.now()).inDays > 7) {
      // Clear cache once a week
      await localCategoryDataSource.clearAllCache();
      await localServicePostDataSource.clearAllCache();

      // Record cache clear time
      await prefs.setInt('last_cache_clear', now);
    }
    */

      // For immediate fix, unconditionally clear cache once
      await localCategoryDataSource.clearAllCache();

      // Record cache clear time
      await prefs.setInt('last_cache_clear', now);

      DebugLogger.log('Cache initialization complete', category: 'INIT');
    } catch (e) {
      DebugLogger.log('Error in cache initialization: $e', category: 'INIT_ERROR');
    }
  }
  Future<void> initializeAppData() async {
    try {
      // Mark the start of initialization
      await prefs.setBool('is_initializing', true);

      // Step 1: Fetch and cache categories
      await _initializeCategories();

      // Step 2: Fetch and cache category menu
      await _initializeCategoryMenu();

      // Step 3: Fetch and cache default category service posts
      await _initializeDefaultCategoryPosts();

      // Step 4: Fetch and cache default category subcategories
      await _initializeDefaultCategorySubcategories();

      // Mark initialization complete
      await prefs.setBool('is_first_launch', false);
      await prefs.setBool('is_initializing', false);
      await prefs.setInt('last_initialization_timestamp', DateTime.now().millisecondsSinceEpoch);

      DebugLogger.log('First launch initialization completed successfully',
          category: 'INIT');
    } catch (e, stackTrace) {
      // Handle initialization errors
      DebugLogger.log('First launch initialization failed: $e\n$stackTrace',
          category: 'INIT_ERROR');

      // Reset initialization flags
      await prefs.setBool('is_initializing', false);
      await prefs.setBool('is_first_launch', true);

      // Rethrow to allow caller to handle
      rethrow;
    }
  }

  Future<void> _initializeCategories() async {
    try {
      final categories = await categoriesRepository.getCategories();
      DebugLogger.log('Fetched ${categories.length} categories during initialization',
          category: 'INIT');
    } catch (e) {
      DebugLogger.log('Failed to fetch categories: $e', category: 'INIT_ERROR');
      rethrow;
    }
  }

  Future<void> _initializeCategoryMenu() async {
    try {
      final categoryMenu = await categoriesRepository.getCategoryMenu();
      DebugLogger.log('Fetched ${categoryMenu.length} category menu items during initialization',
          category: 'INIT');
    } catch (e) {
      DebugLogger.log('Failed to fetch category menu: $e', category: 'INIT_ERROR');
      rethrow;
    }
  }

  Future<void> _initializeDefaultCategoryPosts() async {
    try {
      // Default to category 1 for initial posts
      final defaultCategory = 1;
      final servicePosts = await servicePostRepository.getServicePostsByCategory(
          categories: defaultCategory,
          page: 1
      );
      DebugLogger.log('Fetched ${servicePosts.length} service posts for category $defaultCategory during initialization',
          category: 'INIT');
    } catch (e) {
      DebugLogger.log('Failed to fetch default category service posts: $e', category: 'INIT_ERROR');
      rethrow;
    }
  }

  Future<void> _initializeDefaultCategorySubcategories() async {
    try {
      // Default to category 1 for initial subcategories
      final defaultCategory = 1;
      final subcategories = await categoriesRepository.getSubCategoriesMenu(defaultCategory);
      DebugLogger.log('Fetched ${subcategories.length} subcategories for category $defaultCategory during initialization',
          category: 'INIT');
    } catch (e) {
      DebugLogger.log('Failed to fetch default category subcategories: $e', category: 'INIT_ERROR');
      rethrow;
    }
  }

  // Check if app needs full initialization
  bool needsInitialization() {
    // Check if this is the first launch or initialization was interrupted
    final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    final isInitializing = prefs.getBool('is_initializing') ?? false;

    return isFirstLaunch || isInitializing;
  }

  // Optional: Reset initialization state if needed
  Future<void> resetInitializationState() async {
    await prefs.setBool('is_first_launch', true);
    await prefs.setBool('is_initializing', false);
    await prefs.remove('last_initialization_timestamp');
  }
}