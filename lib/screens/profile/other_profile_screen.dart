import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_event.dart';
import 'package:talbna/blocs/other_users/user_profile_state.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_event.dart';
import 'package:talbna/blocs/user_action/user_action_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/interaction_widget/report_tile.dart';
import 'package:talbna/screens/profile/add_point_screen.dart';
import 'package:talbna/screens/profile/user_followers_screen.dart';
import 'package:talbna/screens/profile/user_following_screen.dart';
import 'package:talbna/screens/profile/user_info_widget.dart';
import 'package:talbna/screens/service_post/other_user_post_screen.dart';
import 'package:talbna/screens/widgets/custom_tab_profile.dart';
import 'package:talbna/screens/widgets/error_widget.dart';
import 'package:talbna/screens/widgets/full_screen_image.dart';
import 'package:talbna/utils/constants.dart';

import '../../provider/language.dart';

class OtherProfileScreen extends StatefulWidget {
  const OtherProfileScreen(
      {Key? key,
      required this.fromUser,
      required this.toUser,
      required this.isOtherProfile, required this.user})
      : super(key: key);
  final bool isOtherProfile;
  final int fromUser;
  final int toUser;
  final User user;

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen>
    with SingleTickerProviderStateMixin {
  final Language _language = Language();

  late final TabController _tabController;
  late OtherUserProfileBloc _userProfileBloc;
  late UserActionBloc userActionBloc;
  late bool isFollowing = false;
  late bool isHimSelf = true ;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _userProfileBloc = context.read<OtherUserProfileBloc>()
      ..add(OtherUserProfileRequested(id: widget.toUser));
    userActionBloc = context.read<UserActionBloc>();
    userActionBloc.add(GetUserFollow(user: widget.toUser));
    if(widget.toUser == widget.fromUser){
      isHimSelf = false;
    }
  }

  void _setClipboardData(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtherUserProfileBloc, OtherUserProfileState>(
      bloc: _userProfileBloc,
      builder: (BuildContext context, OtherUserProfileState state) {
        if (state is OtherUserProfileInitial ||
            state is OtherUserProfileLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is OtherUserProfileLoadSuccess) {
          final user = state.user;
          final  List<String> userImageURl = ['${user.photos?.first.src}'];
          return Scaffold(
            appBar: AppBar(
              leadingWidth: 30,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(
                            mediaUrls: userImageURl,
                            initialIndex: userImageURl.length,
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                          '${user.photos?.first.src}'),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Text(user.userName ?? 'no data', overflow: TextOverflow.clip,),
                ],
              ),
              actions: [
                Row(
                  children: [
                    BlocConsumer<UserActionBloc, UserActionState>(
                      listener: (context, state) {
                        if (state is UserFollowUnFollowToggled) {
                          isFollowing = state.isFollower; // Update the isFollowing variable
                          final message = state.isFollower
                              ? 'You are now following ${user.userName}'
                              : 'You have unfollowed ${user.userName}';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is GetFollowUserSuccess) {
                          isFollowing = state.followSuccess;
                        }
                        return Visibility(
                          visible: isHimSelf,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                            child: TextButton(
                              onPressed: () {
                                context.read<UserActionBloc>().add(
                                  ToggleUserMakeFollowEvent(user: widget.toUser),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: isFollowing ? Colors.grey : Colors.blue, // Customize the button color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                isFollowing ? 'Unfollow' : 'Follow',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 30,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Wrap(
                              children: [
                                ListTile(
                                  onLongPress: () =>
                                      _setClipboardData(user.id.toString()),
                                  leading: const Icon(
                                    Icons.perm_identity,
                                  ),
                                  title: Text(
                                    user.id.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                    leading: const Icon(
                                      Icons.report,
                                    ),
                                    title:  Text(
                                      _language.tReportText(),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? AppTheme.lightPrimaryColor.withOpacity(0.8)
                                                  : AppTheme.darkPrimaryColor.withOpacity(0.8),
                                              child: ReportTile(
                                                type: 'user',
                                                userId: widget.fromUser,
                                              ),
                                            );
                                          });
                                    }),
                                ListTile(
                                  leading: const Icon(
                                    Icons.attach_money,
                                  ),
                                  title:  Text(
                                    _language.tConvertPointsText(),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AddPointScreen(
                                          fromUserID: widget.fromUser,
                                          toUserId: widget.toUser,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  CustomTab(title: _language.tPostsText(), count: user.servicePostsCount ?? 0),
                  CustomTab(
                      title: _language.tFollowersText(), count: user.followersCount ?? 0),
                  CustomTab(
                      title: _language.tFollowingText(), count: user.followingCount ?? 0),
                   Tab(text: _language.tOverviewText()),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                Center(
                  child: OtherUserPostScreen(userID: widget.toUser, user: widget.user,),
                ),
                Center(
                  child: UserFollowerScreen(
                    userID: user.id, user: user,
                  ),
                ),
                Center(
                  child: UserFollowingScreen(
                    userID: user.id, user: user,
                  ),
                ),
                Center(
                  child: UserInfoWidget(
                    userId: user.id,
                    user: user,
                  ),
                ),
              ],
            ),
          );
        } else if (state is OtherUserProfileLoadFailure) {
          return ErrorCustomWidget.show(context, message: state.error);
        } else {
          return ErrorCustomWidget.show(context,
              message: 'No user profile data found.');
        }
      },
    );
  }
}
