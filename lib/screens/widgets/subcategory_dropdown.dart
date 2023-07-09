import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/repositories/categories_repository.dart';

class SubCategoriesDropdown extends StatefulWidget {
  final Category? selectedCategory;
  final Function(SubCategory) onSubCategorySelected;
  final SubCategory? initialSubCategory;
  const SubCategoriesDropdown({
    Key? key,
    required this.selectedCategory,
    required this.onSubCategorySelected, this.initialSubCategory,
  }) : super(key: key);

  @override
  _SubCategoriesDropdownState createState() => _SubCategoriesDropdownState();
}

class _SubCategoriesDropdownState extends State<SubCategoriesDropdown> {
  List<SubCategory> _subCategories = [];
  SubCategory? _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    _fetchSubCategories(widget.selectedCategory?.id);
    if (widget.initialSubCategory != null) {
      _selectedSubCategory = widget.initialSubCategory;
    }
  }

  @override
  void didUpdateWidget(covariant SubCategoriesDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory != null && oldWidget.selectedCategory != widget.selectedCategory) {
      _fetchSubCategories(widget.selectedCategory!.id);
    }
  }

  void _fetchSubCategories(int? categoryId) async {
    try {
      CategoriesRepository repository = CategoriesRepository();
      _subCategories = await repository.getSubCategories(categoryId!);
      setState(() {
        _selectedSubCategory = _subCategories.first;
      });
      widget.onSubCategorySelected(_selectedSubCategory!); // Add this line
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<SubCategory>(
      value: _selectedSubCategory,
      decoration: const InputDecoration(
        labelText: 'الفئة الفرعية',
      ),
      items: _subCategories
          .map((subCategory) => DropdownMenuItem<SubCategory>(
        value: subCategory,
        child: Text(subCategory.name , style: const TextStyle(color: Colors.white),),
      ))
          .toList(),
      dropdownColor: AppTheme.primaryColor,
      onChanged: (SubCategory? newSubCategory) {
        if (newSubCategory != null) {
          setState(() {
            _selectedSubCategory = newSubCategory;
          });
          widget.onSubCategorySelected(newSubCategory);
        }
      },
    );
  }
}
