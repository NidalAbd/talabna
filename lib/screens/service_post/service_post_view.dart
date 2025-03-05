import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/user_contact/user_contact_bloc.dart';
import 'package:talbna/blocs/user_contact/user_contact_event.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/interaction_widget/location_button.dart';
import 'package:talbna/screens/profile/user_contact_buttons.dart';
import 'package:talbna/screens/service_post/service_post_card_header.dart';
import 'package:talbna/screens/service_post/service_post_interaction_row.dart';
import 'package:talbna/screens/widgets/image_grid.dart';
import 'package:talbna/screens/widgets/service_post_action.dart';
import 'package:talbna/screens/widgets/user_avatar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../provider/language.dart';
import '../../utils/debug_logger.dart';
import '../../utils/photo_image_helper.dart';

class ServicePostCardView extends StatefulWidget {
  const ServicePostCardView({
    super.key,
    required this.userProfileId,
    required this.onPostDeleted,  // Make this optional again to match existing code
    required this.servicePost,
    required this.canViewProfile,
    required this.user,
  });  // Use named parameter for the super constructor

  final Function onPostDeleted;
  final int userProfileId;
  final ServicePost servicePost;
  final bool canViewProfile;
  final User user;

  @override
  State<ServicePostCardView> createState() => _ServicePostCardViewState();
}

class _ServicePostCardViewState extends State<ServicePostCardView> {
  late ServicePostBloc _servicePostBloc;
  late OtherUserProfileBloc _userProfileBloc;
  late UserContactBloc _userContactBloc;
  late EdgeInsets padding;
  final Language _language = Language();
  final bool _viewIncremented = false;
  static final Set<int> _incrementedPostIds = {};

  @override
  void initState() {
    super.initState();
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _userProfileBloc = BlocProvider.of<OtherUserProfileBloc>(context);
    _userContactBloc = BlocProvider.of<UserContactBloc>(context)
      ..add(UserContactRequested(user: widget.servicePost.userId!));

    // Only increment view count once per post per app session
    if (!_incrementedPostIds.contains(widget.servicePost.id)) {
      _incrementedPostIds.add(widget.servicePost.id!);
      _servicePostBloc.add(
          ViewIncrementServicePostEvent(servicePostId: widget.servicePost.id!));
      DebugLogger.log('Incrementing view count for servicePost.id: ${widget.servicePost.id}',
          category: 'SERVICE_POST');
    } else {
      DebugLogger.log('View already incremented for post ${widget.servicePost.id}, skipping',
          category: 'SERVICE_POST');
    }

    if (widget.servicePost.haveBadge == 'عادي') {
      padding = const EdgeInsets.fromLTRB(0, 2, 0, 0);
    } else {
      padding = const EdgeInsets.fromLTRB(0, 30, 0, 0);
    }
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

  void _shareServicePost() {
    final postId = widget.servicePost.id.toString();
    final postTitle = widget.servicePost.title ?? 'منشور';
    final url = 'https://talbna.cloud/api/deep-link/service-post/$postId';

    DebugLogger.log('Sharing service post: ID=$postId, Title=$postTitle, URL=$url', category: 'SHARE');

    Share.share(
      'شاهد هذا المنشور: $postTitle\n$url',
      subject: postTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.servicePost.title ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareServicePost,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: padding,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              widget.servicePost.haveBadge == 'عادي'
                  ? Container()
                  : Positioned(
                top: -20,
                left: 0,
                child: Wrap(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 1, 0, 10),
                    child: ServicePostHeaderContainer(
                      haveBadge: widget.servicePost.haveBadge!,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                        child: Text(
                          getHaveBadgeText(widget.servicePost.haveBadge!),
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
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Row(
                            children: [
                              UserAvatar(
                                imageUrl:ProfileImageHelper.getProfileImageUrl(
                                  widget.servicePost.userPhoto,
                                ),
                                radius: 16,
                                fromUser: widget.userProfileId,
                                toUser: widget.servicePost.userId!,
                                canViewProfile: widget.canViewProfile,
                                user: widget.user,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 11,
                                    ),
                                    Text(
                                      widget.servicePost.userName ??
                                          'Unknown', // Display full username
                                      maxLines:
                                      1, // Allow only one line of text
                                      overflow: TextOverflow
                                          .ellipsis, // Display ellipsis if text overflows
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      formatTimeDifference(
                                          widget.servicePost.createdAt),
                                      style: const TextStyle(
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              ServicePostAction(
                                key:
                                Key('servicePost_${widget.servicePost.id}'),
                                servicePostUserId: widget.servicePost.userId,
                                userProfileId: widget.userProfileId,
                                servicePostId: widget.servicePost.id,
                                onPostDeleted: widget.onPostDeleted,
                                servicePost: widget.servicePost,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget.servicePost.description ?? '',
                                textAlign: TextAlign.justify,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Hero(
                              tag:
                              'photo_${widget.servicePost.id}', // Use a unique tag for each photo
                              child: ImageGrid(
                                imageUrls: widget.servicePost.photos
                                    ?.map((photo) => '${photo.src}')
                                    .toList() ??
                                    [],

                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ServicePostInteractionRow(
                          key: Key('servicePost_interaction_${widget.servicePost.id}'),
                          servicePostId: widget.servicePost.id,
                          likes: widget.servicePost.favoritesCount.toString(),
                          views: widget.servicePost.viewCount.toString(),
                          servicePostUserId: widget.servicePost.userId,
                          servicePostBloc: _servicePostBloc,
                          userProfileBloc: _userProfileBloc,
                          isFav: widget.servicePost.isFavorited!,
                          servicePost: widget.servicePost,
                          user: widget.user,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: UserContactButtons(
                      key: Key('UserContactButtons_${widget.servicePost.id}'),
                      userId: widget.servicePost.userId!,
                      servicePostBloc: _servicePostBloc,
                      userContactBloc: _userContactBloc,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (widget.servicePost.categoriesId != 7 &&
                      widget.servicePost.locationLatitudes != null &&
                      widget.servicePost.locationLongitudes != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: LocationButtonWidget(
                        locationLatitudes:
                        widget.servicePost.locationLatitudes!,
                        locationLongitudes:
                        widget.servicePost.locationLongitudes!,
                        width: 15,
                      ),
                    ),
                  if (widget.servicePost.categoriesId != 7 &&
                      widget.servicePost.locationLatitudes != null &&
                      widget.servicePost.locationLongitudes != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 2,
                        child: SizedBox(
                            height: 200,
                            child: GestureDetector(
                              onTap: () {
                                final url =
                                    'https://www.google.com/maps/search/?api=1&query=${widget.servicePost.locationLatitudes},${widget.servicePost.locationLongitudes}';
                                launchUrl(Uri.parse(url));
                              },
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                      widget.servicePost.locationLatitudes!,
                                      widget.servicePost.locationLongitudes!),
                                  zoom: 15,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('user-location'),
                                    position: LatLng(
                                        widget.servicePost.locationLatitudes!,
                                        widget.servicePost.locationLongitudes!),
                                    infoWindow: const InfoWindow(
                                        title: 'User Location'),
                                  ),
                                },
                              ),
                            )),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}