import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_follow/user_follow_bloc.dart';
import 'package:talbna/blocs/user_follow/user_follow_event.dart';
import 'package:talbna/blocs/user_follow/user_follow_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/interaction_widget/phone_Icon_button.dart';
import 'package:talbna/screens/interaction_widget/phone_button.dart';
import 'package:talbna/screens/interaction_widget/watsapp_button.dart';
import 'package:talbna/screens/interaction_widget/watsapp_icon_button.dart';
import 'package:talbna/screens/profile/user_card.dart';
import 'package:talbna/utils/constants.dart';
class UserSellerScreen extends StatefulWidget {
  const UserSellerScreen({Key? key, required this.userID}) : super(key: key);
  final int userID;
  @override
  UserSellerScreenState createState() => UserSellerScreenState();
}
class UserSellerScreenState extends State<UserSellerScreen> {
  final ScrollController _scrollSearchController = ScrollController();
  late UserFollowBloc _userFollowBloc;
  late UserActionBloc _userActionBloc;

  int _currentPage = 1;
  late bool _hasReachedMax = false;
  List<User> _sellers = [];
  @override
  void initState() {
    super.initState();
    _scrollSearchController.addListener(_onScroll);
    _userFollowBloc = context.read<UserFollowBloc>();
    _userActionBloc = context.read<UserActionBloc>();
    _userFollowBloc.add(UserSellerRequested( page: _currentPage));
  }
  @override
  void dispose() {
    _scrollSearchController.dispose();
    _sellers.clear();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasReachedMax &&
        _scrollSearchController.offset >=
            _scrollSearchController.position.maxScrollExtent &&
        !_scrollSearchController.position.outOfRange) {
      _handleLoadMore();
    }
  }
  void _handleLoadMore() {
    _currentPage++;
    _userFollowBloc.add(UserSellerRequested( page: _currentPage));
  }
  Future<void> _handleRefresh() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _sellers.clear();
    _userFollowBloc.add(UserSellerRequested( page: _currentPage));
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
      child: BlocListener<UserFollowBloc, UserFollowState>(
        bloc: _userFollowBloc,
        listener: (context, state) {
          if (state is UserSellerSuccessState) {
            setState(() {
              _sellers = List.from(_sellers)..addAll(state.users);
              _hasReachedMax = state.hasReachedMax;
            });
          }
        },
        child: BlocBuilder<UserFollowBloc, UserFollowState>(
          bloc: _userFollowBloc,
          builder: (context, state) {
            if (state is UserFollowLoadInProgress && _sellers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else if (_sellers.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  controller: _scrollSearchController,
                  itemCount: _hasReachedMax ? _sellers.length : _sellers.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= _sellers.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (index >= 0 && index < _sellers.length) {
                      final follower = _sellers[index];
                      return AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          child:Card(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.lightForegroundColor
                                : AppTheme.darkForegroundColor,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: Image.network(
                                      '${Constants.apiBaseUrl}/storage/${follower.photos!.first.src}',
                                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                        return const CircleAvatar(
                                          radius: 30,
                                          backgroundImage: AssetImage('assets/avatar.png'),
                                        );
                                      },
                                    ).image,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      follower.userName!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 30,
                                  ),
                                  WhatsAppIconButtonWidget(width: 20,whatsAppNumber: follower.watsNumber,),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),

                      );
                    } else {
                      return const Center(child: Text('Invalid index'));
                    }
                  },
                ),
              );
        } else if (state is UserFollowLoadFailure) {
          return Center(child: Text(state.error));
        } else {
          return const Center(child: Text('No Seller found.'));
        }
      },
      ),
      ),
    );
  }
}