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
import 'package:talbna/main.dart';
import 'package:talbna/screens/service_post/subcategory_post_screen.dart';
import 'package:talbna/utils/constants.dart';

import '../widgets/shimmer_widgets.dart';

class SubcategoryListView extends StatefulWidget {
  final int categoryId;
  final int userId;
  final User user;
  final ServicePostBloc servicePostBloc;
  final UserProfileBloc userProfileBloc;

  const SubcategoryListView({
    super.key,
    required this.categoryId,
    required this.userId,
    required this.servicePostBloc,
    required this.userProfileBloc,
    required this.user,
  });

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

  void _navigateToSubcategory(SubCategoryMenu subcategory) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubCategoryPostScreen(
          userID: widget.userId,
          categoryId: subcategory.categoriesId,
          subcategoryId: subcategory.id,
          servicePostBloc: widget.servicePostBloc,
          userProfileBloc: widget.userProfileBloc,
          user: widget.user,
          titleSubcategory: subcategory.name[language] ?? subcategory.name['en'] ?? 'Unknown',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final backgroundColor = isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;

    return BlocBuilder<SubcategoryBloc, SubcategoryState>(
      builder: (context, state) {
        if (state is SubcategoryLoading) {
          // Replace CircularProgressIndicator with Shimmer
          return const SubcategoryListViewShimmer();
        } else if (state is SubcategoryLoaded) {
          if (state.subcategories.isEmpty) {
            return _buildEmptyState(isDarkMode);
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              itemCount: state.subcategories.length,
              itemBuilder: (context, index) {
                final subcategory = state.subcategories[index];
                return _buildSubcategoryCard(
                  subcategory,
                  isDarkMode,
                  primaryColor,
                  backgroundColor,
                  textColor,
                  index,
                );
              },
            ),
          );
        } else if (state is SubcategoryError) {
          return _buildErrorState(state.message, isDarkMode, primaryColor);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            color: isDarkMode ? AppTheme.darkDisabledColor : AppTheme.lightDisabledColor,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            "No subcategories available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try checking back later",
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppTheme.darkDisabledColor : AppTheme.lightDisabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, bool isDarkMode, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.lightErrorColor,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _subcategoryBloc.add(FetchSubcategories(categoryId: widget.categoryId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryCard(
      SubCategoryMenu subcategory,
      bool isDarkMode,
      Color primaryColor,
      Color backgroundColor,
      Color textColor,
      int index,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToSubcategory(subcategory),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF1E1E1E) : Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Hero(
                    tag: 'subcategory_${subcategory.id}',
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: primaryColor.withOpacity(0.1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: subcategory.photos.isNotEmpty
                            ? Image.network(
                          '${Constants.apiBaseUrl}/${subcategory.photos[0].src}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported_outlined,
                              color: primaryColor.withOpacity(0.5),
                            );
                          },
                        )
                            : Icon(
                          Icons.category_outlined,
                          color: primaryColor.withOpacity(0.5),
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subcategory.name[language] ?? subcategory.name['en'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Total: ${formatNumber(subcategory.servicePostsCount)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: primaryColor.withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}