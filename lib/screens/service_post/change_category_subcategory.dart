import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/screens/interaction_widget/point_balance.dart';
import 'package:talbna/screens/widgets/category_dropdown.dart';
import 'package:talbna/screens/widgets/subcategory_dropdown.dart';
import 'package:talbna/screens/widgets/success_widget.dart';
import '../../provider/language.dart';

class ChangeCategoryScreen extends StatefulWidget {
  const ChangeCategoryScreen({
    super.key,
    required this.userId,
    required this.servicePostId,
    required this.category,
    required this.subCategory,
  });

  final int userId;
  final int servicePostId;
  final Category? category;
  final SubCategory? subCategory;

  @override
  State<ChangeCategoryScreen> createState() => _ChangeCategoryScreenState();
}

class _ChangeCategoryScreenState extends State<ChangeCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final Language _language = Language();

  late Category? _selectedCategory;
  late SubCategory? _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
    _selectedSubCategory = widget.subCategory;
  }

  void _handleCategorySelected(Category newCategory) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedCategory = newCategory;
          _selectedSubCategory = null;
        });
      }
    });
  }

  void _handleSubCategorySelected(SubCategory newSubCategory) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedSubCategory = newSubCategory;
        });
      }
    });
  }

  Future<void> _submitForm() async {
    if (!mounted) return;

    if (_formKey.currentState?.validate() != true) return;

    if (_selectedCategory == null || _selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category and subcategory.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final servicePost = ServicePost(
      category: _selectedCategory,  // Add the category here
      subCategory: _selectedSubCategory,
    );

    context.read<ServicePostBloc>().add(
      ServicePostCategoryUpdateEvent(servicePost: servicePost, servicePostID: widget.servicePostId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_language.tChangeCategoryText()),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PointBalance(
              userId: widget.userId,
              showBalance: true,
              canClick: true,
            ),
          ),
        ],
      ),
      body: BlocListener<ServicePostBloc, ServicePostState>(
        listener: (context, state) {
          if (state is ServicePostOperationSuccess) {
            showCustomSnackBar(context, 'success', type: SnackBarType.success);
            Navigator.of(context).pop();
          } else if (state is ServicePostOperationFailure) {
            showCustomSnackBar(context, 'error', type: SnackBarType.error);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CategoriesDropdown(
                    onCategorySelected: _handleCategorySelected,
                    language: _language.getLanguage(),
                    initialValue: _selectedCategory,
                    // Add the hideServicePostCategories parameter with value true
                    hideServicePostCategories: true,
                  ),
                  const SizedBox(height: 16.0),
                  if (_selectedCategory != null)
                    SubCategoriesDropdown(
                      selectedCategory: _selectedCategory,
                      onSubCategorySelected: _handleSubCategorySelected,
                      initialValue: _selectedSubCategory,
                      selectedSubCategory: _selectedSubCategory,
                    ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: Text(_language.tChangeCategoryText()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}