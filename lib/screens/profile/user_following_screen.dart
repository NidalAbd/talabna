import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_follow/user_follow_bloc.dart';
import 'package:talbna/blocs/user_follow/user_follow_event.dart';
import 'package:talbna/blocs/user_follow/user_follow_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/profile/user_card.dart';
class UserFollowingScreen extends StatefulWidget {
  const UserFollowingScreen({super.key, required this.userID, required this.user});
  final int userID;
  final User user;
  @override
  UserFollowingScreenState createState() => UserFollowingScreenState();
}
class UserFollowingScreenState extends State<UserFollowingScreen> {
  final ScrollController _scrollController = ScrollController();
  late UserFollowBloc _userFollowBloc;
  late UserActionBloc _userActionBloc;
  int _currentPage = 1;
  late bool _hasReachedMax = false;
  List<User> _following = [];
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _userFollowBloc = context.read<UserFollowBloc>();
    _userActionBloc = context.read<UserActionBloc>();
    _userFollowBloc.add(UserFollowingRequested(user: widget.userID, page: _currentPage));
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _following.clear();
    super.dispose();
  }
  void _onScroll() {
    if (!_hasReachedMax &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _handleLoadMore();
    }
  }
  void _handleLoadMore() {
    _currentPage++;
    _userFollowBloc
        .add(UserFollowingRequested(user: widget.userID, page: _currentPage));
  }
  Future<void> _handleRefresh() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _following.clear();
    _userFollowBloc.add(UserFollowingRequested(user: widget.userID, page: _currentPage));
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: BlocListener<UserFollowBloc, UserFollowState>(
        bloc: _userFollowBloc,
        listener: (context, state) {
          if (state is UserFollowerFollowingSuccess) {
            setState(() {
              _following = List.from(_following)..addAll(state.users);
              _hasReachedMax = state.hasReachedMax;
            });
          }
        },
        child: BlocBuilder<UserFollowBloc, UserFollowState>(
          bloc: _userFollowBloc,
          builder: (context, state) {
            if (state is UserFollowLoadInProgress && _following.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else if (_following.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _hasReachedMax ? _following.length : _following.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= _following.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (index >= 0 && index < _following.length) {
                      final follower = _following[index];
                      return AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,child:
                      UserCard(
                        key: UniqueKey(),
                        follower: follower,
                        userActionBloc: _userActionBloc,
                        userId: widget.userID, user: widget.user,
                      ));
                    } else {
                      return const Center(child: Text('Invalid index'));
                    }
                  },
                ),
              );
            } else if (state is UserFollowLoadFailure) {
              return Center(child: Text(state.error));
            } else {
              return const Center(child: Text('No following found.'));
            }
          },
        ),
      ),
    );
  }
}
