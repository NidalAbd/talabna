import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/category/subcategory_bloc.dart';
import 'package:talbna/blocs/category/subcategory_event.dart';
import 'package:talbna/blocs/category/subcategory_state.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/data/models/category_menu.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/service_post/main_post_menu.dart';
import 'package:talbna/utils/debug_logger.dart';

import '../widgets/shimmer_widgets.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.servicePostBloc, required this.userId, required this.user});
  final ServicePostBloc servicePostBloc;
  final int userId;
  final User user;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late SubcategoryBloc _subcategoryBloc;
  late bool showSubcategoryGridView = false;
  final int _selectedCategory = 1;
  CategoryMenu? selectedCategory; // Added

  // Safely arrange categories with proper error handling
  List<CategoryMenu> arrangeCategories(List<CategoryMenu> categories) {
    try {
      if (categories.isEmpty) {
        return [];
      }

      // Find reels category (id 7) if it exists
      CategoryMenu? reelsCategory;
      try {
        reelsCategory = categories.firstWhere((category) => category.id == 7);
      } catch (e) {
        // Reels category not found, will remain null
      }

      // Filter and sort other categories
      final otherCategories = categories
          .where((category) => category.id != 7)
          .toList();

      // Sort by ID numerically
      otherCategories.sort((a, b) => a.id.compareTo(b.id));

      // If reels category exists, insert it in the middle
      if (reelsCategory != null) {
        final middleIndex = otherCategories.length ~/ 2;
        return [
          ...otherCategories.sublist(0, middleIndex),
          reelsCategory,
          ...otherCategories.sublist(middleIndex),
        ];
      } else {
        return otherCategories;
      }
    } catch (e) {
      // Log error but don't crash
      DebugLogger.log('Error arranging categories: $e', category: 'CATEGORIES');
      // Return original list as fallback
      return categories;
    }
  }

  Future<void> _toggleSubcategoryGridView({required bool canToggle}) async {
    if (canToggle == true) {
      setState(() {
        showSubcategoryGridView = !showSubcategoryGridView;
      });
    } else {
      if (_selectedCategory == 6 || _selectedCategory == 0) {
        setState(() {
          showSubcategoryGridView = false;
        });
      }
    }
    await _saveShowSubcategoryGridView(showSubcategoryGridView);
  }

  Future<bool> _loadShowSubcategoryGridView() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('showSubcategoryGridView') ?? false;
    } catch (e) {
      DebugLogger.log('Error loading grid view preference: $e', category: 'PREFERENCES');
      return false;
    }
  }

  Future<void> _saveShowSubcategoryGridView(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('showSubcategoryGridView', value);
    } catch (e) {
      DebugLogger.log('Error saving grid view preference: $e', category: 'PREFERENCES');
    }
  }

  @override
  void initState() {
    super.initState();

    // Get bloc and load categories
    _subcategoryBloc = BlocProvider.of<SubcategoryBloc>(context);
    _subcategoryBloc.add(FetchCategories(forceRefresh: false));

    // Load grid view preference
    _loadShowSubcategoryGridView().then((value) {
      if (mounted) {
        setState(() {
          showSubcategoryGridView = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubcategoryBloc, SubcategoryState>(
      builder: (context, state) {
        if (state is SubcategoryLoading) {
          // Use the shimmer widget instead of CircularProgressIndicator
          return Scaffold(
            body: const CategoryScreenShimmer(),
            floatingActionButton: FloatingActionButton(
              onPressed: null, // Disabled during loading
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.grid_view_rounded,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        } else if (state is CategoryLoaded) {
          final categories = state.categories;

          // Auto-select first category if none is selected
          if (selectedCategory == null && categories.isNotEmpty) {
            // Delay setting state to avoid build-during-build error
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  try {
                    selectedCategory = categories.firstWhere(
                            (c) => c.id == 1,
                        orElse: () => categories.first
                    );
                  } catch (e) {
                    // Handle edge case if list is empty for some reason
                    DebugLogger.log('Error auto-selecting category: $e', category: 'CATEGORIES');
                  }
                });
              }
            });
          }

          if (categories.isEmpty) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 48,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.lightDisabledColor
                          : AppTheme.darkDisabledColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No categories available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.lightDisabledColor
                            : AppTheme.darkDisabledColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _subcategoryBloc.add(FetchCategories(forceRefresh: true));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkPrimaryColor
                            : AppTheme.lightPrimaryColor,
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
          } else {
            // Arrange categories properly
            final arrangedCategories = arrangeCategories(categories);

            return Directionality(
              textDirection: TextDirection.ltr,
              child: Scaffold(
                  body: Column(
                    children: [
                      _buildCategoryRow(arrangedCategories),
                      Expanded(
                        child: selectedCategory == null
                            ? const Center(child: Text('Select a category'))
                            : MainMenuPostScreen(
                          category: selectedCategory!.id,
                          userID: widget.userId,
                          servicePostBloc: widget.servicePostBloc,
                          showSubcategoryGridView: showSubcategoryGridView,
                          user: widget.user,
                        ),
                      ),
                    ],
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () async {
                      await _toggleSubcategoryGridView(canToggle: true);
                    },
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.lightPrimaryColor
                        : AppTheme.darkPrimaryColor,
                    child: Icon(
                      showSubcategoryGridView ? Icons.list : Icons.grid_view_rounded,
                      color: Colors.white,
                    ),
                  ),
                  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat
              ),
            );
          }
        } else if (state is SubcategoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _subcategoryBloc.add(FetchCategories(forceRefresh: true));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No subcategories found.'));
        }
      },
    );
  }

  Widget _buildCategoryRow(List<CategoryMenu> categories) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(CategoryMenu category) {
    final isSelected = selectedCategory?.id == category.id;
    final backgroundColor = isSelected
        ? Theme.of(context).brightness == Brightness.dark
        ? AppTheme.darkSecondaryColor
        : AppTheme.lightSecondaryColor
        : Theme.of(context).brightness == Brightness.dark
        ? AppTheme.darkPrimaryColor.withOpacity(0.7)
        : AppTheme.lightPrimaryColor.withOpacity(0.7);

    // Get display name safely
    String displayName;
    try {
      if (category.name is Map) {
        final nameMap = category.name as Map;
        displayName = nameMap['en']?.toString() ?? 'Category ${category.id}';
      } else {
        displayName = category.name.toString();
      }
    } catch (e) {
      displayName = 'Category ${category.id}';
      DebugLogger.log('Error getting category name: $e', category: 'CATEGORIES');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: RawChip(
        onPressed: () {
          setState(() {
            selectedCategory = category;
          });

          DebugLogger.log('Selected category: ${category.id} ($displayName)', category: 'CATEGORIES');
        },
        backgroundColor: backgroundColor,
        label: Text(
          displayName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}