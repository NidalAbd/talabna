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

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  late UserActionBloc _userActionBloc;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  int _currentPage = 1;
  bool _isSearching = false;
  bool _userHasReachedMax = false;
  bool _postHasReachedMax = false;

  List<User> users = <User>[];
  List<ServicePost> servicePosts = <ServicePost>[];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    _userActionBloc = context.read<UserActionBloc>();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final bool shouldLoadMore = _tabController.index == 0
          ? !_userHasReachedMax
          : !_postHasReachedMax;

      if (shouldLoadMore) {
        _currentPage++;
        _userActionBloc.add(UserSearchAction(search: _searchQuery, page: _currentPage));
      }
    }
  }

  void _handleSearch(String query) {
    if (query.isEmpty) return;

    setState(() {
      _searchQuery = query;
      _currentPage = 1;
      _isSearching = true;
      _userHasReachedMax = false;
      _postHasReachedMax = false;
      users.clear();
      servicePosts.clear();
    });

    _userActionBloc.add(UserSearchAction(search: query, page: 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: theme.primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildSearchField(theme),
            ),
          ),
        ),
      ),
      body: BlocConsumer<UserActionBloc, UserActionState>(
        listener: (context, state) {
          if (state is UserSearchActionResult) {
            setState(() {
              if (_currentPage == 1) {
                users = List.from(state.users);
                servicePosts = List.from(state.servicePosts);
              } else {
                users.addAll(state.users);
                servicePosts.addAll(state.servicePosts);
              }
              _userHasReachedMax = state.usersHasReachedMax;
              _postHasReachedMax = state.servicePostsHasReachedMax;
            });
          } else if (state is UserActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  behavior: SnackBarBehavior.floating,
                )
            );
          }
        },
        builder: (context, state) {
          if (state is UserActionInProgress && _currentPage == 1) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.primaryColor,
              ),
            );
          }

          if (!_isSearching) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: theme.primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Search for users or posts',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }

          if (users.isEmpty && servicePosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: theme.primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: theme.primaryColor,
                  unselectedLabelColor: theme.hintColor,
                  indicatorColor: theme.primaryColor,
                  indicatorWeight: 3,
                  labelStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: theme.textTheme.titleMedium,
                  tabs: [
                    Tab(
                      text: 'Users (${users.length})',
                    ),
                    Tab(
                      text: 'Posts (${servicePosts.length})',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUsersList(theme),
                    _buildPostsList(theme),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        textInputAction: TextInputAction.search,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search users and posts...',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.hintColor,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.hintColor,
          ),
          suffixIcon: _isSearching
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: theme.hintColor,
            ),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _isSearching = false;
                users.clear();
                servicePosts.clear();
              });
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onSubmitted: _handleSearch,
        onChanged: (value) {
          if (value.isNotEmpty) {
            _handleSearch(value);
          }
        },
      ),
    );
  }

  Widget _buildUsersList(ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length + (_userHasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == users.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: theme.primaryColor,
              ),
            ),
          );
        }

        return UserCard(
          follower: users[index],
          userActionBloc: _userActionBloc,
          userId: widget.userID,
          user: widget.user,
        );
      },
    );
  }

  Widget _buildPostsList(ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: servicePosts.length + (_postHasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == servicePosts.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: theme.primaryColor,
              ),
            ),
          );
        }

        return ServicePostCard(
          onPostDeleted: (int postId) {
            setState(() {
              servicePosts.removeWhere((post) => post.id == postId);
            });
          },
          servicePost: servicePosts[index],
          canViewProfile: true,
          userProfileId: widget.userID,
          user: widget.user,
        );
      },
    );
  }
}