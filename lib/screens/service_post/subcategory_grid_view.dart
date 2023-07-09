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
   int user = 251155151;

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
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 80),
                    child: IconButton(
                      onPressed: () {},
                      icon:  Icon(
                        Icons.sentiment_very_dissatisfied,
                        size: 150.0,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.lightDisabledColor
                            : AppTheme.darkDisabledColor,
                      ),
                      tooltip: 'Change to list view',
                    ),
                  )),
            );
          } else {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4 / 2,

                ),
                itemCount: state.subcategories.length,
                itemBuilder: (context, index) {
                  final subcategory = state.subcategories[index];
                  return _buildSubcategoryCard(subcategory);
                },
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
      child: SizedBox(
        width: 200, // Set the desired width for the card
        height: MediaQuery.of(context).size.width /
            6, // Set the desired height for the card
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.lightForegroundColor
                  : AppTheme.darkForegroundColor,
              child: SizedBox(
                width: double.infinity,
                height: 200, // Set a fixed height for the container
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 15, 0),
                      child: Text(
                        subcategory.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow
                            .ellipsis, // Truncate text with ellipsis
                        maxLines: 1, // Limit the text to 1 line
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text('العدد الكلي : ${formatNumber(subcategory.servicePostsCount)}  '),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                width: 64,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.lightForegroundColor.withOpacity(0.1)
                          : AppTheme.darkForegroundColor.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    width: 60,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: subcategory.photos.isNotEmpty
                            ? NetworkImage(
                          '${Constants.apiBaseUrl}/${subcategory.photos[0].src}',
                        ) as ImageProvider
                            : const AssetImage('assets/loading.gif'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
