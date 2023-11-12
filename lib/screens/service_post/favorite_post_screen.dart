import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/service_post/service_post_card.dart';

import '../../provider/language.dart';

class FavoritePostScreen extends StatefulWidget {
  const FavoritePostScreen({Key? key, required this.userID, required this.user}) : super(key: key);
  final int userID;
  final User user;

  @override
  FavoritePostScreenState createState() => FavoritePostScreenState();
}

class FavoritePostScreenState extends State<FavoritePostScreen> {
  final ScrollController _scrollFavouritePostController = ScrollController();
  late ServicePostBloc _servicePostBloc;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  final Language _language = Language();

  List<ServicePost> _servicePostsFavourite = [];
  late Function onPostDeleted = (int postId) {
    setState(() {
      _servicePostsFavourite.removeWhere((post) => post.id == postId);
    });
  };
  @override
  void initState() {
    super.initState();
    _scrollFavouritePostController.addListener(_onScrollFavouritePost);
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _servicePostBloc.add(GetServicePostsByUserFavouriteEvent(widget.userID, _currentPage));
  }
  void _onScrollFavouritePost() {
    if (!_hasReachedMax &&
        _scrollFavouritePostController.offset >=
            _scrollFavouritePostController.position.maxScrollExtent &&
        !_scrollFavouritePostController.position.outOfRange) {
      _currentPage++;
      _servicePostBloc.add(GetServicePostsByUserFavouriteEvent(widget.userID, _currentPage));
    }
  }

  Future<void> _handleFavouritePostRefresh() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _servicePostsFavourite.clear();
    _servicePostBloc.add(GetServicePostsByUserFavouriteEvent(widget.userID, _currentPage));
  }

  void _handleFavouritePostLoadSuccess(
      List<ServicePost> servicePosts, bool hasReachedMax) {
    setState(() {
      _hasReachedMax = hasReachedMax;
      _servicePostsFavourite = [..._servicePostsFavourite, ...servicePosts];
    });
  }
  Future<bool> _onWillPopFavourite() async {
    if (_scrollFavouritePostController.offset > 0) {
      _scrollFavouritePostController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
      );
      // Wait for the duration of the scrolling animation before refreshing
      await Future.delayed(const Duration(milliseconds: 1000));
      // Trigger a refresh after reaching the top
      _handleFavouritePostRefresh();
      return false;
    } else {
      return true;
    }
  }
  @override
  void dispose() {
    _servicePostsFavourite.clear();
    _scrollFavouritePostController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(_language.tFavoriteText()),
      ),
      body: WillPopScope(
        onWillPop: _onWillPopFavourite,
        child: BlocListener<ServicePostBloc, ServicePostState>(
          bloc: _servicePostBloc,
          listener: (context, state) {
            if (state is ServicePostLoadSuccess) {
              _handleFavouritePostLoadSuccess(state.servicePosts, state.hasReachedMax);
            }
          },
          child: BlocBuilder<ServicePostBloc, ServicePostState>(
            bloc: _servicePostBloc,
            builder: (context, state) {
              if (state is ServicePostLoading && _servicePostsFavourite.isEmpty) {
                // show loading indicator
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (_servicePostsFavourite.isNotEmpty) {
                // show list of service posts
                return RefreshIndicator(
                  onRefresh: _handleFavouritePostRefresh,
                  child: ListView.builder(
                    controller: _scrollFavouritePostController,
                    itemCount: _hasReachedMax
                        ? _servicePostsFavourite.length
                        : _servicePostsFavourite.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= _servicePostsFavourite.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final servicePost = _servicePostsFavourite[index];
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                        child: ServicePostCard(
                            key: UniqueKey(), // Add this line
                            onPostDeleted: onPostDeleted,
                            userProfileId: widget.userID,
                            servicePost: servicePost, canViewProfile: false, user: widget.user,
                        ),
                      );
                    },
                  )

                );
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

