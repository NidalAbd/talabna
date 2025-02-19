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

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key,required this.servicePostBloc, required this.userId, required this.user});
  final ServicePostBloc servicePostBloc;
  final int userId;
  final User user;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late SubcategoryBloc _subcategoryBloc;
  int user = 251155151;
  late bool showSubcategoryGridView = false;
  final int _selectedCategory = 1;
  CategoryMenu? selectedCategory; // Added


  Future<void> _toggleSubcategoryGridView({required bool canToggle}) async {
    if (canToggle == true) {
      showSubcategoryGridView = !showSubcategoryGridView;
    } else {
      if (_selectedCategory == 6 || _selectedCategory == 0) {
        showSubcategoryGridView = false;
      }
    }
    await _saveShowSubcategoryGridView(showSubcategoryGridView);
    setState(() {});
  }
  Future<bool> _loadShowSubcategoryGridView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showSubcategoryGridView') ?? false;
  }

  Future<void> _saveShowSubcategoryGridView(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showSubcategoryGridView', value);
  }

  @override
  void initState() {
    super.initState();
    _subcategoryBloc = BlocProvider.of<SubcategoryBloc>(context);
    _subcategoryBloc.add(const FetchCategories());
    _loadShowSubcategoryGridView().then((value) {
      setState(() {
        showSubcategoryGridView = value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubcategoryBloc, SubcategoryState>(
      builder: (context, state) {
        if (state is SubcategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CategoryLoaded) {
          if (state.categories.isEmpty) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: IconButton(
                onPressed: () {},
                icon:  Icon(
                  Icons.sentiment_satisfied_alt_outlined,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.lightDisabledColor
                      : AppTheme.darkDisabledColor,
                ),
                tooltip: 'Change to list view',
              ),
            );
          } else {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Scaffold(
                body: Column(
                  children: [
                    _buildCategoryRow(state.categories),
                    Expanded(
                      child: selectedCategory == null ? Container() : MainMenuPostScreen(category: selectedCategory!.id, userID: widget.userId, servicePostBloc: widget.servicePostBloc, showSubcategoryGridView: showSubcategoryGridView, user: widget.user,),
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
          return Center(child: Text(state.message));
        } else {
          return const Center(child: Text('No subcategories found.'));
        }
      },
    );
  }

  Widget _buildCategoryRow(List<CategoryMenu> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map<Widget>((category) => _buildCategoryCard(category)).toList(),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryMenu category) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: RawChip(
        onPressed: () {
          setState(() {
            selectedCategory = category;
          });
        },
        label: Text(
          category.name,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold , color: Colors.white),
          overflow: TextOverflow.ellipsis, // Truncate text with ellipsis
          maxLines: 1, // Limit the text to 1 line
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

}


