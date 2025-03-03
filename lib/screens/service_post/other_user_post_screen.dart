import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/service_post/service_post_card.dart';

class OtherUserPostScreen extends StatefulWidget {
   const OtherUserPostScreen({super.key, required this.userID, required this.user});
  final int userID;
  final User user;

  @override
  OtherUserPostScreenState createState() => OtherUserPostScreenState();
}

class OtherUserPostScreenState extends State<OtherUserPostScreen> {
  final ScrollController _scrollUserController = ScrollController();
  late ServicePostBloc _servicePostBloc;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<ServicePost> _servicePostsUser = [];
  late Function onPostDeleted = (int postId) {
    setState(() {
      _servicePostsUser.removeWhere((post) => post.id == postId);
    });
  };

  @override
  void initState() {
    super.initState();
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _servicePostBloc.add(GetServicePostsByUserIdEvent(widget.userID, _currentPage));
    _scrollUserController.addListener(_onScrollUserPost);
  }

  void _onScrollUserPost() {
    if (!_hasReachedMax &&
        _scrollUserController.offset >=
            _scrollUserController.position.maxScrollExtent &&
        !_scrollUserController.position.outOfRange) {
      _currentPage++;
      _servicePostBloc
          .add(GetServicePostsByUserIdEvent(widget.userID, _currentPage));
    }
  }

  Future<void> _handleUserPostRefresh() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _servicePostsUser.clear();
    _servicePostBloc
        .add(GetServicePostsByUserIdEvent(widget.userID, _currentPage));
  }
  void _handleUserPostLoadSuccess(
      List<ServicePost> servicePosts, bool hasReachedMax) {
    setState(() {
      _hasReachedMax = hasReachedMax;
      _servicePostsUser = [..._servicePostsUser, ...servicePosts];
    });
  }
  Future<bool> _onWillPopUserPost() async {
    if (_scrollUserController.positions.isNotEmpty && _scrollUserController.offset > 0) {
      _scrollUserController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
      );
      // Wait for the duration of the scrolling animation before refreshing
      await Future.delayed(const Duration(milliseconds: 1000));
      // Trigger a refresh after reaching the top
      _handleUserPostRefresh();
      return false;
    } else {
      return true;
    }
  }


  @override
  void dispose() {
    _servicePostsUser.clear();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopUserPost,
      child: BlocListener<ServicePostBloc, ServicePostState>(
        bloc: _servicePostBloc,
        listener: (context, state) {
          if (state is ServicePostLoadSuccess) {
            _handleUserPostLoadSuccess(state.servicePosts, state.hasReachedMax);
          }
        },
        child: BlocBuilder<ServicePostBloc, ServicePostState>(
          bloc: _servicePostBloc,
          builder: (context, state) {

            if (state is ServicePostLoading && _servicePostsUser.isEmpty) {
              // show loading indicator
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (_servicePostsUser.isNotEmpty) {
              // show list of service posts
              return RefreshIndicator(
                onRefresh: _handleUserPostRefresh,
                child: ListView.builder(
                  controller: _scrollUserController,
                  itemCount: _hasReachedMax
                      ? _servicePostsUser.length
                      : _servicePostsUser.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= _servicePostsUser.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final servicePost = _servicePostsUser[index];
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      child: ServicePostCard(
                          key: UniqueKey(), // Add this line
                          onPostDeleted: onPostDeleted,
                          userProfileId: widget.userID,
                          servicePost: servicePost,
                          canViewProfile: false, user: widget.user,
                      ),
                    );
                  },
                )

              );
            } else if (state is ServicePostLoadFailure) {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _handleUserPostRefresh,
                      icon: const Icon(Icons.refresh),
                    ),
                    const Text('some error happen , press refresh button'),
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
    );
  }
}
