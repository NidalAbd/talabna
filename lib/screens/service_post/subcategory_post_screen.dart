import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_event.dart';
import 'package:talbna/blocs/user_action/user_action_state.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/service_post/service_post_card.dart';

class SubCategoryPostScreen extends StatefulWidget {
  const SubCategoryPostScreen(
      {Key? key,
      required this.userID,
      required this.categoryId,
      required this.subcategoryId,
      required this.servicePostBloc,
      required this.userProfileBloc, required this.user})
      : super(key: key);
  final int userID;
  final User user;
  final int categoryId;
  final int subcategoryId;
  final ServicePostBloc servicePostBloc;
  final UserProfileBloc userProfileBloc;
  @override
  SubCategoryPostScreenState createState() => SubCategoryPostScreenState();
}

class SubCategoryPostScreenState extends State<SubCategoryPostScreen> {
  final ScrollController _scrollSubCategoryPostController = ScrollController();
  int _currentPage = 1;
  bool _hasReachedMax = false;
  late bool isFollowing = false;
  late String subcategoryTitle= 'تفاصيل الفرع';

  List<ServicePost> _servicePostsSubCategory = [];
  late Function onPostDeleted = (int postId) {
    setState(() {
      _servicePostsSubCategory.removeWhere((post) => post.id == postId);
    });
  };

  @override
  void initState() {
    super.initState();
    _handleRefreshSubcategories();
    _scrollSubCategoryPostController.addListener(_onScrollSubcategories);
    context
        .read<UserActionBloc>()
        .add(GetUserFollowSubcategories(subCategoryId: widget.subcategoryId));
    widget.servicePostBloc.add(GetServicePostsByCategorySubCategoryEvent(
        widget.categoryId, widget.subcategoryId, _currentPage));
  }

  void _onScrollSubcategories() {
    if (!_hasReachedMax &&
        _scrollSubCategoryPostController.offset >=
            _scrollSubCategoryPostController.position.maxScrollExtent &&
        !_scrollSubCategoryPostController.position.outOfRange) {
      _currentPage++;
      widget.servicePostBloc.add(GetServicePostsByCategorySubCategoryEvent(
          widget.categoryId, widget.subcategoryId, _currentPage));
    }
  }

  Future<void> _handleRefreshSubcategories() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _servicePostsSubCategory.clear();
    widget.servicePostBloc.add(GetServicePostsByCategorySubCategoryEvent(
        widget.categoryId, widget.subcategoryId, _currentPage));
  }

  void _handleSubcategoriesPostLoadSuccess(
      List<ServicePost> servicePosts, bool hasReachedMax) {
    setState(() {
      _hasReachedMax = hasReachedMax;
      _servicePostsSubCategory = [..._servicePostsSubCategory, ...servicePosts];
    });
  }

  Future<bool> _onWillPopSubcategories() async {
    if (_scrollSubCategoryPostController.offset > 0) {
      _scrollSubCategoryPostController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
      );
      // Wait for the duration of the scrolling animation before refreshing
      await Future.delayed(const Duration(milliseconds: 1000));
      // Trigger a refresh after reaching the top
      _handleRefreshSubcategories();
      return false;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    _servicePostsSubCategory.clear();
    _scrollSubCategoryPostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title:  Text(subcategoryTitle),
        actions: [
          BlocConsumer<UserActionBloc, UserActionState>(
            listener: (context, state) {
              if (state is UserMakeFollowSubcategoriesSuccess) {
                isFollowing = state.followSuccess; // Update the isFollowing variable
                final message = state.followSuccess
                    ? 'You are now following  $subcategoryTitle'
                    : 'You have unfollowed $subcategoryTitle';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is GetFollowSubcategoriesSuccess) {
                isFollowing = state.followSuccess;
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 15, 10),
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<UserActionBloc>().add(
                      UserMakeFollowSubcategories(subCategoryId: widget.subcategoryId),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: isFollowing ? Colors.grey : Colors.blue, // Customize the text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  label: Text(
                    isFollowing ? 'Unfollow' : 'Follow',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  icon: Icon(
                    isFollowing ? Icons.verified_user_outlined : Icons.add_circle, // Replace with your desired icons
                    size: 20, // Set the size of the icon
                  ),
                )
              );
            },
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: _onWillPopSubcategories,
        child: BlocListener<ServicePostBloc, ServicePostState>(
          bloc: widget.servicePostBloc,
          listener: (context, state) {
            if (state is ServicePostLoadSuccess) {
              _handleSubcategoriesPostLoadSuccess(
                  state.servicePosts, state.hasReachedMax);
            }
          },
          child: BlocBuilder<ServicePostBloc, ServicePostState>(
            bloc: widget.servicePostBloc,
            builder: (context, state) {
              if (state is ServicePostLoading &&
                  _servicePostsSubCategory.isEmpty) {
                // show loading indicator
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (_servicePostsSubCategory.isNotEmpty) {
                subcategoryTitle = _servicePostsSubCategory.first.subCategory!.id.toString(); // Get ID
                // show list of service posts
                return RefreshIndicator(
                    onRefresh: _handleRefreshSubcategories,
                    child: ListView.builder(
                      controller: _scrollSubCategoryPostController,
                      itemCount: _hasReachedMax
                          ? _servicePostsSubCategory.length
                          : _servicePostsSubCategory.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= _servicePostsSubCategory.length) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final servicePost = _servicePostsSubCategory[index];
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          child: ServicePostCard(
                            key: UniqueKey(), // Add this line
                            onPostDeleted: onPostDeleted,
                            servicePost: servicePost, canViewProfile: false,
                            userProfileId: widget.userID, user: widget.user,
                          ),
                        );
                      },
                    ));
              } else if (state is ServicePostLoadFailure) {
// show error message
                return Center(
                  child: Text(state.errorMessage),
                );
              } else {
// show empty state
                return const Center(
                  child: Text('No service posts found.'),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
