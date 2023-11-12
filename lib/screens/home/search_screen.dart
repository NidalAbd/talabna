import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_event.dart';
import 'package:talbna/blocs/user_action/user_action_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/profile/user_card.dart';
import 'package:talbna/screens/service_post/service_post_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key, required this.userID, required this.user}) : super(key: key);
  final int userID;
  final User user;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  late UserActionBloc _userActionBloc;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;

  bool _userHasReachedMax = false;
  bool _postHasReachedMax = false;

  List<User> users = <User>[];
  List<ServicePost> servicePosts = <ServicePost>[];
  late Function onPostDeleted = (int postId) {
    setState(() {
      servicePosts.removeWhere((post) => post.id == postId);
    });
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _userActionBloc = context.read<UserActionBloc>();
  }

  void _onScroll() {
    if ((!_userHasReachedMax || !_postHasReachedMax) &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _handleLoadMore();
    }
  }

  void _handleLoadMore() {
    _currentPage++;
    _userActionBloc
        .add(UserSearchAction(search: _searchQuery, page: _currentPage));
  }
  @override
  void dispose() {
    _scrollController.dispose();
    users.clear();
    servicePosts.clear();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: _buildSearchField(),
        actions: _buildActions(),
      ),
      body: BlocListener<UserActionBloc, UserActionState>(
        bloc: _userActionBloc,
        listener: (context, state) {
          if (state is UserSearchActionResult) {
            setState(() {
              users = List.from(users)..addAll(state.users);
              _userHasReachedMax = state.usersHasReachedMax;
            });
          }
        },
        child: BlocConsumer<UserActionBloc, UserActionState>(
          listener: (context, state) {
            if (state is UserActionFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, state) {
            print(state);
            if (state is UserActionInProgress && _currentPage == 1) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is UserSearchActionResult) {
              if (state.users.isEmpty && state.servicePosts.isEmpty) {
                return const Center(
                  child: Text('No results found.'),
                );
              }
              users.addAll(state.users);
              servicePosts.addAll(state.servicePosts);
              _userHasReachedMax = state.usersHasReachedMax;
              _postHasReachedMax = state.servicePostsHasReachedMax;

              return DefaultTabController(
                length: 2,
                child:  Column(
                    children: <Widget>[
                      const TabBar(
                        tabs:  <Widget>[
                          Tab(text: 'Users'),
                          Tab(text: 'Posts'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: <Widget>[
                            _buildUserListView(),
                            _buildPostListView(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration:  const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
      ),
      style: const TextStyle(fontSize: 18.0),
      onChanged: (query) => setState(() {
        _isSearching = true;
        _searchQuery = query;
        _userHasReachedMax = false;
        _postHasReachedMax = false;
        _currentPage = 1;
        users.clear();
        servicePosts.clear();
        _userActionBloc.add(UserSearchAction(search: _searchQuery, page: _currentPage));
      }),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            setState(() {
              _searchQueryController.clear();
              _searchQuery = '';
              _isSearching = false;
              _userHasReachedMax = false;
              _postHasReachedMax = false;
              _currentPage = 1;
              users.clear();
              servicePosts.clear();
            });
          },
        ),
      ];
    } else {
      return <Widget>[];
    }
  }

  Widget _buildUserListView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: users.length + (_userHasReachedMax ? 0 : 1),
      itemBuilder: (BuildContext context, int index) {
        if (index == users.length && !_userHasReachedMax) {
          return const Center(child: CircularProgressIndicator());
        } else {
          final User user = users[index];
          return UserCard(
            follower: user,
            userActionBloc: _userActionBloc,
            userId: widget.userID, user: widget.user,
          );
        }
      },
    );
  }

  Widget _buildPostListView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: servicePosts.length + (_postHasReachedMax ? 0 : 1),
      itemBuilder: (BuildContext context, int index) {
        if (index == servicePosts.length && !_postHasReachedMax) {
          return const Center(child: CircularProgressIndicator());
        } else {
          final ServicePost post = servicePosts[index];
          return ServicePostCard(
            onPostDeleted: onPostDeleted,
            servicePost: post,
            canViewProfile: true,
            userProfileId: widget.userID, user: widget.user,
          );
        }
      },
    );
  }
}
