// lib/blocs/category/subcategory_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/data/models/categories_selected_menu.dart';
import 'package:talbna/data/models/category_menu.dart';
import 'package:talbna/data/repositories/categories_repository.dart';
import 'package:talbna/data/datasources/local/local_category_data_source.dart';
import 'package:talbna/utils/debug_logger.dart';
import 'subcategory_event.dart';
import 'subcategory_state.dart';

class SubcategoryBloc extends Bloc<SubcategoryEvent, SubcategoryState> {
  final CategoriesRepository categoriesRepository;
  final LocalCategoryDataSource localDataSource;

  // Cache for subcategories by category ID
  final Map<int, List<SubCategoryMenu>> _subcategoryCache = {};

  // Cache for categories
  List<CategoryMenu>? _categoriesCache;

  // Track pending request categories to avoid duplicate requests
  final Set<int> _pendingCategories = {};

  // Flag to indicate if categories fetch is in progress
  bool _isFetchingCategories = false;

  SubcategoryBloc({
    required this.categoriesRepository,
    required this.localDataSource,
  }) : super(SubcategoryInitial()) {
    DebugLogger.log('SubcategoryBloc created: $hashCode', category: 'BLOC');

    on<FetchSubcategories>((event, emit) async {
      // First, check if we need to force refresh (skip memory cache)
      if (!event.forceRefresh) {
        // Check if we already have this category in memory cache
        if (_subcategoryCache.containsKey(event.categoryId)) {
          DebugLogger.log('Using memory-cached subcategories for category ${event.categoryId}',
              category: 'SUBCATEGORY_BLOC');

          // Emit brief loading state if requested (for UI consistency)
          if (event.showLoadingState) {
            emit(SubcategoryLoading());
            await Future.delayed(const Duration(milliseconds: 50));
          }

          emit(SubcategoryLoaded(_subcategoryCache[event.categoryId]!));
          return;
        }
      }

      // Not in memory cache or forcing refresh, check permanent storage
      if (!event.forceRefresh) {
        try {
          // Check if we have valid cache in local storage
          if (localDataSource.isCacheValid('cached_subcategory_menu_${event.categoryId}')) {
            final cachedSubcategories = await localDataSource.getSubCategoriesMenu(event.categoryId);

            if (cachedSubcategories.isNotEmpty) {
              DebugLogger.log('Using storage-cached subcategories for category ${event.categoryId}',
                  category: 'SUBCATEGORY_BLOC');

              // Update memory cache
              _subcategoryCache[event.categoryId] = cachedSubcategories;

              // Emit brief loading state if requested (for UI consistency)
              if (event.showLoadingState) {
                emit(SubcategoryLoading());
                await Future.delayed(const Duration(milliseconds: 50));
              }

              emit(SubcategoryLoaded(cachedSubcategories));

              // If we're not already fetching, get fresh data in background
              if (!_pendingCategories.contains(event.categoryId) && !event.forceRefresh) {
                _fetchAndUpdateSubcategories(event.categoryId, emit, false);
              }

              return;
            }
          } else {
            DebugLogger.log('No valid cache for subcategories category ${event.categoryId}',
                category: 'SUBCATEGORY_BLOC');
          }
        } catch (e) {
          // Error reading from local storage, we'll continue to fetch from API
          DebugLogger.log('Error reading subcategories from local storage: $e',
              category: 'SUBCATEGORY_BLOC');
        }
      }

      // Check if we're already fetching this category
      if (_pendingCategories.contains(event.categoryId)) {
        DebugLogger.log('Already fetching subcategories for category ${event.categoryId}',
            category: 'SUBCATEGORY_BLOC');
        return;
      }

      // Not in any cache, need to fetch
      if (event.showLoadingState) {
        emit(SubcategoryLoading());
      }

      await _fetchAndUpdateSubcategories(event.categoryId, emit, event.showLoadingState);
    });

    on<InitializeSubcategoryCache>((event, emit) async {
      try {
        DebugLogger.log('Initializing subcategory cache from local storage', category: 'SUBCATEGORY_BLOC');

        // Try to load categories from local storage
        if (localDataSource.isCacheValid('cached_category_menu')) {
          final cachedCategories = await localDataSource.getCategoryMenu();

          if (cachedCategories.isNotEmpty) {
            // Update memory cache
            _categoriesCache = cachedCategories;

            // Emit loaded state without loading indicator
            emit(CategoryLoaded(cachedCategories));

            DebugLogger.log('Initialized categories from cache: ${cachedCategories.length} items',
                category: 'SUBCATEGORY_BLOC');
          }
        }
      } catch (e) {
        DebugLogger.log('Error initializing subcategory cache: $e',
            category: 'SUBCATEGORY_BLOC');
        // Don't emit error state, as this is just pre-loading
      }
    });

    on<FetchCategories>((event, emit) async {
      // First, check if we need to force refresh (skip memory cache)
      if (!event.forceRefresh) {
        // Check if we already have categories in memory cache
        if (_categoriesCache != null) {
          DebugLogger.log('Using memory-cached categories', category: 'SUBCATEGORY_BLOC');

          // Emit brief loading state if requested (for UI consistency)
          if (event.showLoadingState) {
            emit(SubcategoryLoading());
            await Future.delayed(const Duration(milliseconds: 50));
          }

          emit(CategoryLoaded(_categoriesCache!));
          return;
        }
      }

      // Not in memory cache or forcing refresh, check permanent storage
      if (!event.forceRefresh) {
        try {
          // Check if we have valid cache in local storage
          if (localDataSource.isCacheValid('cached_category_menu')) {
            final cachedCategories = await localDataSource.getCategoryMenu();

            if (cachedCategories.isNotEmpty) {
              DebugLogger.log('Using storage-cached categories',
                  category: 'SUBCATEGORY_BLOC');

              // Update memory cache
              _categoriesCache = cachedCategories;

              // Emit brief loading state if requested (for UI consistency)
              if (event.showLoadingState) {
                emit(SubcategoryLoading());
                await Future.delayed(const Duration(milliseconds: 50));
              }

              emit(CategoryLoaded(cachedCategories));

              // If we're not already fetching, get fresh data in background
              if (!_isFetchingCategories && !event.forceRefresh) {
                _fetchAndUpdateCategories(emit, false);
              }

              return;
            }
          }
        } catch (e) {
          // Error reading from local storage, we'll continue to fetch from API
          DebugLogger.log('Error reading categories from local storage: $e',
              category: 'SUBCATEGORY_BLOC');
        }
      }

      // Avoid duplicate requests
      if (_isFetchingCategories) {
        DebugLogger.log('Already fetching categories', category: 'SUBCATEGORY_BLOC');
        return;
      }

      if (event.showLoadingState) {
        emit(SubcategoryLoading());
      }

      await _fetchAndUpdateCategories(emit, event.showLoadingState);
    });

    on<ClearSubcategoryCache>((event, emit) async {
      if (event.categoryId != null) {
        // Clear specific category from memory cache
        _subcategoryCache.remove(event.categoryId);

        // Also clear from local storage
        try {
          final prefs = await localDataSource.sharedPreferences;
          prefs.remove('cached_subcategory_menu_${event.categoryId}');
          prefs.remove('cached_subcategory_menu_${event.categoryId}_timestamp');
        } catch (e) {
          DebugLogger.log('Error clearing subcategory cache from storage: $e',
              category: 'SUBCATEGORY_BLOC');
        }

        DebugLogger.log('Cleared subcategory cache for category ${event.categoryId}',
            category: 'SUBCATEGORY_BLOC');
      } else {
        // Clear all cache from memory
        _subcategoryCache.clear();
        _categoriesCache = null;

        // Also clear from local storage
        try {
          final prefs = await localDataSource.sharedPreferences;
          // Find all subcategory keys
          final keys = prefs.getKeys().where(
                  (key) => key.startsWith('cached_subcategory_menu_') ||
                  key.startsWith('cached_category_menu')
          ).toList();

          // Remove all those keys
          for (final key in keys) {
            prefs.remove(key);
          }
        } catch (e) {
          DebugLogger.log('Error clearing all subcategory cache from storage: $e',
              category: 'SUBCATEGORY_BLOC');
        }

        DebugLogger.log('Cleared all subcategory cache', category: 'SUBCATEGORY_BLOC');
      }
    });

    on<PrefetchSubcategories>((event, emit) async {
      for (final categoryId in event.categoryIds) {
        // Skip if already in cache or being fetched
        if (_subcategoryCache.containsKey(categoryId) || _pendingCategories.contains(categoryId)) {
          continue;
        }

        _pendingCategories.add(categoryId);

        try {
          DebugLogger.log('Prefetching subcategories for category $categoryId',
              category: 'SUBCATEGORY_BLOC');

          final subcategories = await categoriesRepository.getSubCategoriesMenu(categoryId);

          // Store in memory cache
          _subcategoryCache[categoryId] = subcategories;

          // Also store in local storage
          try {
            await localDataSource.cacheSubCategoriesMenu(categoryId, subcategories);
          } catch (e) {
            DebugLogger.log('Error caching subcategories to local storage: $e',
                category: 'SUBCATEGORY_BLOC');
          }

          _pendingCategories.remove(categoryId);

          DebugLogger.log('Prefetched ${subcategories.length} subcategories for category $categoryId',
              category: 'SUBCATEGORY_BLOC');
        } catch (e) {
          _pendingCategories.remove(categoryId);
          DebugLogger.log('Error prefetching subcategories for category $categoryId: $e',
              category: 'SUBCATEGORY_BLOC');
        }
      }
    });
  }

  // Helper method to fetch subcategories from API and update caches
  Future<void> _fetchAndUpdateSubcategories(
      int categoryId,
      Emitter<SubcategoryState> emit,
      bool emitState
      ) async {
    _pendingCategories.add(categoryId);

    try {
      final stopwatch = Stopwatch()..start();
      final List<SubCategoryMenu> subcategories =
      await categoriesRepository.getSubCategoriesMenu(categoryId);
      stopwatch.stop();

      DebugLogger.log(
          'Fetched ${subcategories.length} subcategories for category $categoryId in ${stopwatch.elapsedMilliseconds}ms',
          category: 'SUBCATEGORY_BLOC');

      // Store in memory cache
      _subcategoryCache[categoryId] = subcategories;

      // Also store in local storage
      try {
        await localDataSource.cacheSubCategoriesMenu(categoryId, subcategories);
      } catch (e) {
        DebugLogger.log('Error caching subcategories to local storage: $e',
            category: 'SUBCATEGORY_BLOC');
      }

      _pendingCategories.remove(categoryId);

      // Only emit if requested
      if (emitState) {
        emit(SubcategoryLoaded(subcategories));
      }
    } catch (e) {
      _pendingCategories.remove(categoryId);
      DebugLogger.log('Error fetching subcategories: $e', category: 'SUBCATEGORY_BLOC');

      // Only emit error if requested
      if (emitState) {
        emit(SubcategoryError(e.toString()));
      }
    }
  }

  // Helper method to fetch categories from API and update caches
  Future<void> _fetchAndUpdateCategories(
      Emitter<SubcategoryState> emit,
      bool emitState
      ) async {
    _isFetchingCategories = true;

    try {
      final stopwatch = Stopwatch()..start();
      final List<CategoryMenu> categories = await categoriesRepository.getCategoryMenu();
      stopwatch.stop();

      DebugLogger.log(
          'Fetched ${categories.length} categories in ${stopwatch.elapsedMilliseconds}ms',
          category: 'SUBCATEGORY_BLOC');

      // Store in memory cache
      _categoriesCache = categories;

      // Also store in local storage
      try {
        await localDataSource.cacheCategoryMenu(categories);
      } catch (e) {
        DebugLogger.log('Error caching categories to local storage: $e',
            category: 'SUBCATEGORY_BLOC');
      }

      _isFetchingCategories = false;

      // Only emit if requested
      if (emitState) {
        emit(CategoryLoaded(categories));
      }
    } catch (e) {
      _isFetchingCategories = false;
      DebugLogger.log('Error fetching categories: $e', category: 'SUBCATEGORY_BLOC');

      // Only emit error if requested
      if (emitState) {
        emit(SubcategoryError(e.toString()));
      }
    }
  }

  // Public method to prefetch subcategories
  Future<void> prefetchSubcategories(List<int> categoryIds) async {
    add(PrefetchSubcategories(categoryIds));
  }

  @override
  Future<void> close() {
    DebugLogger.log('SubcategoryBloc closed: $hashCode', category: 'BLOC');
    return super.close();
  }
}