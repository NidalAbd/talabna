import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_follow/user_follow_bloc.dart';
import 'package:talbna/blocs/user_follow/user_follow_event.dart';
import 'package:talbna/blocs/user_follow/user_follow_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/profile/user_card.dart';

import '../widgets/shimmer_widgets.dart';

class UserFollowerScreen extends StatefulWidget {
  const UserFollowerScreen({super.key, required this.userID, required this.user});
  final int userID;
  final User user;
  @override
  UserFollowerScreenState createState() => UserFollowerScreenState();
}

class UserFollowerScreenState extends State<UserFollowerScreen> with AutomaticKeepAliveClientMixin {
  final Language _language = Language();
  final ScrollController _scrollSearchController = ScrollController();
  late UserFollowBloc _userFollowBloc;
  late UserActionBloc _userActionBloc;

  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<User> _followers = [];
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollSearchController.addListener(_onScroll);
    _userFollowBloc = context.read<UserFollowBloc>();
    _userActionBloc = context.read<UserActionBloc>();
    _fetchFollowers();
  }

  void _fetchFollowers() {
    setState(() {
      _isLoading = true;
    });
    _userFollowBloc.add(UserFollowerRequested(user: widget.userID, page: _currentPage));
  }

  @override
  void dispose() {
    _scrollSearchController.removeListener(_onScroll);
    _scrollSearchController.dispose();
    _followers.clear();
    super.dispose();
  }

  void _onScroll() {
    if (!_isLoading &&
        !_hasReachedMax &&
        _scrollSearchController.hasClients &&
        _scrollSearchController.offset >=
            _scrollSearchController.position.maxScrollExtent - 200 &&
        !_scrollSearchController.position.outOfRange) {
      _handleLoadMore();
    }
  }

  void _handleLoadMore() {
    setState(() {
      _isLoading = true;
    });
    _currentPage++;
    _userFollowBloc.add(UserFollowerRequested(user: widget.userID, page: _currentPage));
  }

  Future<void> _handleRefresh() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _followers.clear();
    _fetchFollowers();
    return Future.value();
  }

  Future<bool> _onWillPop() async {
    if (_scrollSearchController.hasClients && _scrollSearchController.position.pixels > 0) {
      _scrollSearchController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      _handleRefresh();
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: BlocListener<UserFollowBloc, UserFollowState>(
        bloc: _userFollowBloc,
        listener: (context, state) {
          if (state is UserFollowerFollowingSuccess) {
            setState(() {
              _followers = List.from(_followers)..addAll(state.users);
              _hasReachedMax = state.hasReachedMax;
              _isInitialized = true;
              _isLoading = false;
            });
          } else if (state is UserFollowLoadFailure) {
            setState(() {
              _isInitialized = true;
              _isLoading = false;
            });
          }
        },
        child: BlocBuilder<UserFollowBloc, UserFollowState>(
          bloc: _userFollowBloc,
          builder: (context, state) {
            if (state is UserFollowLoadInProgress && !_isInitialized) {
              return const UserFollowerScreenShimmer();
            } else if (_followers.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: _handleRefresh,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkSecondaryColor
                    : AppTheme.lightPrimaryColor,
                child: ListView.builder(
                  controller: _scrollSearchController,
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _hasReachedMax ? _followers.length : _followers.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= _followers.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.darkSecondaryColor
                                : AppTheme.lightPrimaryColor,
                            strokeWidth: 3,
                          ),
                        ),
                      );
                    }
                    if (index >= 0 && index < _followers.length) {
                      final follower = _followers[index];
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeIn,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: UserCard(
                            key: ValueKey(follower.id),
                            follower: follower,
                            userActionBloc: _userActionBloc,
                            userId: widget.userID,
                            user: widget.user,
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              );
            } else {
              return RefreshIndicator(
                onRefresh: _handleRefresh,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkSecondaryColor
                    : AppTheme.lightPrimaryColor,
                child: ListView(
                  controller: _scrollSearchController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height / 4),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(context).disabledColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.people_alt_outlined,
                              size: 48,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppTheme.darkSecondaryColor
                                  : AppTheme.lightPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            state is UserFollowLoadFailure
                                ? state.error
                                : _language.tNoFollowersFoundText(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).disabledColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh,
                                  size: 16,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _language.tPullToRefreshText(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}