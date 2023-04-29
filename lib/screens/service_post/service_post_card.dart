import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/screens/service_post/service_post_card_header.dart';
import 'package:talbna/screens/service_post/service_post_interaction_row.dart';
import 'package:talbna/screens/widgets/image_grid.dart';
import 'package:talbna/screens/widgets/service_post_action.dart';
import 'package:talbna/screens/widgets/user_avatar.dart';
import 'package:talbna/utils/constants.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ServicePostCard extends StatefulWidget {
  const ServicePostCard({
    Key? key,
    this.userProfileId,
    this.id,
    this.title,
    this.description,
    this.userPhoto,
    this.username,
    this.postDate,
    this.views,
    this.likes,
    this.photos,
    this.haveBadge,
    this.category,
    this.subcategory,
    this.userId,
    this.onPostDeleted,
    this.type, required this.isFavorited,
  }) : super(key: key);
  final Function? onPostDeleted;
  final int? id;
  final int? userProfileId;
  final String? title;
  final String? description;
  final String? userPhoto;
  final String? username;
  final DateTime? postDate;
  final String? views;
  final String? likes;
  final List<Photo>? photos;
  final String? haveBadge;
  final String? category;
  final String? subcategory;
  final String? type;
  final bool isFavorited; // Add this field
  final int? userId;

  @override
  State<ServicePostCard> createState() => _ServicePostCardState();
}

class _ServicePostCardState extends State<ServicePostCard> {
  late ServicePostBloc _servicePostBloc;
  late OtherUserProfileBloc _userProfileBloc;
  @override
  void initState() {
    super.initState();
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _userProfileBloc = BlocProvider.of<OtherUserProfileBloc>(context);
  }

  String formatTimeDifference(DateTime? postDate) {
    if (postDate == null) {
      return 'Unknown time';
    }
    Duration difference = DateTime.now().difference(postDate);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}sec ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).round()}M ago';
    } else {
      return '${(difference.inDays / 365).round()}Y ago';
    }
  }

  String getHaveBadgeText(String haveBadge) {
    switch (haveBadge) {
      case 'ماسي':
        return 'مميز ماسي';
      case 'ذهبي':
        return 'مميز ذهبي';
      case 'عادي':
        return 'عادي';
      default:
        return haveBadge;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.haveBadge == 'عادي'
              ? Container()
              : Positioned(
                  top: -18,
                  left: 2,
                  child: Wrap(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 1, 0, 10),
                      child: ServicePostHeaderContainer(
                        haveBadge: widget.haveBadge!,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text(
                            getHaveBadgeText(widget.haveBadge!),
                            style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
          VisibilityDetector(
            key: Key('servicePost_${widget.id}'),
            onVisibilityChanged: (visibilityInfo) {
              if (visibilityInfo.visibleFraction > 0.95) {
                _servicePostBloc.add(
                    ViewIncrementServicePostEvent(servicePostId: widget.id!));
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      UserAvatar(
                        userId: widget.userId,
                        imageUrl:
                            '${Constants.apiBaseUrl}/storage/${widget.userPhoto}',
                        radius: 16,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.username ??
                                  'Unknown', // Display full username
                              maxLines: 1, // Allow only one line of text
                              overflow: TextOverflow
                                  .ellipsis, // Display ellipsis if text overflows
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              formatTimeDifference(widget.postDate),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 70),
                      Expanded(
                        flex: 2,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            widget.title!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      ServicePostAction(
                        key: Key('servicePost_${widget.id}'),
                        servicePostUserId: widget.userId,
                        userProfileId: widget.userProfileId,
                        servicePostId: widget.id,
                        onPostDeleted: widget.onPostDeleted!,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 10),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            widget.description!,
                            textAlign: TextAlign.justify,
                            maxLines: 6,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ImageGrid(
                            imageUrls: widget.photos
                                    ?.map((photo) =>
                                        '${Constants.apiBaseUrl}/storage/${photo.src}')
                                    .toList() ??
                                []),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                       ServicePostInteractionRow(
                        key: Key('servicePost_${widget.id}'),
                        servicePostId: widget.id,
                        likes: widget.likes,
                        views: widget.views,
                        servicePostUserId: widget.userId,
                        servicePostBloc: _servicePostBloc,
                        userProfileBloc: _userProfileBloc,
                        isFav: widget.isFavorited,
                      ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -22,
            right: 0,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 1, 0, 10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 237, 237, 233),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        topLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      widget.type!,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 11, 11, 11), fontSize: 10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 1, 0, 10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 237, 237, 233),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        topLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      widget.subcategory!,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 11, 11, 11), fontSize: 10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 1, 0, 10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 237, 237, 233),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      widget.category!,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 11, 11, 11),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
