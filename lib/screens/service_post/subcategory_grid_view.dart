import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/category/subcategory_bloc.dart';
import 'package:talbna/blocs/category/subcategory_event.dart';
import 'package:talbna/blocs/category/subcategory_state.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/data/models/categories_selected_menu.dart';
import 'package:talbna/screens/service_post/subcategory_post_screen.dart';
import 'package:talbna/utils/constants.dart';

class SubcategoryGridView extends StatefulWidget {
  final int categoryId;
  final int userId;
  final ServicePostBloc servicePostBloc;
  final UserProfileBloc userProfileBloc;

  const SubcategoryGridView(
      {Key? key,
      required this.categoryId,
      required this.userId,
      required this.servicePostBloc,
      required this.userProfileBloc})
      : super(key: key);

  @override
  _SubcategoryGridViewState createState() => _SubcategoryGridViewState();
}

class _SubcategoryGridViewState extends State<SubcategoryGridView> {
  late SubcategoryBloc _subcategoryBloc;
  @override
  void initState() {
    super.initState();
    _subcategoryBloc = BlocProvider.of<SubcategoryBloc>(context);
    _subcategoryBloc.add(FetchSubcategories(categoryId: widget.categoryId));
  }

  @override
  void dispose() {
    super.dispose();
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
                child: Padding(
                  padding: const EdgeInsets.only(right: 80),
                  child: IconButton(
                    onPressed: () {},
                    icon:  Icon(
                      Icons.sentiment_very_dissatisfied,
                      size: 100.0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.lightDisabledColor
                          : AppTheme.darkDisabledColor,
                    ),
                    tooltip: 'Change to list view',
                  ),
                ));
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4 / 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: state.subcategories.length,
              itemBuilder: (context, index) {
                final subcategory = state.subcategories[index];
                return _buildSubcategoryCard(subcategory);
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

  Widget _buildSubcategoryCard(SubCategoryMenu subcategory) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => SubCategoryPostScreen(
                    userID: widget.userId,
                    categoryId: subcategory.categoriesId,
                    subcategoryId: subcategory.id,
                    servicePostBloc: widget.servicePostBloc,
                    userProfileBloc: widget.userProfileBloc,
                  )),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 200, // Set the desired width for the card
          height: MediaQuery.of(context).size.width /
              6, // Set the desired height for the card
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Card(
                child: SizedBox(
                  width: double.infinity,
                  height: 100, // Set a fixed height for the container
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          subcategory.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow
                              .ellipsis, // Truncate text with ellipsis
                          maxLines: 1, // Limit the text to 1 line
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                        child:
                            Text('${subcategory.servicePostsCount} services'),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFEEF9E6),
                  radius: 30,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: subcategory.photos.isNotEmpty
                        ? NetworkImage(
                            '${Constants.apiBaseUrl}/${subcategory.photos[0].src}')
                        : const AssetImage('assets/loading.gif')
                            as ImageProvider<Object>?,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
