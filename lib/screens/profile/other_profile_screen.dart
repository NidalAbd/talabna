import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'dart:convert';

import '../../app_theme.dart';
import '../../blocs/other_users/user_profile_bloc.dart';
import '../../blocs/other_users/user_profile_event.dart';
import '../../blocs/other_users/user_profile_state.dart';
import '../../blocs/user_action/user_action_bloc.dart';
import '../../blocs/user_action/user_action_event.dart';
import '../../blocs/user_action/user_action_state.dart';
import '../../data/models/user.dart';
import '../../provider/language.dart';
import '../../utils/constants.dart';
import '../interaction_widget/report_tile.dart';
import '../profile/add_point_screen.dart';
import '../profile/user_followers_screen.dart';
import '../profile/user_following_screen.dart';
import '../profile/user_info_widget.dart';
import '../service_post/other_user_post_screen.dart';
import '../widgets/error_widget.dart';

class OtherProfileScreen extends StatefulWidget {
  const OtherProfileScreen({
    Key? key,
    required this.fromUser,
    required this.toUser,
    required this.user,
    required this.isOtherProfile,
  }) : super(key: key);

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
  late UserActionBloc _userActionBloc;
  final ScrollController _scrollController = ScrollController();
  bool _isTitleVisible = false;
  bool isFollowing = false;
  bool isHimSelf = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize user profile bloc
    _userProfileBloc = context.read<OtherUserProfileBloc>()
      ..add(OtherUserProfileRequested(id: widget.toUser));

    // Initialize user action bloc
    _userActionBloc = context.read<UserActionBloc>();
    _userActionBloc.add(GetUserFollow(user: widget.toUser));

    // Check if the profile belongs to the current user
    isHimSelf = widget.fromUser == widget.toUser;

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

  // Safe method to show a snackbar that checks context and mounted state
  void _showSnackBar(String message) {
    if (mounted && context.mounted) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.clearSnackBars(); // Clear any existing snackbars first

      Future.microtask(() {
        if (mounted && context.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  void _setClipboardData(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      _showSnackBar('Copied to clipboard');
    }
  }

  String _getProfileImageUrl(User user) {
    if (user.photos != null && user.photos!.isNotEmpty) {
      return '${Constants.apiBaseUrl}/storage/${user.photos!.first.src}';
    }
    return 'https://via.placeholder.com/150';
  }

  String _getLocationText(User user) {
    // Use the app's current locale or default to English
    final String currentLang = Localizations.localeOf(context).languageCode;
    final List<String> locationParts = [];

    if (user.city != null) {
      try {
        locationParts.add(user.city!.getName(currentLang));
      } catch (e) {
        // Fallback if getName method fails
        locationParts.add(user.city.toString());
      }
    }

    if (user.country != null) {
      try {
        locationParts.add(user.country!.getName(currentLang));
      } catch (e) {
        // Fallback if getName method fails
        locationParts.add(user.country.toString());
      }
    }

    return locationParts.join(', ');
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
    return BlocListener<UserActionBloc, UserActionState>(
      listener: (context, state) {
        if (state is UserFollowUnFollowToggled && mounted) {
          setState(() {
            isFollowing = state.isFollower;
          });

          final message = state.isFollower
              ? 'You are now following the user'
              : 'You have unfollowed the user';

          _showSnackBar(message);
        } else if (state is GetFollowUserSuccess) {
          setState(() {
            isFollowing = state.followSuccess;
          });
        }
      },
      child: BlocBuilder<OtherUserProfileBloc, OtherUserProfileState>(
        builder: (context, state) {
          if (state is OtherUserProfileLoadInProgress) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is OtherUserProfileLoadSuccess) {
            final user = state.user;
            return Scaffold(
              body: NestedScrollView(
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
                        labelColor: Colors.white, // Color for selected tab
                        unselectedLabelColor: Colors.white70, // Color for unselected tabs with better visibility
                        indicatorColor: Colors.white, // Indicator line color
                        indicatorWeight: 3, // Make indicator more prominent
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold, // Bold text for selected tab
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.normal, // Normal weight for unselected tabs
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
                    OtherUserPostScreen(userID: user.id, user: widget.user),
                    UserFollowerScreen(userID: user.id, user: user),
                    UserFollowingScreen(userID: user.id, user: user),
                    UserInfoWidget(userId: user.id, user: user),
                  ],
                ),
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
            child: CachedNetworkImage(
              imageUrl: _getProfileImageUrl(user),
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
              placeholder: (context, url) => Container(
                color: Colors.grey[800],
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[900],
                child: const Icon(Icons.error, color: Colors.white),
              ),
            ),
          )
        else
          Container(
            color: Colors.grey[800],
          ),

        // Profile content
        SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile Picture
                Hero(
                  tag: 'profile_image_${user.id}',
                  child: CircleAvatar(
                    radius: 45, // Further reduced from 50
                    backgroundImage: CachedNetworkImageProvider(
                      _getProfileImageUrl(user),
                    ),
                    onBackgroundImageError: (exception, stackTrace) =>
                    const AssetImage('assets/images/placeholder.png'),
                  ),
                ),
                const SizedBox(height: 8), // Reduced from 12

                // Username
                Text(
                  user.userName ?? 'User Name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20, // Reduced from 22
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Location info (city and country)
                if (user.city != null || user.country != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              _getLocationText(user),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Follow button for other profiles
                if (!isHimSelf)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _buildProfileFollowButton(),
                  ),

                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4), // Reduced from 8
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatColumn('Posts', user.servicePostsCount ?? 0),
                      const SizedBox(width: 20), // Reduced from 24
                      _buildStatColumn('Followers', user.followersCount ?? 0),
                      const SizedBox(width: 20), // Reduced from 24
                      _buildStatColumn('Following', user.followingCount ?? 0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column _buildStatColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18, // Reduced from 20
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12, // Reduced from 14
          ),
        ),
      ],
    );
  }

  Widget _buildProfileFollowButton() {
    return ElevatedButton(
      onPressed: isHimSelf
          ? null
          : () {
        context.read<UserActionBloc>().add(
          ToggleUserMakeFollowEvent(user: widget.toUser),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.grey[700] : Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minimumSize: const Size(80, 24),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        isFollowing ? 'Unfollow' : 'Follow',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, User user) {
    if (mounted && context.mounted) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Wrap(
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
                  if (mounted && context.mounted) {
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
                      },
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: Text(_language.tConvertPointsText()),
                onTap: () {
                  Navigator.pop(context);
                  if (mounted && context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddPointScreen(
                          fromUserID: widget.fromUser,
                          toUserId: widget.toUser,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }
}