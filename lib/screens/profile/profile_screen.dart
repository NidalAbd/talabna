import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:talbna/screens/profile/user_followers_screen.dart';
import 'package:talbna/screens/profile/user_following_screen.dart';
import 'package:talbna/screens/profile/user_info_widget.dart';
import 'dart:ui';

import '../../blocs/other_users/user_profile_bloc.dart';
import '../../blocs/other_users/user_profile_event.dart';
import '../../blocs/other_users/user_profile_state.dart';
import '../../data/models/user.dart';
import '../../provider/language.dart';
import '../../utils/constants.dart';
import '../../utils/photo_image_helper.dart';
import '../interaction_widget/report_tile.dart';
import '../service_post/other_post_screen.dart';
import '../widgets/error_widget.dart';
import 'add_point_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.fromUser,
    required this.toUser,
    required this.user,
  });

  final int fromUser;
  final int toUser;
  final User user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late OtherUserProfileBloc _userProfileBloc;
  final Language _language = Language();
  final ScrollController _scrollController = ScrollController();
  bool _isTitleVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _userProfileBloc = context.read<OtherUserProfileBloc>();

    // Move the event dispatch to the first frame to ensure context is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userProfileBloc.add(OtherUserProfileRequested(id: widget.toUser));
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Adjust this value based on your design
    if (_scrollController.offset > 200 && !_isTitleVisible) {
      setState(() {
        _isTitleVisible = true;
      });
    } else if (_scrollController.offset <= 200 && _isTitleVisible) {
      setState(() {
        _isTitleVisible = false;
      });
    }
  }

  void _setClipboardData(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    // Using a safer way to show SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ID copied to clipboard'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }


  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<OtherUserProfileBloc, OtherUserProfileState>(
        builder: (BuildContext context, OtherUserProfileState state) {
          if (state is OtherUserProfileLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OtherUserProfileLoadSuccess) {
            final user = state.user;
            return NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 300.0,
                    pinned: true,
                    title: _isTitleVisible
                        ? Text(user.userName ?? 'Profile')
                        : null,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showMoreOptions(context, user),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildProfileHeader(user),
                    ),
                    bottom: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white, // Selected tab text color
                      unselectedLabelColor: Colors.white70, // Unselected tab text color with better visibility
                      indicatorColor: Colors.white, // Indicator line color
                      indicatorWeight: 3, // Thicker indicator for better visibility
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      tabs: [
                        Tab(text: _language.tPostsText()),
                        Tab(text: _language.tFollowersText()),
                        Tab(text: _language.tFollowingText()),
                        Tab(text: _language.tOverviewText()),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  UserPostScreen(userID: user.id, user: user),
                  UserFollowerScreen(userID: user.id, user: widget.user),
                  UserFollowingScreen(userID: user.id, user: widget.user),
                  UserInfoWidget(userId: user.id, user: user),
                ],
              ),
            );
          } else if (state is OtherUserProfileLoadFailure) {
            return ErrorCustomWidget.show(context, message: state.error);
          } else {
            return ErrorCustomWidget.show(context, message: 'No user profile data found.');
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred background image
        if (user.photos != null && user.photos!.isNotEmpty)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Image.network(
              ProfileImageHelper.getProfileImageUrl(user),
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),

        // Profile content
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Picture
            Hero(
              tag: 'profile_image_${user.id}',
              child: CircleAvatar(
                radius: 60,
                backgroundImage: CachedNetworkImageProvider(
                  ProfileImageHelper.getProfileImageUrl(user),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Username
            Text(
              user.userName ?? 'User Name',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Bio or additional info (if available)

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatColumn('Posts', user.servicePostsCount ?? 0),
                  const SizedBox(width: 32),
                  _buildStatColumn('Followers', user.followersCount ?? 0),
                  const SizedBox(width: 32),
                  _buildStatColumn('Following', user.followingCount ?? 0),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showMoreOptions(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                onLongPress: () => _setClipboardData(user.id.toString()),
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
                title: Text(_language.tReportText()),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return ReportTile(
                        type: 'user',
                        userId: widget.fromUser,
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: Text(_language.tConvertPointsText()),
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
          ),
        );
      },
    );
  }
}