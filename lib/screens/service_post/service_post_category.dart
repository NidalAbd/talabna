import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/service_post/service_post_card.dart';

import '../widgets/shimmer_widgets.dart';

class ServicePostScreen extends StatefulWidget {
  final int category;
  final int userID;
  final bool showSubcategoryGridView;
  final ServicePostBloc servicePostBloc;
  final User user;
  const ServicePostScreen({
    super.key,
    required this.category,
    required this.userID,
    required this.servicePostBloc, required this.showSubcategoryGridView, required this.user,
  });

  @override
  ServicePostScreenState createState() => ServicePostScreenState();
}

class ServicePostScreenState extends State<ServicePostScreen>
    with AutomaticKeepAliveClientMixin<ServicePostScreen> {
  @override
  bool get wantKeepAlive => true;
  late  bool haveSubcategory;
  final ScrollController _scrollCategoryPostController = ScrollController();
  int _currentPage = 1;
  bool _hasReachedMax = false;
  late bool isRealScreen = widget.category == 8;
  late int? userId;

  List<ServicePost> _servicePostsCategory = [];
  late Function onPostDeleted = (int postId) {
    setState(() {
      _servicePostsCategory.removeWhere((post) => post.id == postId);
    });
  };
  @override
  void initState() {
    super.initState();
    _scrollCategoryPostController.addListener(_onScrollCategoryPost);
    widget.servicePostBloc.add(GetServicePostsByCategoryEvent(widget.category, _currentPage));
  }


  void _onScrollCategoryPost() {
    if (!_hasReachedMax &&
        _scrollCategoryPostController.offset >=
            _scrollCategoryPostController.position.maxScrollExtent &&
        !_scrollCategoryPostController.position.outOfRange) {
      _currentPage++;
      widget.servicePostBloc.add(GetServicePostsByCategoryEvent(widget.category, _currentPage));
    }
  }

  Future<void> _handleRefreshCategoryPost() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _servicePostsCategory.clear();
    widget.servicePostBloc.add(GetServicePostsByCategoryEvent(widget.category, _currentPage));
  }
  void _handleCategoryPostLoadSuccess(
      List<ServicePost> servicePosts, bool hasReachedMax) {
    setState(() {
      _hasReachedMax = hasReachedMax;
      _servicePostsCategory = [..._servicePostsCategory, ...servicePosts];
    });
  }

  Future<bool> _onWillPopCategoryPost() async {
    if (_scrollCategoryPostController.offset > 0) {
      _scrollCategoryPostController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
      );
      // Wait for 200 milliseconds before refreshing
      await Future.delayed(const Duration(milliseconds: 200));
      // Trigger a refresh after reaching the top
      _handleRefreshCategoryPost();
      return false;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    _servicePostsCategory.clear();
    _scrollCategoryPostController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context); // Add this line
    return WillPopScope(
      onWillPop: _onWillPopCategoryPost,
      child:BlocListener<ServicePostBloc, ServicePostState>(
        listenWhen: (previous, current) {
          return current is ServicePostLoadSuccess;
        },
        bloc: widget.servicePostBloc,
        listener: (context, state) {
          if (state is ServicePostLoadSuccess) {
            _handleCategoryPostLoadSuccess(
                state.servicePosts, state.hasReachedMax);
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: BlocBuilder<ServicePostBloc, ServicePostState>(
                bloc: widget.servicePostBloc,
                builder: (context, state) {
                  if (_servicePostsCategory.isNotEmpty) {
                    return RefreshIndicator(
                      onRefresh: _handleRefreshCategoryPost,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollCategoryPostController,
                              itemCount: _hasReachedMax
                                  ? _servicePostsCategory.length
                                  : _servicePostsCategory.length + 1,
                              itemBuilder: (context, index) {
                                if (index >= _servicePostsCategory.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final servicePost = _servicePostsCategory[index];
                                return AnimatedOpacity(
                                  opacity: 1.0,
                                  duration: const Duration(milliseconds: 2000),
                                  curve: Curves.easeIn,
                                  child: ServicePostCard(
                                    key: Key('servicePostCategory_${servicePost.id}'),
                                    onPostDeleted: onPostDeleted,
                                    servicePost: servicePost,
                                    canViewProfile: true,
                                    userProfileId: widget.userID,
                                    user: widget.user,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is ServicePostLoadFailure) {
                    String errorMessage = state.errorMessage;
                    if (errorMessage.contains('SocketException')) {
                      errorMessage = 'No internet connection';
                    }
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _handleRefreshCategoryPost,
                            icon: const Icon(Icons.refresh),
                          ),
                          Text('Some error occurred: $errorMessage'),
                        ],
                      ),
                    );
                  } else {
                    // Replace this with shimmer loading
                    return const ServicePostScreenShimmer();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}