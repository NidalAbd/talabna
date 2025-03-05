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
import '../../utils/photo_image_helper.dart';
import '../interaction_widget/report_tile.dart';
import '../service_post/other_post_screen.dart';
import '../widgets/error_widget.dart';
import 'add_point_screen.dart';

// Add this safeguard function to safely show SnackBars
void safeShowSnackBar(BuildContext context, String message) {
  if (context == null || !Navigator.canPop(context)) {
    print('Warning: Invalid context for SnackBar');
    return;
  }

  try {
    // Clear any existing SnackBars first
    ScaffoldMessenger.of(context).clearSnackBars();

    // Build the SnackBar first to avoid null issues during build
    final snackBar = SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    );

    // Show the SnackBar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } catch (e) {
    print('Error showing SnackBar: $e');
  }
}

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

    // Defer bloc operations until after initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _userProfileBloc = BlocProvider.of<OtherUserProfileBloc>(context);
        _userProfileBloc.add(OtherUserProfileRequested(id: widget.toUser));
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
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

  // Modified safe clipboard function
  void _setClipboardData(String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    // Use a simple tooltip or dialog instead of SnackBar
    if (mounted) {
      // Use a dialog which is less likely to cause null issues
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => AlertDialog(
          content: Text('ID copied to clipboard'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('OK'),
            ),
          ],
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
    // Make sure we have a Scaffold as the direct parent of the BlocBuilder
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
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
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
            // Use a simple error widget instead of potentially problematic one
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${state.error}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        _userProfileBloc.add(OtherUserProfileRequested(id: widget.toUser));
                      }
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            // Use a simple placeholder widget
            return Center(
              child: Text('No user profile data found.'),
            );
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
              ProfileImageHelper.getProfileImageUrl(user.photos?.first),
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
                  ProfileImageHelper.getProfileImageUrl(user.photos?.first),
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