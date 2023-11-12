import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_event.dart';
import 'package:talbna/blocs/user_action/user_action_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/widgets/user_avatar.dart';
import 'package:talbna/utils/constants.dart';

import '../../provider/language.dart';

class UserCard extends StatefulWidget {
  final User follower;
  final int userId;
  final User user;
  final UserActionBloc userActionBloc;
  const UserCard({
    Key? key,
    required this.follower,
    required this.userActionBloc,
    required this.userId, required this.user,
  }) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late bool? isFollowThisUser = widget.follower.isFollow;
  final Language _language = Language();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String avatarUrl =
        'storage/photos/avatar1.png'; // Provide a default avatar URL
    if (widget.follower.photos!.isNotEmpty) {
      avatarUrl =
          '${widget.follower.photos![0].src}';
    } else {
      avatarUrl =
          'storage/photos/avatar1.png'; // Provide a default avatar URL
    }
    return Card(
      child: ListTile(
        leading: UserAvatar(
          imageUrl: avatarUrl,
          radius: 24,
          toUser: widget.follower.id,
          canViewProfile: true,
          fromUser: widget.userId, user: widget.user,
        ),
        title: Text(
          widget.follower.userName!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: SizedBox(
          width: 100, // Set the desired width
          child: BlocConsumer<UserActionBloc, UserActionState>(
            bloc: widget.userActionBloc,
            listener: (context, state) {
              // Listener code...
            },
            builder: (context, state) {
              if (state is UserFollowUnFollowFromListToggled &&
                  state.userId == widget.follower.id) {
                isFollowThisUser = state.isFollower;
              }
              return TextButton(
                onPressed: () {
                  widget.userActionBloc.add(
                    ToggleUserMakeFollowFromListEvent(user: widget.follower.id),
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final message = isFollowThisUser!
                        ? 'You are now following ${widget.follower.userName}'
                        : 'You have unfollowed ${widget.follower.userName}';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    isFollowThisUser!
                        ? Colors
                            .red // Change to the desired color for unfollow button
                        : Colors
                            .blue, // Change to the desired color for follow button
                  ),
                ),
                child: Text(
                  isFollowThisUser! ? _language.getUnfollowText() : _language.getFollowText(),
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
