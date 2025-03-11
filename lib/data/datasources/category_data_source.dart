// lib/data/datasources/category_data_source.dart
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/models/categories_selected_menu.dart';
import '../models/category_menu.dart';


abstract class CategoryDataSource {
  Future<List<Category>> getCategories();
  Future<List<CategoryMenu>> getCategoryMenu();
  Future<List<SubCategory>> getSubCategories(int categoryId);
  Future<List<SubCategoryMenu>> getSubCategoriesMenu(int categoryId);
}