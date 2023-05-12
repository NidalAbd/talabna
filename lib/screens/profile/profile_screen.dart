import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_event.dart';
import 'package:talbna/blocs/other_users/user_profile_state.dart';
import 'package:talbna/screens/interaction_widget/report_tile.dart';
import 'package:talbna/screens/profile/add_point_screen.dart';
import 'package:talbna/screens/profile/purchase_request_screen.dart';
import 'package:talbna/screens/profile/user_followers_screen.dart';
import 'package:talbna/screens/profile/user_following_screen.dart';
import 'package:talbna/screens/profile/user_info_widget.dart';
import 'package:talbna/screens/service_post/user_post_screen.dart';
import 'package:talbna/screens/widgets/custom_tab_profile.dart';
import 'package:talbna/screens/widgets/error_widget.dart';
import 'package:talbna/utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    Key? key,
    required this.fromUser,
    required this.toUser,
  }) : super(key: key);
  final int fromUser;
  final int toUser;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late OtherUserProfileBloc _userProfileBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _userProfileBloc = context.read<OtherUserProfileBloc>()
      ..add(OtherUserProfileRequested(id: widget.toUser));
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
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text(user.userName ?? 'no data'),
              actions: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(
                          '${Constants.apiBaseUrl}/storage/${user.photos?.first.src}'),
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
                                  leading: const Icon(Icons.perm_identity),
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
                                    leading: const Icon(Icons.report),
                                    title: const Text('Report'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ReportTile(
                                              type: 'user',
                                              userId: widget.fromUser,
                                            );
                                          });
                                    }),
                                ListTile(
                                  leading: const Icon(Icons.attach_money),
                                  title: const Text('Add Points'),
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
                  CustomTab(title: 'Posts', count: user.servicePostsCount ?? 0),
                  CustomTab(
                      title: 'Followers', count: user.followersCount ?? 0),
                  CustomTab(
                      title: 'Following', count: user.followingCount ?? 0),
                  const Tab(text: 'Info'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                Center(
                  child: UserPostScreen(userID: user.id),
                ),
                Center(
                  child: UserFollowerScreen(
                    userID: user.id,
                  ),
                ),
                Center(
                  child: UserFollowingScreen(
                    userID: user.id,
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
          return ErrorCustomWidget.show(context, state.error);
        } else {
          return ErrorCustomWidget.show(context, 'No user profile data found.');
        }
      },
    );
  }
}
