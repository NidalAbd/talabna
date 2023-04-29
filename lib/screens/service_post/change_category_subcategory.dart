import 'dart:io';
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

class ChangeCategoryScreen extends StatefulWidget {
  const ChangeCategoryScreen({Key? key,required this.userId, required this.servicePostId}) : super(key: key);
  final int userId;
  final int servicePostId;

  @override
  State<ChangeCategoryScreen> createState() => _ChangeCategoryScreenState();
}

class _ChangeCategoryScreenState extends State<ChangeCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;

  Future<void> _submitForm() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()){
      if (_selectedCategory == null || _selectedSubCategory == null) {
        ErrorWidget('Please select a category and subcategory.');
        return;
      }
      final servicePost = ServicePost(
          category: _selectedCategory?.id.toString(), // use the category ID instead of the name
          subCategory: _selectedSubCategory?.id.toString(), // use the subcategory ID instead of the name
      );
      context.read<ServicePostBloc>().add(ServicePostCategoryUpdateEvent(servicePost, widget.servicePostId));
    }
  }


  void _onCategorySelected(Category newCategory) {
    setState(() {
      _selectedCategory = newCategory;
    });
  }
  void _onSubCategorySelected(SubCategory newSubCategory) {
    setState(() {
      _selectedSubCategory = newSubCategory;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تغيير القسم'),
        actions:  [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                PointBalance(userId: widget.userId,),
              ],
            ),
          ),
        ],
      ),
      body: BlocListener<ServicePostBloc, ServicePostState>(
        listener: (context, state) {
          if (state is ServicePostOperationSuccess) {
            SuccessWidget.show(context, 'Service Post Category Changed successfully');
            Navigator.of(context).pop();
          } else if (state is ServicePostOperationFailure) {
            ErrorWidget('Error creating : ${state.errorMessage}');
          }
        },
        child: Form(
          key: _formKey,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [

                CategoriesDropdown(
                  onCategorySelected: _onCategorySelected,
                ),
                const SizedBox(height: 8.0),
                SubCategoriesDropdown(
                  selectedCategory: _selectedCategory,
                  onSubCategorySelected: _onSubCategorySelected,
                ),

                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('تحويل'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}