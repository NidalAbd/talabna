import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/utils/constants.dart';

class ServicePostInteractionRow extends StatefulWidget {
  const ServicePostInteractionRow({
    Key? key,
    required this.servicePostUserId,
    this.userProfileId,
    this.servicePostId,
    this.views,
    this.likes,
    required this.servicePostBloc,
    required this.isFav,
    required this.userProfileBloc,
  }) : super(key: key);
  final ServicePostBloc servicePostBloc;
  final OtherUserProfileBloc userProfileBloc;
  final int? servicePostUserId;
  final int? servicePostId;
  final int? userProfileId;
  final String? views;
  final String? likes;
  final bool isFav;
  @override
  State<ServicePostInteractionRow> createState() =>
      _ServicePostInteractionRowState();
}

class _ServicePostInteractionRowState extends State<ServicePostInteractionRow> {
  late int likesCount;
  @override
  void initState() {
    super.initState();
    likesCount = int.parse(widget.likes!);
    // widget.userProfileBloc.add(OtherUserProfileContactRequested(id: widget.servicePostUserId!)); // Add this line
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
                        color:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.lightBackgroundColor
                            : AppTheme.lightForegroundColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.views!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 22,
                            color: isFavorite ? Colors.red : Colors.grey,
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
                      color:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.lightBackgroundColor
                          : AppTheme.lightForegroundColor,
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
