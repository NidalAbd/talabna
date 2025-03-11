import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_event.dart';
import 'package:talbna/blocs/user_action/user_action_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/utils/constants.dart';

import '../../utils/photo_image_helper.dart';

class UserCard extends StatefulWidget {
  final User follower;
  final int userId;
  final User user;
  final UserActionBloc userActionBloc;

  const UserCard({
    super.key,
    required this.follower,
    required this.userActionBloc,
    required this.userId,
    required this.user,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> with SingleTickerProviderStateMixin {
  late bool? isFollowThisUser = widget.follower.isFollow;
  final Language _language = Language();
  final String _uniqueTagSuffix = DateTime.now().microsecondsSinceEpoch.toString();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Photo URL handling method similar to ProfileScreen
  String _getPhotoUrl() {
    if (widget.follower.photos != null &&
        widget.follower.photos!.isNotEmpty &&
        widget.follower.photos!.first.src != null) {
      return '${Constants.apiBaseUrl}/${widget.follower.photos!.first.src}';
    }
    return '';
  }

  void _toggleFollow() {
    if (_isToggling) return;

    setState(() {
      _isToggling = true;
    });

    // Trigger scale animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Trigger follow/unfollow action
    widget.userActionBloc.add(
      ToggleUserMakeFollowFromListEvent(user: widget.follower.id),
    );

    // Show feedback snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFollowThisUser!
              ? 'You are now following ${widget.follower.userName}'
              : 'You have unfollowed ${widget.follower.userName}',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _getPhotoUrl();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BlocConsumer<UserActionBloc, UserActionState>(
      bloc: widget.userActionBloc,
      listener: (context, state) {
        if (state is UserFollowUnFollowFromListToggled &&
            state.userId == widget.follower.id) {
          setState(() {
            isFollowThisUser = state.isFollower;
            _isToggling = false;
          });
        }
      },
      builder: (context, state) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Profile Avatar
                      Hero(
                        tag: 'userCardAvatar${widget.follower.id}_$_uniqueTagSuffix',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: photoUrl.isNotEmpty
                                ? NetworkImage(ProfileImageHelper.getProfileImageUrl(widget.follower.photos!.first),)
                                : null,
                            child: photoUrl.isEmpty
                                ? Icon(Icons.person, size: 32, color: Colors.grey[700])
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.follower.userName ?? 'Unknown User',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${widget.follower.userName?.replaceAll(' ', '_') ?? 'user'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Follow/Unfollow Button
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: ElevatedButton(
                          key: ValueKey(isFollowThisUser),
                          onPressed: _toggleFollow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowThisUser!
                                ? Colors.red.shade400
                                : theme.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            isFollowThisUser!
                                ? _language.getUnfollowText()
                                : _language.getFollowText(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}