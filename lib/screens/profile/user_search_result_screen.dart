import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_event.dart';
import 'package:talbna/blocs/user_action/user_action_state.dart';
import 'package:talbna/blocs/user_follow/user_follow_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/profile/user_card.dart';
class UserSearchResult extends StatefulWidget {
   UserSearchResult({Key? key, required this.currentPage,required this.searchQuery,required this.userHasReachedMax,required this.usersResult, required this.userActionBloc, required this.userID}) : super(key: key);
   final int userID;
   late List<User> usersResult = [];
   final UserActionBloc userActionBloc;
   late int currentPage;
   String searchQuery = '';
   bool userHasReachedMax = false;

   @override
  UserSearchResultState createState() => UserSearchResultState();
}
class UserSearchResultState extends State<UserSearchResult> {
  final ScrollController _scrollSearchController = ScrollController();
  late UserActionBloc _userActionBloc;

  @override
  void initState() {
    super.initState();
    _scrollSearchController.addListener(_onScroll);
    _userActionBloc = context.read<UserActionBloc>();
  }
  @override
  void dispose() {
    _scrollSearchController.dispose();
    widget.usersResult.clear();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.userHasReachedMax &&
        _scrollSearchController.offset >=
            _scrollSearchController.position.maxScrollExtent &&
        !_scrollSearchController.position.outOfRange) {
      _handleLoadMore();
    }
  }
  void _handleLoadMore() {
    widget.currentPage++;
    _userActionBloc
        .add(UserSearchAction(search: widget.searchQuery, page: widget.currentPage));
  }
  Future<void> _handleRefresh() async {
    widget.currentPage = 1;
    widget.userHasReachedMax = false;
    widget.usersResult.clear();
    _userActionBloc
        .add(UserSearchAction(search: widget.searchQuery, page: widget.currentPage));
  }
  Future<bool> _onWillPop() async {
    if (_scrollSearchController.offset > 0) {
      _scrollSearchController.animateTo(
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
      child: BlocListener<UserActionBloc, UserActionState>(
        bloc: widget.userActionBloc,
        listener: (context, state) {
          if (state is UserSearchActionResult) {
            setState(() {
              widget.usersResult = List.from(widget.usersResult)..addAll(state.users);
              widget.userHasReachedMax = state.usersHasReachedMax;
            });
          }
        },
        child: BlocBuilder<UserActionBloc, UserActionState>(
          bloc: widget.userActionBloc,
          builder: (context, state) {
            if (state is UserFollowLoadInProgress && widget.usersResult.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else if (widget.usersResult.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  controller: _scrollSearchController,
                  itemCount: widget.userHasReachedMax ? widget.usersResult.length : widget.usersResult.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= widget.usersResult.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (index >= 0 && index < widget.usersResult.length) {
                      final follower = widget.usersResult[index];
                      return AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,child:
                          UserCard(
                            key: UniqueKey(),
                            follower: follower,
                            userActionBloc: _userActionBloc,
                            isFollower: follower.isFollow!,
                            userId: widget.userID,
                          ));
                    } else {
                      return const Center(child: Text('Invalid index'));
                    }
                  },
                ),
              );
        } else if (state is UserActionFailure) {
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
