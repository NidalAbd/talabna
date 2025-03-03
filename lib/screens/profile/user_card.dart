import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_event.dart';
import 'package:talbna/blocs/user_action/user_action_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/utils/constants.dart';

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

class _UserCardState extends State<UserCard> {
  late bool? isFollowThisUser = widget.follower.isFollow;
  final Language _language = Language();

  // Photo URL handling method similar to ProfileScreen
  String _getPhotoUrl() {
    if (widget.follower.photos != null &&
        widget.follower.photos!.isNotEmpty &&
        widget.follower.photos!.first.src != null) {
      return '${Constants.apiBaseUrl}/storage/${widget.follower.photos!.first.src}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _getPhotoUrl();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode
        ? Theme.of(context).primaryColor
        : Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Profile Avatar
            Hero(
              tag: 'userCardAvatar${widget.follower.id}',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[800]! : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl.isEmpty
                      ? Icon(Icons.person, size: 30, color: Colors.grey[700])
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${widget.follower.userName?.replaceAll(' ', '_') ?? 'user'}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Follow/Unfollow Button
            BlocConsumer<UserActionBloc, UserActionState>(
              bloc: widget.userActionBloc,
              listener: (context, state) {
                if (state is UserFollowUnFollowFromListToggled &&
                    state.userId == widget.follower.id) {
                  setState(() {
                    isFollowThisUser = state.isFollower;
                  });
                }
              },
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowThisUser!
                        ? Colors.red.shade400
                        : primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}