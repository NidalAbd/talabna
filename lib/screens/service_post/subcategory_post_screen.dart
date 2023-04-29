import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/screens/service_post/service_post_card.dart';

class SubCategoryPostScreen extends StatefulWidget {
  const SubCategoryPostScreen(
      {Key? key,
      required this.userID,
      required this.categoryId,
      required this.subcategoryId,
      required this.servicePostBloc, required this.userProfileBloc})
      : super(key: key);
  final int userID;
  final int categoryId;
  final int subcategoryId;
  final ServicePostBloc servicePostBloc;
  final UserProfileBloc userProfileBloc;

  @override
  SubCategoryPostScreenState createState() => SubCategoryPostScreenState();
}

class SubCategoryPostScreenState extends State<SubCategoryPostScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<ServicePost> _servicePostsSubCategory = [];
  late Function onPostDeleted = (int postId) {
    setState(() {
      _servicePostsSubCategory.removeWhere((post) => post.id == postId);
    });
  };

  @override
  void initState() {
    super.initState();
    _handleRefresh();
    _scrollController.addListener(_onScroll);
    widget.servicePostBloc.add(GetServicePostsByCategorySubCategoryEvent(
          widget.categoryId, widget.subcategoryId, _currentPage));
  }

  void _onScroll() {
    if (!_hasReachedMax &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _currentPage++;
      widget.servicePostBloc.add(GetServicePostsByCategorySubCategoryEvent(
          widget.categoryId, widget.subcategoryId, _currentPage));
    }
  }

  Future<void> _handleRefresh() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _servicePostsSubCategory.clear();
    widget.servicePostBloc.add(GetServicePostsByCategorySubCategoryEvent(
        widget.categoryId, widget.subcategoryId, _currentPage));
  }

  void _handleServicePostLoadSuccess(
      List<ServicePost> servicePosts, bool hasReachedMax) {
    setState(() {
      _hasReachedMax = hasReachedMax;
      _servicePostsSubCategory = [..._servicePostsSubCategory, ...servicePosts];
    });
  }

  Future<bool> _onWillPop() async {
    if (_scrollController.offset > 0) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
      );
      // Wait for the duration of the scrolling animation before refreshing
      await Future.delayed(const Duration(milliseconds: 1000));
      // Trigger a refresh after reaching the top
      _handleRefresh();
      return false;
    } else {
      return true;
    }
  }
  @override
  void dispose() {
    _servicePostsSubCategory.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الفرع'),
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: BlocListener<ServicePostBloc, ServicePostState>(
          bloc: widget.servicePostBloc,
          listener: (context, state) {
            if (state is ServicePostLoadSuccess) {
              _handleServicePostLoadSuccess(
                  state.servicePosts, state.hasReachedMax);
            }
          },
          child: BlocBuilder<ServicePostBloc, ServicePostState>(
            bloc: widget.servicePostBloc,
            builder: (context, state) {
              if (state is ServicePostLoading && _servicePostsSubCategory.isEmpty) {
                // show loading indicator
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (_servicePostsSubCategory.isNotEmpty) {
                // show list of service posts
                return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: ListView.builder(
                      controller: _scrollController,
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
                            userProfileId: widget.userID,
                            id: servicePost.id,
                            title: servicePost.title,
                            description: servicePost.description,
                            userPhoto: servicePost.userPhoto,
                            username: servicePost.userName,
                            postDate: servicePost.createdAt,
                            isFavorited: servicePost.isFavorited!,
                            views: servicePost.viewCount.toString(),
                            likes: servicePost.favoritesCount.toString(),
                            photos: servicePost.photos,
                            haveBadge: servicePost.haveBadge,
                            category: servicePost.category,
                            subcategory: servicePost.subCategory,
                            type: servicePost.type,
                            userId: servicePost.userId,

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