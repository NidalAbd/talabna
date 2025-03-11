import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/home/home_screen_list_appBar_icon.dart';
import 'package:talbna/screens/reel/reels_screen.dart';
import 'package:talbna/screens/service_post/main_post_menu.dart';
import 'package:talbna/data/repositories/categories_repository.dart';
import '../../blocs/category/subcategory_bloc.dart';
import '../../blocs/category/subcategory_event.dart';
import '../../blocs/category/subcategory_state.dart';
import '../../blocs/service_post/service_post_event.dart';
import '../../core/home_screenI_initializer.dart';
import '../../core/service_locator.dart';
import '../../data/models/category_menu.dart';
import '../../data/datasources/local/local_category_data_source.dart';
import '../../utils/custom_routes.dart';
import '../../utils/debug_logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userId});
  final int userId;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // BLoC and Repository instances
  late UserProfileBloc _userProfileBloc;
  late ServicePostBloc _servicePostBloc;
  late CategoriesRepository _categoryRepository;
  final Language language = Language();
  late SubcategoryBloc _subcategoryBloc;

  // UI State
  bool showSubcategoryGridView = false;
  int _selectedCategory = 1;
  List<Category> _categories = [];
  bool isLoading = true;
  String currentLanguage = 'en';
  bool _justUpdated = false;
  bool _profileCompleted = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize controllers first
    _initializeControllers();

    // Force immediate category loading - this is now our primary method
    _forceDirectCategoryLoading();

    // Rest of initialization
    _initializeScreen();

    DebugLogger.printAllLogs();

    try {
      // Create initializer to manage caching
      final initializer = HomeScreenInitializer(context);
      initializer.initialize();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setSystemUIOverlayStyle();

        // After UI is displayed, refresh data in background
        Future.delayed(const Duration(milliseconds: 500), () {
          initializer.refreshDataInBackground();
        });
      });
    } catch (e) {
      DebugLogger.log('Error in home screen initialization: $e', category: 'INIT_ERROR');
    }
  }


// In HomeScreen.dart
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if we already have categories but are still showing loading
    if (isLoading && _categories.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When returning to this screen, we should not show loading if we already have categories
    if (isLoading && _categories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }
  void _forceDirectCategoryLoading() {
    if (!mounted) return;

    // If categories are already loaded, don't show loading state
    if (_categories.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    DebugLogger.log('Force-loading categories from storage first', category: 'CATEGORIES');

    // Show loading state temporarily
    setState(() {
      isLoading = true;
    });

    // Wait for controllers to be initialized
    Future.microtask(() async {
      try {
        _categoryRepository ??= serviceLocator<CategoriesRepository>();

        // Get the local data source
        final localDataSource = serviceLocator<LocalCategoryDataSource>();

        // FIRST: Try to load from local storage
        bool loadedFromCache = false;

        if (localDataSource.isCacheValid('cached_category_menu')) {
          try {
            final cachedCategories = await localDataSource.getCategories();

            if (cachedCategories.isNotEmpty && mounted) {
              // Filter out suspended categories
              final activeCategories = cachedCategories.where((category) => !category.isSuspended).toList();
              final arrangedCategories = _arrangeCategories(activeCategories);

              setState(() {
                _categories = arrangedCategories;
                isLoading = false;

                // Auto-select first category if no category is selected
                if (_selectedCategory == 0 && _categories.isNotEmpty) {
                  _selectedCategory = _categories.first.id;
                }
              });

              loadedFromCache = true;
              DebugLogger.log('Successfully loaded ${cachedCategories.length} categories from storage',
                  category: 'CATEGORIES');

              // Load service posts for the selected category
              if (_servicePostBloc != null && _selectedCategory > 0) {
                _servicePostBloc.add(
                  GetServicePostsByCategoryEvent(
                    _selectedCategory,
                    1,
                    forceRefresh: true, // Always get fresh posts from API
                  ),
                );
              }

              // Also fetch subcategories for the selected category from storage
              _loadSubcategoriesFromStorage(_selectedCategory);
            }
          } catch (e) {
            DebugLogger.log('Error loading categories from storage: $e', category: 'CATEGORIES');
            // We'll try from API next
          }
        }

        // SECOND: If storage failed, try API
        if (!loadedFromCache) {
          // Load categories directly from repository
          final categories = await _categoryRepository.getCategories(forceRefresh: true);

          if (mounted && categories.isNotEmpty) {
            // Filter out suspended categories
            final activeCategories = categories.where((category) => !category.isSuspended).toList();
            final arrangedCategories = _arrangeCategories(activeCategories);

            setState(() {
              _categories = arrangedCategories;
              isLoading = false;

              // Auto-select first category if no category is selected
              if (_selectedCategory == 0 && _categories.isNotEmpty) {
                _selectedCategory = _categories.first.id;
              }
            });

            DebugLogger.log('Successfully loaded ${categories.length} categories from API',
                category: 'CATEGORIES');

            // Load service posts for the selected category
            if (_servicePostBloc != null && _selectedCategory > 0) {
              _servicePostBloc.add(
                GetServicePostsByCategoryEvent(
                  _selectedCategory,
                  1,
                  forceRefresh: true, // Always get fresh posts from API
                ),
              );
            }
          } else {
            // If loading fails, ensure we're not stuck in loading state
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          }
        }

        // THIRD: Refresh categories in background if we showed cached data
        if (loadedFromCache && mounted) {
          _refreshCategoriesInBackground();
        }
      } catch (e) {
        DebugLogger.log('Error force-loading categories: $e', category: 'CATEGORIES');

        // Ensure we exit loading state
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        // Try one more fallback approach - use the bloc but only with FetchCategories
        if (mounted && _subcategoryBloc != null) {
          _subcategoryBloc.add(
            FetchCategories(
              showLoadingState: true,
              forceRefresh: true,
            ),
          );
        }
      }
    });

    // Safety timeout - no matter what, exit loading after 2 seconds
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && isLoading) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  // Helper method to load subcategories from storage
  Future<void> _loadSubcategoriesFromStorage(int categoryId) async {
    if (!mounted) return;

    try {
      final localDataSource = serviceLocator<LocalCategoryDataSource>();

      if (localDataSource.isCacheValid('cached_subcategory_menu_$categoryId')) {
        final cachedSubcategories = await localDataSource.getSubCategoriesMenu(categoryId);

        if (cachedSubcategories.isNotEmpty) {
          DebugLogger.log('Loaded ${cachedSubcategories.length} subcategories for category $categoryId from storage',
              category: 'SUBCATEGORIES');

          // Now that we have subcategories, tell the bloc about them
          if (_subcategoryBloc != null) {
            _subcategoryBloc.add(
              FetchSubcategories(
                  categoryId: categoryId,
                  showLoadingState: false,
                  forceRefresh: false
              ),
            );
          }
        }
      }
    } catch (e) {
      DebugLogger.log('Error loading subcategories from storage: $e', category: 'SUBCATEGORIES');
    }
  }

  // Helper method to refresh categories in background
  void _refreshCategoriesInBackground() {
    if (!mounted) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        if (_categoryRepository != null && mounted) {
          _categoryRepository.getCategories(forceRefresh: true).then((categories) {
            if (mounted && categories.isNotEmpty) {
              // Filter out suspended categories
              final activeCategories = categories.where((category) => !category.isSuspended).toList();
              final arrangedCategories = _arrangeCategories(activeCategories);

              setState(() {
                _categories = arrangedCategories;

                // Don't change the selected category here - that would disrupt the user
              });

              DebugLogger.log('Refreshed ${categories.length} categories in background',
                  category: 'CATEGORIES');
            }
          }).catchError((error) {
            DebugLogger.log('Error refreshing categories in background: $error',
                category: 'CATEGORIES');
          });
        }
      } catch (e) {
        DebugLogger.log('Exception in _refreshCategoriesInBackground: $e',
            category: 'CATEGORIES');
      }
    });
  }

  // Add this method to ensure categories are loaded
  void _ensureCategoriesLoaded() {
    if (!mounted) return;

    // Get the Bloc instances if not already initialized
    if (_subcategoryBloc == null) {
      _subcategoryBloc = BlocProvider.of<SubcategoryBloc>(context);
    }

    // Only show loading if categories are empty
    if (_categories.isEmpty) {
      setState(() {
        isLoading = true;
      });

      // Declare the subscription variable first
      late final StreamSubscription subscription;

      // Then initialize it
      subscription = _subcategoryBloc.stream.listen((state) {
        if (state is CategoryLoaded && mounted) {
          // Process categories when they're loaded
          _processCategoriesFromBloc(state, subscription);
        } else if (state is SubcategoryError && mounted) {
          // Exit loading state on error
          setState(() {
            isLoading = false;
          });
          subscription.cancel();

          // Try direct repository access as fallback
          _fetchCategoriesFallback();
        }
      });

      // Request categories from bloc - use cache first
      _subcategoryBloc.add(
        FetchCategories(
          showLoadingState: false,
          forceRefresh: false,
        ),
      );

      // Set a shorter timeout to exit loading state if nothing happens
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && isLoading && _categories.isEmpty) {
          DebugLogger.log('Category loading timeout, trying fallback', category: 'CATEGORIES');

          // Try fallback method if first attempt times out
          _fetchCategoriesFallback();

          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  Future<void> _initializeScreen() async {
    try {
      if (!mounted) return;

      await _loadLanguage();
      if (!mounted) return;

      // Use a cache-first strategy for initial data
      await _loadInitialDataFromCache();

      // Explicitly set loading to false if categories are already loaded
      if (_categories.isNotEmpty) {
        setState(() {
          isLoading = false;
        });
      }

      if (mounted) {
        _animationController.forward();
      }
    } catch (e, stackTrace) {
      DebugLogger.log('Initialization Error: $e\n$stackTrace', category: 'INIT');

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadInitialDataFromCache() async {
    if (!mounted) return;

    await _loadShowSubcategoryGridView();
    if (!mounted) return;

    // Get the Bloc instances
    _subcategoryBloc = BlocProvider.of<SubcategoryBloc>(context);
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);

    // Trigger loading categories from cache with force refresh = false
    _subcategoryBloc.add(
      FetchCategories(
        showLoadingState: false,  // Don't show loading indicator for cached data
        forceRefresh: false,      // Use cache first
      ),
    );

    // Load service posts for default category DIRECTLY FROM API
    _servicePostBloc.add(
      GetServicePostsByCategoryEvent(
        _selectedCategory,
        1,
        forceRefresh: true,  // Force API fetch
      ),
    );

    // Check if categories are already loaded
    if (_categories.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    } else {
      // Set a timeout to ensure loading state doesn't persist
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && isLoading) {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  // Apply consistent system UI colors
  void _setSystemUIOverlayStyle() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDarkMode ? AppTheme.darkPrimaryColor : Colors.white;
    final brightness = isDarkMode ? Brightness.light : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: barColor,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
      systemNavigationBarColor: barColor,
      systemNavigationBarIconBrightness: brightness,
    ));
  }

  void _initializeControllers() {
    if (!mounted) return;

    _userProfileBloc = BlocProvider.of<UserProfileBloc>(context);
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _categoryRepository = serviceLocator<CategoriesRepository>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _userProfileBloc.add(UserProfileRequested(id: widget.userId));
  }

  Future<void> _loadLanguage() async {
    if (!mounted) return;
    final lang = await language.getLanguage();
    if (mounted) {
      setState(() {
        currentLanguage = lang;
      });
    }
  }

  Future<void> _loadShowSubcategoryGridView() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        showSubcategoryGridView = prefs.getBool('showSubcategoryGridView') ?? false;
      });
    }
  }

  Future<void> _saveShowSubcategoryGridView(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showSubcategoryGridView', value);
  }

  Future<void> _toggleSubcategoryGridView({required bool canToggle}) async {
    if (!mounted) return;
    if (canToggle) {
      setState(() {
        showSubcategoryGridView = !showSubcategoryGridView;
      });
      await _saveShowSubcategoryGridView(showSubcategoryGridView);
    }
  }

  IconData _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1: return Icons.work_outline_rounded;
      case 2: return Icons.devices_rounded;
      case 3: return Icons.home_rounded;
      case 7: return Icons.play_circle_fill_rounded;
      case 4: return Icons.directions_car_rounded;
      case 5: return Icons.miscellaneous_services_rounded;
      case 6: return Icons.location_on_rounded;
      default: return Icons.work_outline_rounded;
    }
  }

  String _getCategoryName(Category category) {
    return category.name[currentLanguage] ?? category.name['en'] ?? 'Unknown';
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // First check if categories are already loaded in state
      if (_categories.isNotEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Get categories from repository with cache priority
      final categories = await _categoryRepository.getCategories(forceRefresh: false);

      if (!mounted) return;

      // Filter out suspended categories
      final activeCategories = categories.where((category) => !category.isSuspended).toList();
      final arrangedCategories = _arrangeCategories(activeCategories);

      if (mounted) {
        setState(() {
          _categories = arrangedCategories;
          isLoading = false;

          // Auto-select first category if no category is selected
          if (_selectedCategory == 0 && _categories.isNotEmpty) {
            _selectedCategory = _categories.first.id;
          }
        });

        // Also update the BLoC state to keep it in sync
        final subcategoryBloc = BlocProvider.of<SubcategoryBloc>(context);
        subcategoryBloc.add(FetchCategories(
          showLoadingState: false,
          forceRefresh: false,
        ));
      }
    } catch (e, stackTrace) {
      DebugLogger.log('Error fetching categories: $e\n$stackTrace', category: 'CATEGORIES');

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Add this method to process loaded categories
  void _processCategoriesFromBloc(CategoryLoaded state, StreamSubscription subscription) {
    // Convert CategoryMenu to Category objects if needed
    final categories = state.categories.map((menu) {
      // Create the proper name map from menu.name
      Map<String, String> nameMap = {};
      if (menu.name is Map) {
        // If it's already a map, convert it to the right format
        (menu.name as Map).forEach((key, value) {
          nameMap[key.toString()] = value?.toString() ?? '';
        });
      } else if (menu.name != null) {
        // If it's not a map but has a value, use it as the 'en' value
        nameMap['en'] = menu.name.toString();
      } else {
        // Fallback
        nameMap['en'] = 'Category ${menu.id}';
      }

      return Category(
          id: menu.id,
          name: nameMap,
          isSuspended: menu.isSuspended ?? false
      );
    }).toList();

    if (mounted) {
      setState(() {
        // Filter out suspended categories
        final activeCategories = categories.where((category) => !category.isSuspended).toList();
        _categories = _arrangeCategories(activeCategories);
        isLoading = false;

        // Auto-select first category if no category is selected
        if (_selectedCategory == 0 && _categories.isNotEmpty) {
          _selectedCategory = _categories.first.id;
        }
      });
    }

    // Cancel the subscription since we got what we needed
    subscription.cancel();

    // Log success
    DebugLogger.log('Loaded ${categories.length} categories through bloc', category: 'CATEGORIES');
  }

  // Add this fallback method to directly query the repository
  void _fetchCategoriesFallback() {
    DebugLogger.log('Using direct repository fallback for categories', category: 'CATEGORIES');

    if (_categoryRepository != null && mounted) {
      _categoryRepository.getCategories(forceRefresh: false).then((categories) {
        if (mounted && categories.isNotEmpty) {
          setState(() {
            // Filter out suspended categories
            final activeCategories = categories.where((category) => !category.isSuspended).toList();
            _categories = _arrangeCategories(activeCategories);

            // Auto-select first category if no category is selected
            if (_selectedCategory == 0 && _categories.isNotEmpty) {
              _selectedCategory = _categories.first.id;
            }
          });

          DebugLogger.log('Loaded ${categories.length} categories via fallback', category: 'CATEGORIES');
        }
      }).catchError((error) {
        DebugLogger.log('Error in categories fallback: $error', category: 'CATEGORIES');
      });
    }
  }
  // Fixed arrange method for Category objects (not CategoryMenu)
  List<Category> _arrangeCategories(List<Category> categories) {
    if (categories.isEmpty) {
      return [];
    }

    // Find reels category (id 7) safely
    Category? reelsCategory;
    try {
      reelsCategory = categories.firstWhere((category) => category.id == 7);
    } catch (e) {
      // No reels category found, that's okay
      reelsCategory = null;
    }

    // Filter categories that are not reels and sort them by ID
    final otherCategories = categories
        .where((category) => category.id != 7)
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    // If reels category exists, insert it in the middle
    if (reelsCategory != null) {
      final middleIndex = otherCategories.length ~/ 2;

      // Log the arrangement
      DebugLogger.log(
          'Arranging ${otherCategories.length} categories with reels in middle (index $middleIndex)',
          category: 'CATEGORIES'
      );

      return [
        ...otherCategories.sublist(0, middleIndex),
        reelsCategory,
        ...otherCategories.sublist(middleIndex),
      ];
    } else {
      return otherCategories;
    }
  }


  void _onCategorySelected(int categoryId, BuildContext context, User user) {
    if (!mounted) return;

    setState(() => _selectedCategory = categoryId);

    // Keep this condition - it prevents toggling for category 6 and 0
    if (categoryId == 6 || categoryId == 0) {
      _toggleSubcategoryGridView(canToggle: false);

      // For category 6, we'll handle the service post loading in MainMenuPostScreen
      // So no additional code needed here, the component will handle it
    }

    if (categoryId == 7) {
      _navigateToReels(context, user);
    }

    // Load service posts for the selected category
    if (_servicePostBloc != null && categoryId != 7) {
      _servicePostBloc.add(
        GetServicePostsByCategoryEvent(
          categoryId,
          1,
          forceRefresh: true, // Always use fresh posts from API
        ),
      );

      // Also load subcategories
      if (_subcategoryBloc != null) {
        _subcategoryBloc.add(
          FetchSubcategories(
            categoryId: categoryId,
            showLoadingState: false,
            forceRefresh: false, // Try cache first, then API
          ),
        );
      }
    }
  }

// Add this to your HomeScreen class (_HomeScreenState)

  Future<void> _navigateToReels(BuildContext context, User user) async {
    // Save the current selected category before navigation
    final previousCategory = _selectedCategory;

    // Set the UI state to indicate Reels is selected
    setState(() => _selectedCategory = 7);

    try {
      // Use the custom transition
      final route = ReelsRouteTransition(
        page: ReelsHomeScreen(
          userId: widget.userId,
          user: user,

        ),
      );

      // Push the route and wait for it to complete
      await Navigator.of(context).push(route);

      // After returning, restore the previous category (as backup in case onClose wasn't called)
      if (mounted) {
        setState(() => _selectedCategory = previousCategory != 7 ? previousCategory : 1);
      }
    } catch (e) {
      print('Error navigating to reels: $e');

      // If there's an error, reset to the previous category
      if (mounted) {
        setState(() => _selectedCategory = previousCategory != 7 ? previousCategory : 1);
      }
    }
  }

// Add this helper method to force a UI refresh when returning from Reels
  void _forceUIRefresh() {
    if (!mounted) return;

    // Schedule a UI refresh on the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          // No need to change any state variables, just trigger a rebuild
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _disposed = true;
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // On coming back to the app, clear loading state if categories exist
      if (isLoading && _categories.isNotEmpty) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    if (!mounted) return Container();

    // Ensure focus when the screen appears to detect coming back from another screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Additional safety check - always reset loading if we have categories
      if (isLoading && _categories.isNotEmpty) {
        setState(() {
          isLoading = false;
        });
      }
    });

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // UI colors setup
    final backgroundColor = isDarkMode ? AppTheme.darkPrimaryColor : Colors.white;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;
    final iconColor = isDarkMode ? AppTheme.darkIconColor : AppTheme.lightIconColor;

    // Make sure system colors are consistent with theme
    _setSystemUIOverlayStyle();

    return BlocConsumer<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        // Reset loading state after profile update
        if (state is UserProfileUpdateSuccess && mounted) {
          setState(() {
            isLoading = false;
          });
          _handleProfileUpdate();
        }

        // Always reset loading if we already have categories
        if (state is UserProfileLoadSuccess && isLoading && _categories.isNotEmpty) {
          setState(() {
            isLoading = false;
          });
        }

        // Only show loading indicator for empty categories
        if (state is UserProfileLoadInProgress && _categories.isEmpty) {
          setState(() {
            isLoading = true;
          });
        }
      },
      builder: (context, state) {
        if (!mounted) return Container();

        // Don't show loading if we already have categories
        if ((state is UserProfileLoadInProgress || state is UserProfileInitial) && _categories.isEmpty) {
          return _buildLoadingScreen(backgroundColor, primaryColor);
        }

        if (state is UserProfileLoadFailure) {
          return _buildErrorScreen(state.error, backgroundColor, primaryColor);
        }

        if (state is UserProfileLoadSuccess) {
          final user = state.user;

          // Only show loading if categories are empty
          if (isLoading && _categories.isEmpty) {
            return _buildMainScreenWithLoading(user, backgroundColor, primaryColor, textColor);
          }

          return _buildMainScreen(user, backgroundColor, primaryColor, textColor, iconColor);
        }

        return _buildEmptyScreen(backgroundColor);
      },
    );
  }

  void _handleProfileUpdate() {
    if (!mounted) return;

    setState(() {
      _justUpdated = true;
      _profileCompleted = true; // Mark profile as completed when it's updated
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _justUpdated = false;
        });
      }
    });

    _userProfileBloc.add(UserProfileRequested(id: widget.userId));
  }

  Widget _buildLoadingScreen(Color backgroundColor, Color primaryColor) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: CircularProgressIndicator(color: primaryColor),
      ),
    );
  }

  Widget _buildErrorScreen(String error, Color backgroundColor, Color primaryColor) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _userProfileBloc.add(UserProfileRequested(id: widget.userId)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen(Color backgroundColor) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: const Center(child: Text('No user home data found.')),
    );
  }

  // Add this method to show main screen with loading indicator for categories
  Widget _buildMainScreenWithLoading(User user, Color backgroundColor, Color primaryColor, Color textColor) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScreen(User user, Color backgroundColor, Color primaryColor, Color textColor, Color iconColor) {
    if (!mounted) return Container();

    // If categories are still loading, show a loading UI
    if (isLoading) {
      return _buildMainScreenWithLoading(user, backgroundColor, primaryColor, textColor);
    }

    // Check if we have categories after loading
    if (_categories.isEmpty) {
      return _buildEmptyCategoriesScreen(user, backgroundColor, primaryColor, textColor, iconColor);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(user, backgroundColor, primaryColor, textColor),
        body: _buildBody(user, backgroundColor),
        bottomNavigationBar: _buildBottomNavBar(user, backgroundColor, primaryColor, textColor, iconColor),
      ),
    );
  }

  Widget _buildEmptyCategoriesScreen(User user, Color backgroundColor, Color primaryColor, Color textColor, Color iconColor) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(user, backgroundColor, primaryColor, textColor),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 60, color: iconColor),
            const SizedBox(height: 16),
            Text(
              'No categories available',
              style: TextStyle(fontSize: 18, color: textColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Try to fetch categories again, this time force refresh
                if (_subcategoryBloc != null) {
                  _subcategoryBloc.add(
                    FetchCategories(
                      showLoadingState: true,
                      forceRefresh: true,
                    ),
                  );
                  setState(() {
                    isLoading = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(User user, Color backgroundColor, Color primaryColor, Color textColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fontFamily = GoogleFonts.poppins().fontFamily;

    // Use consistent accent color for logo
    final accentColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightSecondaryColor;

    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor,
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(8, 2, 0, 0),
        child: Row(
          children: [
            Text(
              'TALAB',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: accentColor,
              ),
            ),
            Text(
              'NA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
      actions: [
        VertIconAppBar(
          userId: widget.userId,
          user: user,
          showSubcategoryGridView: showSubcategoryGridView,
          toggleSubcategoryGridView: _toggleSubcategoryGridView,
        ),
      ],
    );
  }

  Widget _buildBody(User user, Color backgroundColor) {
    if (!mounted) return Container();

    if (_selectedCategory == 7) {
      return Container();
    }

    return Container(
      decoration: BoxDecoration(color: backgroundColor),
      child: MainMenuPostScreen(
        key: ValueKey(_selectedCategory),
        category: _selectedCategory,
        userID: widget.userId,
        servicePostBloc: _servicePostBloc,
        showSubcategoryGridView: showSubcategoryGridView,
        user: user,
      ),
    );
  }

  Widget _buildBottomNavBar(User user, Color backgroundColor, Color primaryColor, Color textColor, Color iconColor) {
    if (!mounted) return Container();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.06),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _categories.map((category) {
                  if (category.id == 7) {
                    return const SizedBox(width: 50);
                  }

                  bool isSelected = _selectedCategory == category.id;
                  return _buildNavItem(
                    category: category,
                    isSelected: isSelected,
                    user: user,
                    primaryColor: primaryColor,
                    iconColor: iconColor,
                    textColor: textColor,
                  );
                }).toList(),
              ),
            ),
            if (_hasReelsCategory)
              Positioned(
                top: 5,
                child: _buildReelsButton(
                  reelsCategory: _getReelsCategory()!,
                  user: user,
                  primaryColor: primaryColor,
                ),
              ),
            if (_hasReelsCategory)
              Positioned(
                bottom: 8,
                child: _buildReelsLabel(
                  reelsCategory: _getReelsCategory()!,
                  primaryColor: primaryColor,
                  textColor: textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool get _hasReelsCategory => _categories.any((c) => c.id == 7);

  Category? _getReelsCategory() {
    try {
      return _categories.firstWhere((c) => c.id == 7);
    } catch (e) {
      return null;
    }
  }

  Widget _buildNavItem({
    required Category category,
    required bool isSelected,
    required User user,
    required Color primaryColor,
    required Color iconColor,
    required Color textColor,
  }) {
    if (!mounted) return Container();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _onCategorySelected(category.id, context, user),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            decoration: isSelected
                ? BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            )
                : null,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            child: Icon(
              _getCategoryIcon(category.id),
              size: 25,
              color: isSelected ? primaryColor : iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getCategoryName(category),
            style: TextStyle(
              color: isSelected ? primaryColor : textColor,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReelsButton({
    required Category reelsCategory,
    required User user,
    required Color primaryColor,
  }) {
    if (!mounted) return Container();

    return GestureDetector(
      onTap: () => _onCategorySelected(reelsCategory.id, context, user),
      child: SizedBox(
        height: 40,
        width: 40,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.play_circle_fill_rounded,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReelsLabel({
    required Category reelsCategory,
    required Color primaryColor,
    required Color textColor,
  }) {
    if (!mounted) return Container();

    return AnimatedOpacity(
      opacity: _selectedCategory == 7 ? 1.0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Text(
        _getCategoryName(reelsCategory),
        style: TextStyle(
          color: _selectedCategory == 7 ? primaryColor : textColor,
          fontSize: 12,
          fontWeight: _selectedCategory == 7 ? FontWeight.w600 : FontWeight.normal,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
      ),
    );
  }
}