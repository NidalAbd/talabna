import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/screens/service_post/service_post_card.dart';

class FavoritePostScreen extends StatefulWidget {
  const FavoritePostScreen({Key? key, required this.userID}) : super(key: key);
  final int userID;

  @override
  FavoritePostScreenState createState() => FavoritePostScreenState();
}

class FavoritePostScreenState extends State<FavoritePostScreen> {
  final ScrollController _scrollController = ScrollController();
  late ServicePostBloc _servicePostBloc;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<ServicePost> _servicePostsFavourite = [];
  late Function onPostDeleted = (int postId) {
    setState(() {
      _servicePostsFavourite.removeWhere((post) => post.id == postId);
    });
  };
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _servicePostBloc.add(GetServicePostsByUserFavouriteEvent(widget.userID, _currentPage));
  }
  void _onScroll() {
    if (!_hasReachedMax &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _currentPage++;
      _servicePostBloc.add(GetServicePostsByUserFavouriteEvent(widget.userID, _currentPage));
    }
  }

  Future<void> _handleRefresh() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _servicePostsFavourite.clear();
    _servicePostBloc.add(GetServicePostsByUserFavouriteEvent(widget.userID, _currentPage));
  }

  void _handleServicePostLoadSuccess(
      List<ServicePost> servicePosts, bool hasReachedMax) {
    setState(() {
      _hasReachedMax = hasReachedMax;
      _servicePostsFavourite = [..._servicePostsFavourite, ...servicePosts];
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: BlocListener<ServicePostBloc, ServicePostState>(
          bloc: _servicePostBloc,
          listener: (context, state) {
            if (state is ServicePostLoadSuccess) {
              _handleServicePostLoadSuccess(state.servicePosts, state.hasReachedMax);
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
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
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
                            servicePost: servicePost, canViewProfile: false,
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

