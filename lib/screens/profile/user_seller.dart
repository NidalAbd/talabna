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
import 'package:talbna/provider/language.dart'; // Added Language import

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
  final Language _language = Language(); // Added Language instance

  int _currentPage = 1;
  late bool _hasReachedMax = false;
  List<User> _sellers = [];

  @override
  void initState() {
    super.initState();
    _scrollSearchController.addListener(_onScroll);
    _userFollowBloc = context.read<UserFollowBloc>();
    _userActionBloc = context.read<UserActionBloc>();
    _userFollowBloc.add(UserSellerRequested(page: _currentPage));
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

  // Fixed with proper null safety handling
  String getLocationText(User follower) {
    final String currentLang = _language.getLanguage();

    if (follower.country != null && follower.city != null) {
      return '${follower.country?.getName(currentLang) ?? ""}, ${follower.city?.getName(currentLang) ?? ""}';
    }
    else if (follower.country != null) {
      return follower.country?.getName(currentLang) ?? "";
    }
    else if (follower.city != null) {
      return follower.city?.getName(currentLang) ?? "";
    }
    else {
      return '';
    }
  }

  void _handleLoadMore() {
    _currentPage++;
    _userFollowBloc.add(UserSellerRequested(page: _currentPage));
  }

  Future<void> _handleRefresh() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _sellers.clear();
    _userFollowBloc.add(UserSellerRequested(page: _currentPage));
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
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const SizedBox(width: 5),
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
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        follower.userName ?? 'No Name',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Fixed location text with null safety
                                      Text(
                                        getLocationText(follower),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).textTheme.bodySmall?.color,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 30),
                                WhatsAppIconButtonWidget(
                                  width: 40,
                                  whatsAppNumber: follower.watsNumber,
                                ),
                                const SizedBox(width: 10),
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