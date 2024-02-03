import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/category/subcategory_bloc.dart';
import 'package:talbna/blocs/category/subcategory_event.dart';
import 'package:talbna/blocs/category/subcategory_state.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/data/models/categories_selected_menu.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/service_post/subcategory_post_screen.dart';
import 'package:talbna/utils/constants.dart';

class SubcategoryListView extends StatefulWidget {
  final int categoryId;
  final int userId;
  final User user;
  final ServicePostBloc servicePostBloc;
  final UserProfileBloc userProfileBloc;

  const SubcategoryListView({
    Key? key,
    required this.categoryId,
    required this.userId,
    required this.servicePostBloc,
    required this.userProfileBloc,
    required this.user,
  }) : super(key: key);

  @override
  _SubcategoryListViewState createState() => _SubcategoryListViewState();
}

class _SubcategoryListViewState extends State<SubcategoryListView> {
  late SubcategoryBloc _subcategoryBloc;

  @override
  void initState() {
    super.initState();
    _subcategoryBloc = BlocProvider.of<SubcategoryBloc>(context);
    _subcategoryBloc.add(FetchSubcategories(categoryId: widget.categoryId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubcategoryBloc, SubcategoryState>(
      builder: (context, state) {
        if (state is SubcategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SubcategoryLoaded) {
          if (state.subcategories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.lightDisabledColor
                        : AppTheme.darkDisabledColor,
                    size: 100,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Oops! No subcategories found here 🙁.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              itemCount: state.subcategories.length,
              itemBuilder: (context, index) {
                final subcategory = state.subcategories[index];
                return _buildSubcategoryListItem(subcategory);
              },
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

  Widget _buildSubcategoryListItem(SubCategoryMenu subcategory) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SubCategoryPostScreen(
                userID: widget.userId,
                categoryId: subcategory.categoriesId,
                subcategoryId: subcategory.id,
                servicePostBloc: widget.servicePostBloc,
                userProfileBloc: widget.userProfileBloc,
                user: widget.user,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundImage: subcategory.photos.isNotEmpty
        ? NetworkImage(
        '${Constants.apiBaseUrl}/${subcategory.photos[0].src}',
        ) as ImageProvider
              : const AssetImage('assets/loading.gif'),
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          subcategory.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        subtitle: Text(
          'Total : ${formatNumber(subcategory.servicePostsCount)}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: IconButton(onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SubCategoryPostScreen(
                userID: widget.userId,
                categoryId: subcategory.categoriesId,
                subcategoryId: subcategory.id,
                servicePostBloc: widget.servicePostBloc,
                userProfileBloc: widget.userProfileBloc,
                user: widget.user,
              ),
            ),
          );
        }, icon: const Icon(Icons.arrow_forward_ios)),
      ),
    );
  }

  String formatNumber(int number) {
    if (number >= 1000000000) {
      final double formattedNumber = number / 1000000;
      const String suffix = 'B';
      return '${formattedNumber.toStringAsFixed(1)}$suffix';
    } else if (number >= 1000000) {
      final double formattedNumber = number / 1000000;
      const String suffix = 'M';
      return '${formattedNumber.toStringAsFixed(1)}$suffix';
    } else if (number >= 1000) {
      final double formattedNumber = number / 1000;
      const String suffix = 'K';
      return '${formattedNumber.toStringAsFixed(1)}$suffix';
    } else {
      return number.toString();
    }
  }
}
