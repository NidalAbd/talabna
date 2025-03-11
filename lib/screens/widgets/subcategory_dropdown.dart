import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/repositories/categories_repository.dart';
import '../../core/service_locator.dart';
import '../../provider/language.dart';

class SubCategoriesDropdown extends StatefulWidget {
  final Category? selectedCategory;
  final Function(SubCategory) onSubCategorySelected;
  final SubCategory? initialValue;
  final SubCategory? selectedSubCategory;

  const SubCategoriesDropdown({
    super.key,
    required this.selectedCategory,
    required this.onSubCategorySelected,
    this.initialValue,
    this.selectedSubCategory,
  });

  @override
  _SubCategoriesDropdownState createState() => _SubCategoriesDropdownState();
}

class _SubCategoriesDropdownState extends State<SubCategoriesDropdown> {
  List<SubCategory> _subCategories = [];
  SubCategory? _selectedSubCategory;
  final Language _language = Language();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWithInitialValue();
  }

  void _initializeWithInitialValue() {
    // Handle initial value if provided
    if (widget.initialValue != null) {
      setState(() {
        _selectedSubCategory = widget.initialValue;
        // Create initial list with just the initial subcategory
        _subCategories = [widget.initialValue!];
      });
      // Notify parent about initial selection
      widget.onSubCategorySelected(widget.initialValue!);
    }

    // Fetch subcategories if category is available
    if (widget.selectedCategory != null) {
      _fetchSubCategories(widget.selectedCategory!.id);
    }
  }

  @override
  void didUpdateWidget(covariant SubCategoriesDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle category changes
    if (widget.selectedCategory != null &&
        oldWidget.selectedCategory?.id != widget.selectedCategory?.id) {
      _fetchSubCategories(widget.selectedCategory!.id);
    }

    // Handle initial value changes
    if (widget.initialValue?.id != oldWidget.initialValue?.id) {
      _initializeWithInitialValue();
    }

    // Handle selectedSubCategory changes
    if (widget.selectedSubCategory?.id != oldWidget.selectedSubCategory?.id) {
      setState(() {
        _selectedSubCategory = widget.selectedSubCategory;
      });
    }
  }

  Future<void> _fetchSubCategories(int categoryId) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      CategoriesRepository repository = serviceLocator<CategoriesRepository>();
      final fetchedSubCategories = await repository.getSubCategories(categoryId);


      if (mounted) {
        setState(() {
          if (widget.initialValue != null) {
            // Filter out the initial value to avoid duplicates
            _subCategories = fetchedSubCategories
                .where((sub) => sub.id != widget.initialValue!.id)
                .toList();
            // Keep initial value at the top
            _subCategories.insert(0, widget.initialValue!);
          } else {
            _subCategories = fetchedSubCategories;
            // Select first subcategory if nothing is selected
            if (_selectedSubCategory == null && _subCategories.isNotEmpty) {
              _selectedSubCategory = _subCategories.first;
              widget.onSubCategorySelected(_subCategories.first);
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load subcategories';
          _isLoading = false;
        });
        print("Error fetching subcategories: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading && _subCategories.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    if (_error != null && _subCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: TextStyle(color: AppTheme.lightErrorColor),
            ),
            TextButton(
              onPressed: () {
                if (widget.selectedCategory != null) {
                  _fetchSubCategories(widget.selectedCategory!.id);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_subCategories.isEmpty) {
      return Center(
        child: Text(
          'No subcategories available',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    return Stack(
      children: [
        DropdownButtonFormField<SubCategory>(
          value: _selectedSubCategory,
          decoration: InputDecoration(
            labelText: _language.tSubcategoryText(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: isDarkMode ? AppTheme.darkBackgroundColor : Colors.white,
          ),
          items: _subCategories.map((subCategory) {
            return DropdownMenuItem<SubCategory>(
              value: subCategory,
              child: Text(
                subCategory.name[_language.getLanguage()] ??
                    subCategory.name['en'] ??
                    'Unknown',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            );
          }).toList(),
          dropdownColor: isDarkMode
              ? AppTheme.darkPrimaryColor
              : AppTheme.lightPrimaryColor,
          onChanged: (SubCategory? newSubCategory) {
            if (newSubCategory != null) {
              setState(() {
                _selectedSubCategory = newSubCategory;
              });
              widget.onSubCategorySelected(newSubCategory);
            }
          },
        ),
        if (_isLoading)
          Positioned(
            right: 40,
            top: 15,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}