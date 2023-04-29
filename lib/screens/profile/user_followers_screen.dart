import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_event.dart';
import 'package:talbna/blocs/other_users/user_profile_state.dart';
import 'package:talbna/blocs/user_follow/user_follow_bloc.dart';
import 'package:talbna/blocs/user_follow/user_follow_event.dart';
import 'package:talbna/blocs/user_follow/user_follow_state.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/profile/user_card.dart';
class UserFollowerScreen extends StatefulWidget {
  const UserFollowerScreen({Key? key, required this.userID}) : super(key: key);
  final int userID;
  @override
  UserFollowerScreenState createState() => UserFollowerScreenState();
}
class UserFollowerScreenState extends State<UserFollowerScreen> {
  final ScrollController _scrollController = ScrollController();
  late UserFollowBloc _userFollowBloc;
  int _currentPage = 1;
  late bool _hasReachedMax = false;
  List<User> _followers = [];
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _userFollowBloc = context.read<UserFollowBloc>();
    _userFollowBloc.add(UserFollowerRequested(user: widget.userID, page: _currentPage));
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _followers.clear();
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
    _userFollowBloc.add(UserFollowerRequested(user: widget.userID, page: _currentPage));
  }
  Future<void> _handleRefresh() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _followers.clear();
    _userFollowBloc.add(UserFollowerRequested(user: widget.userID, page: _currentPage));
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
              _followers = List.from(_followers)..addAll(state.users);
              _hasReachedMax = state.hasReachedMax;
            });
          }
        },
        child: BlocBuilder<UserFollowBloc, UserFollowState>(
          bloc: _userFollowBloc,
          builder: (context, state) {
            if (state is UserFollowLoadInProgress && _followers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else if (_followers.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _hasReachedMax ? _followers.length : _followers.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= _followers.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (index >= 0 && index < _followers.length) {
                      final follower = _followers[index];
                      return AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,child: UserCard(follower: follower));
                    } else {
                      return const Center(child: Text('Invalid index'));
                    }
                  },
                ),
              );
        } else if (state is UserFollowLoadFailure) {
          return Center(child: Text(state.error));
        } else {
          return const Center(child: Text('No followers found.'));
        }
      },
      ),
      ),
    );
  }
}
