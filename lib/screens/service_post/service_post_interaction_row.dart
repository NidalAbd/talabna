import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/comments/comment_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/widgets/comment_sheet.dart';
import 'package:talbna/utils/constants.dart';

class ServicePostInteractionRow extends StatefulWidget {
  const ServicePostInteractionRow({
    super.key,
    required this.servicePostUserId,
    this.userProfileId,
    this.servicePostId,
    this.views,
    this.likes,
    required this.servicePostBloc,
    required this.isFav,
    required this.userProfileBloc, required this.servicePost, required this.user,
  });
  final ServicePostBloc servicePostBloc;
  final OtherUserProfileBloc userProfileBloc;
  final int? servicePostUserId;
  final int? servicePostId;
  final int? userProfileId;
  final String? views;
  final String? likes;
  final bool isFav;
  final ServicePost  servicePost;
  final User user;
  @override
  State<ServicePostInteractionRow> createState() =>
      _ServicePostInteractionRowState();
}

class _ServicePostInteractionRowState extends State<ServicePostInteractionRow> {
  late int likesCount;
  late UserProfileBloc _userProfileBloc;
  late ServicePostBloc _servicePostBloc;
  late CommentBloc _commentBloc;
  @override
  void initState() {
    super.initState();
    _userProfileBloc = context.read<UserProfileBloc>();
    _commentBloc = context.read<CommentBloc>();
    likesCount = int.parse(widget.likes!);
    // widget.userProfileBloc.add(OtherUserProfileContactRequested(id: widget.servicePostUserId!)); // Add this line
  }
  String formatNumber(int number) {
    if (number >= 1000000000) {
      final double formattedNumber = number / 1000000;
      const String suffix = 'B';
      return '${formattedNumber.toStringAsFixed(1)}$suffix';
    } else if (number >= 1000000) {
      final double formattedNumber = number / 1000000;
      const String suffix = 'M';
      return '${formattedNumber.toStringAsFixed(1)}$suffix';
    } else if (number >= 1000) {
      final double formattedNumber = number / 1000;
      const String suffix = 'K';
      return '${formattedNumber.toStringAsFixed(1)}$suffix';
    } else {
      return number.toString();
    }
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServicePostBloc, ServicePostState>(
      bloc: widget.servicePostBloc,
      listener: (context, state) {},
      builder: (context, state) {
        bool isFavorite = widget.isFav;
        if (state is ServicePostFavoriteToggled &&
            state.servicePostId == widget.servicePostId) {
          isFavorite = state.isFavorite;
          isFavorite ? likesCount++ : likesCount--;
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye,

                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.views!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CommentModalBottomSheet(
                        iconSize: 25,
                        userProfileBloc: _userProfileBloc,
                        commentBloc: _commentBloc,
                        servicePost: widget.servicePost, user: widget.user,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formatNumber(widget.servicePost.commentsCount ?? 0),
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fmd_bad,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formatNumber(widget.servicePost.reportCount ?? 0),
                        style: TextStyle(
                          fontSize: 16,

                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 22,
                            color: isFavorite ? Colors.red : Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkIconColor
                              : AppTheme.lightIconColor,
                          ),
                          onPressed: () {
                            // printWidgetHierarchy(context);
                            widget.servicePostBloc.add(
                                ToggleFavoriteServicePostEvent(
                                    servicePostId: widget.servicePostId!));
                          }),
                      const SizedBox(width: 5),
                      Text(
                        '$likesCount', // Display the updated likes count
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share,

                    ),
                    onPressed: () async {
                      await Share.share(
                          '${Constants.apiBaseUrl}/api/service_posts/${widget.servicePostId!}');
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
