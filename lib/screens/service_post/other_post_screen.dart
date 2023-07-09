import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/screens/service_post/service_post_card.dart';

class UserPostScreen extends StatefulWidget {
   const UserPostScreen({Key? key, required this.userID}) : super(key: key);
  final int userID;

  @override
  UserPostScreenState createState() => UserPostScreenState();
}

class UserPostScreenState extends State<UserPostScreen> {
  final ScrollController _scrollOtherUserController = ScrollController();
  late ServicePostBloc _servicePostBloc;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<ServicePost> _servicePostsOtherUser = [];
  late Function onPostDeleted = (int postId) {
    setState(() {
      _servicePostsOtherUser.removeWhere((post) => post.id == postId);
    });
  };

  @override
  void initState() {
    super.initState();
    _scrollOtherUserController.addListener(_onScrollOtherUserPost);
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _handleRefreshOtherUserPost(); // Reset the state when the widget is created
  }

  void _onScrollOtherUserPost() {
    if (!_hasReachedMax &&
        _scrollOtherUserController.offset >=
            _scrollOtherUserController.position.maxScrollExtent &&
        !_scrollOtherUserController.position.outOfRange) {
      _currentPage++;
      _servicePostBloc
          .add(GetServicePostsByUserIdEvent(widget.userID, _currentPage));
    }
  }

  Future<void> _handleRefreshOtherUserPost() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _servicePostsOtherUser.clear();
    _servicePostBloc
        .add(GetServicePostsByUserIdEvent(widget.userID, _currentPage));
  }
  void _handleOtherUserPostLoadSuccess(
      List<ServicePost> servicePosts, bool hasReachedMax) {
    setState(() {
      _hasReachedMax = hasReachedMax;
      _servicePostsOtherUser = [..._servicePostsOtherUser, ...servicePosts];
    });
  }
  Future<bool> _onWillPopOtherUserPost() async {
    if (_scrollOtherUserController.positions.isNotEmpty && _scrollOtherUserController.offset > 0) {
      _scrollOtherUserController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
      );
      // Wait for the duration of the scrolling animation before refreshing
      await Future.delayed(const Duration(milliseconds: 1000));
      // Trigger a refresh after reaching the top
      _handleRefreshOtherUserPost();
      return false;
    } else {
      return true;
    }
  }


  @override
  void dispose() {
    _servicePostsOtherUser.clear();
    _scrollOtherUserController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopOtherUserPost,
      child: BlocListener<ServicePostBloc, ServicePostState>(
        bloc: _servicePostBloc,
        listener: (context, state) {
          if (state is ServicePostLoadSuccess) {
            _handleOtherUserPostLoadSuccess(state.servicePosts, state.hasReachedMax);
          }
        },
        child: BlocBuilder<ServicePostBloc, ServicePostState>(
          bloc: _servicePostBloc,
          builder: (context, state) {
            if (state is ServicePostLoading && _servicePostsOtherUser.isEmpty) {
              // show loading indicator
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (_servicePostsOtherUser.isNotEmpty) {
              // show list of service posts
              return RefreshIndicator(
                onRefresh: _handleRefreshOtherUserPost,
                child: ListView.builder(
                  controller: _scrollOtherUserController,
                  itemCount: _hasReachedMax
                      ? _servicePostsOtherUser.length
                      : _servicePostsOtherUser.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= _servicePostsOtherUser.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final servicePost = _servicePostsOtherUser[index];
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      child: ServicePostCard(
                        key: Key('servicePostProfile_${servicePost.id}'),
                          onPostDeleted: onPostDeleted,
                          userProfileId: widget.userID,
                          servicePost: servicePost, canViewProfile: false,
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
                      onPressed: _handleRefreshOtherUserPost,
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
