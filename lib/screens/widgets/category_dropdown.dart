import 'package:flutter/material.dart';
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/repositories/categories_repository.dart';

class CategoriesDropdown extends StatefulWidget {
  final Function(Category) onCategorySelected;
  final Category? initialCategory;

  const CategoriesDropdown({super.key, required this.onCategorySelected, this.initialCategory});

  @override
  _CategoriesDropdownState createState() => _CategoriesDropdownState();
}

class _CategoriesDropdownState extends State<CategoriesDropdown> {
  List<Category> _categories = [];
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }
  }

  void _fetchCategories() async {
    try {
      CategoriesRepository repository = CategoriesRepository();
      _categories = await repository.getCategories();
      setState(() {
        _selectedCategory = _categories.first;
        widget.onCategorySelected(_selectedCategory!);
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Category>(

      value: _selectedCategory,
      decoration: const InputDecoration(

        labelText: 'الفئة الرئيسية',
      ),
      items: _categories
          .map((category) => DropdownMenuItem<Category>(

        value: category,
        child: Text(category.name),
      ))
          .toList(),
      onChanged: (Category? newCategory) {
        if (newCategory != null) {
          setState(() {
            _selectedCategory = newCategory;
          });
          widget.onCategorySelected(newCategory);
        }
      },
    );
  }

}