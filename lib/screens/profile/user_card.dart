import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_event.dart';
import 'package:talbna/blocs/user_action/user_action_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/widgets/user_avatar.dart';
import 'package:talbna/utils/constants.dart';

class UserCard extends StatefulWidget {
  final User follower;
  final int userId;
  final UserActionBloc userActionBloc;
   const UserCard({
    Key? key,
    required this.follower,
    required this.userActionBloc,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late bool? isFollowThisUser = widget.follower.isFollow;
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    String avatarUrl =
        '${Constants.apiBaseUrl}/storage/photos/avatar1.png'; // Provide a default avatar URL
    if (widget.follower.photos!.isNotEmpty) {
      avatarUrl = '${Constants.apiBaseUrl}/storage/${widget.follower.photos![0].src}';
    }else{
      avatarUrl =
      '${Constants.apiBaseUrl}/storage/photos/avatar1.png'; // Provide a default avatar URL
    }
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.lightForegroundColor
          : AppTheme.darkForegroundColor,
      child: ListTile(
        leading: UserAvatar(
          imageUrl: avatarUrl,
          radius: 24,
          toUser: widget.follower.id,
          canViewProfile: true,
          fromUser: widget.userId,
        ),
        title: Text(
          widget.follower.userName!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${widget.follower.country!.name} من ${widget.follower.city!.name}',
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        trailing: BlocConsumer<UserActionBloc, UserActionState>(
          bloc: widget.userActionBloc,
          listener: (context, state) {
            // Listener code...
          },
          builder: (context, state) {
            if (state is UserFollowUnFollowFromListToggled &&
                state.userId == widget.follower.id) {
              isFollowThisUser = state.isFollower; // Update the isFollowing variable
              final message = state.isFollower
                  ? 'You are now following ${widget.follower.userName}'
                  : 'You have unfollowed ${widget.follower.userName}';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
            return TextButton(
              onPressed: () {
                widget.userActionBloc.add(
                  ToggleUserMakeFollowFromListEvent(user: widget.follower.id),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  isFollowThisUser!
                      ? Colors.red // Change to the desired color for unfollow button
                      : Colors.blue, // Change to the desired color for follow button
                ),
              ),
              child: Text(
                isFollowThisUser! ? 'Unfollow' : 'Follow',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
