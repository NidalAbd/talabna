// lib/blocs/category/subcategory_event.dart
import '../../data/models/categories_selected_menu.dart';

abstract class SubcategoryEvent {}

class FetchSubcategories extends SubcategoryEvent {
  final int categoryId;
  final bool showLoadingState;
  final bool forceRefresh;  // Add this field

  FetchSubcategories({
    required this.categoryId,
    this.showLoadingState = true,
    this.forceRefresh = false,  // Default to false
  });
}

class FetchCategories extends SubcategoryEvent {
  final bool showLoadingState;
  final bool forceRefresh;  // Add this field

  FetchCategories({
    this.showLoadingState = true,
    this.forceRefresh = false,  // Default to false
  });
}

class ClearSubcategoryCache extends SubcategoryEvent {
  final int? categoryId; // If null, clear all cache

  ClearSubcategoryCache({
    this.categoryId,
  });
}
class SubcategoriesLoaded extends SubcategoryEvent {
  final List<SubCategoryMenu> subcategories;

  SubcategoriesLoaded(this.subcategories);
}
class PrefetchSubcategories extends SubcategoryEvent {
  final List<int> categoryIds;

  PrefetchSubcategories(this.categoryIds);
}
class InitializeSubcategoryCache extends SubcategoryEvent {
   InitializeSubcategoryCache();
}