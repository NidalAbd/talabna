import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/reel/reels_screen.dart';
import 'package:talbna/screens/service_post/service_post_card.dart';
import 'package:talbna/screens/service_post/subcategory_grid_view.dart';

class ServicePostScreen extends StatefulWidget {
  final int category;
  final int userID;
  final bool showSubcategoryGridView;
  final ServicePostBloc servicePostBloc;
  final User user;
   const ServicePostScreen({
    Key? key,
    required this.category,
    required this.userID,
    required this.servicePostBloc, required this.showSubcategoryGridView, required this.user,
  }) : super(key: key);

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
                               // if(widget.category == 7) NewsPostForm(
                               //    onPostSubmitted: (String text, String? mediaType) {
                               //    },
                               //  ),
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scrollCategoryPostController,
                                    itemCount: _hasReachedMax
                                        ? _servicePostsCategory.length
                                        : _servicePostsCategory.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index >= _servicePostsCategory.length) {
                                        return const Center(
                                            child: CircularProgressIndicator());
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
                                          userProfileId: widget.userID, user: widget.user,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }  else if (state is ServicePostLoadFailure) {
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
                                 Text('some error happen , $errorMessage'),
                              ],
                            ),
                          );
                        } else {
                          return const Center(
                            child: SizedBox(
                              width: 20,
                                height: 20,
                                child: CircularProgressIndicator()),
                          );
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
