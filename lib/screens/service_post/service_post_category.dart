import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/screens/service_post/service_post_card.dart';
import 'package:talbna/screens/service_post/subcategory_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicePostScreen extends StatefulWidget {
  final int category;
  final int userID;
  final ServicePostBloc servicePostBloc;

  const ServicePostScreen({
    Key? key,
    required this.category,
    required this.userID,
    required this.servicePostBloc,
  }) : super(key: key);

  @override
  _ServicePostScreenState createState() => _ServicePostScreenState();
}

class _ServicePostScreenState extends State<ServicePostScreen>
    with AutomaticKeepAliveClientMixin<ServicePostScreen> {
  @override
  bool get wantKeepAlive => true;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasReachedMax = false;
  bool _showSubcategoryGridView = false;
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
    _scrollController.addListener(_onScroll);
    widget.servicePostBloc.add(GetServicePostsByCategoryEvent(widget.category, _currentPage));
    _loadShowSubcategoryGridView().then((value) {
      setState(() {
        _showSubcategoryGridView = value;
      });
    });
  }

  Future<void> _saveShowSubcategoryGridView(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showSubcategoryGridView', value);
  }
  Future<bool> _loadShowSubcategoryGridView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showSubcategoryGridView') ?? false;
  }
  void _onScroll() {
    if (!_hasReachedMax &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _currentPage++;
      widget.servicePostBloc.add(GetServicePostsByCategoryEvent(widget.category, _currentPage));
    }

  }
  Future<void> _handleRefresh() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _servicePostsCategory.clear();
    widget.servicePostBloc.add(GetServicePostsByCategoryEvent(widget.category, _currentPage));
  }
  void _handleServicePostLoadSuccess(
      List<ServicePost> servicePosts, bool hasReachedMax) {
    setState(() {
      _hasReachedMax = hasReachedMax;
      _servicePostsCategory = [..._servicePostsCategory, ...servicePosts];
    });
  }
  Future<void> _toggleSubcategoryGridView() async {
    _showSubcategoryGridView = !_showSubcategoryGridView;
    await _saveShowSubcategoryGridView(_showSubcategoryGridView);
    setState(() {});
  }
  Future<bool> _onWillPop() async {
    if (_scrollController.offset > 0) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
      );
      // Wait for 200 milliseconds before refreshing
      await Future.delayed(const Duration(milliseconds: 200));
      // Trigger a refresh after reaching the top
      _handleRefresh();
      return false;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    _servicePostsCategory.clear();
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context); // Add this line
    return WillPopScope(
      onWillPop: _onWillPop,
      child: BlocListener<ServicePostBloc, ServicePostState>(
        listenWhen: (previous, current) {
          return current is ServicePostLoadSuccess;
        },
        bloc: widget.servicePostBloc,
        listener: (context, state) {
          if (state is ServicePostLoadSuccess) {
            _handleServicePostLoadSuccess(
                state.servicePosts, state.hasReachedMax);
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: _showSubcategoryGridView
                  ? SubcategoryGridView(categoryId: widget.category, userId: widget.userID, servicePostBloc: widget.servicePostBloc, userProfileBloc: BlocProvider.of<UserProfileBloc>(context),)
                  : BlocBuilder<ServicePostBloc, ServicePostState>(
                      bloc: widget.servicePostBloc,
                      builder: (context, state) {
                        if (state is ServicePostLoading &&
                            _servicePostsCategory.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (_servicePostsCategory.isNotEmpty) {
                          return RefreshIndicator(
                            onRefresh: _handleRefresh,
                            child: ListView.builder(
                              controller: _scrollController,
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
                                    servicePost: servicePost, canViewProfile: true,
                                    userProfileId: widget.userID,
                                  ),
                                );
                              },
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
                                  onPressed: _handleRefresh,
                                  icon: const Icon(Icons.refresh),
                                ),
                                 Text('some error happen , $errorMessage'),
                              ],
                            ),
                          );
                        } else {
                          return const Center(
                            child: Text('No service posts found.'),
                          );
                        }
                      },
                    ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor:  AppTheme.primaryColor,
                onPressed: _toggleSubcategoryGridView,
                child: const Icon(Icons.grid_view_rounded , color: Colors.white, ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
