import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/user_contact/user_contact_bloc.dart';
import 'package:talbna/blocs/user_contact/user_contact_event.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/screens/interaction_widget/location_button.dart';
import 'package:talbna/screens/profile/user_contact_buttons.dart';
import 'package:talbna/screens/service_post/service_post_card_header.dart';
import 'package:talbna/screens/service_post/service_post_interaction_row.dart';
import 'package:talbna/screens/widgets/image_grid.dart';
import 'package:talbna/screens/widgets/service_post_action.dart';
import 'package:talbna/screens/widgets/user_avatar.dart';
import 'package:talbna/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ServicePostCardView extends StatefulWidget {
  const ServicePostCardView({
    Key? key,
    required this.userProfileId,
    this.onPostDeleted, required this.servicePost, required this.canViewProfile,

  }) : super(key: key);
  final Function? onPostDeleted;
  final int userProfileId;
  final ServicePost servicePost;
  final bool canViewProfile;

  @override
  State<ServicePostCardView> createState() => _ServicePostCardViewState();
}

class _ServicePostCardViewState extends State<ServicePostCardView> {
  late ServicePostBloc _servicePostBloc;
  late OtherUserProfileBloc _userProfileBloc;
  late UserContactBloc _userContactBloc;
  late EdgeInsets padding;

  @override
  void initState() {
    super.initState();
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _userProfileBloc = BlocProvider.of<OtherUserProfileBloc>(context);
    _userContactBloc = BlocProvider.of<UserContactBloc>(context)..add(UserContactRequested(user: widget.servicePost.userId!));
    _servicePostBloc.add( ViewIncrementServicePostEvent(servicePostId: widget.servicePost.id!));
    if( widget.servicePost.haveBadge == 'عادي'){
      padding = const EdgeInsets.fromLTRB(0, 2, 0, 0);
    }else{
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
title: const Text('عرض التفاصيل'),
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
                      top: -18,
                      left: 2,
                      child: Wrap(children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2, 1, 0, 10),
                          child: ServicePostHeaderContainer(
                            haveBadge: widget.servicePost.haveBadge!,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
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
                  Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.lightForegroundColor
                        : AppTheme.darkForegroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Row(
                            children: [
                              UserAvatar(
                                  imageUrl:
                                  '${Constants.apiBaseUrl}/storage/${widget.servicePost.userPhoto}',
                                  radius: 16,
                                  fromUser: widget.userProfileId,
                                  toUser: widget.servicePost.userId!,
                                  canViewProfile: widget.canViewProfile),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 11,),
                                    Text(
                                      widget.servicePost.userName ??
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
                                      formatTimeDifference(
                                          widget.servicePost.createdAt),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Row(
                                    children: [
                                      Text(
                                        '${widget.servicePost.type!} ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,

                                      ),
                                      Text(
                                        '${widget.servicePost.title!} ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                              ServicePostAction(
                                key: Key('servicePost_${widget.servicePost.id}'),
                                servicePostUserId: widget.servicePost.userId,
                                userProfileId: widget.userProfileId,
                                servicePostId: widget.servicePost.id,
                                onPostDeleted: widget.onPostDeleted!,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                widget.servicePost.description!,
                                textAlign: TextAlign.justify,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(fontSize: 16),
                              ),
                              ImageGrid(
                                  imageUrls: widget.servicePost.photos
                                          ?.map((photo) =>
                                              '${photo.src}')
                                          .toList() ??
                                      [], canClick: true, userId: widget.userProfileId,servicePost: widget.servicePost,),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                             ServicePostInteractionRow(
                              key: Key('servicePost_${widget.servicePost.id}'),
                              servicePostId: widget.servicePost.id,
                              likes: widget.servicePost.favoritesCount.toString(),
                              views: widget.servicePost.viewCount.toString(),
                              servicePostUserId: widget.servicePost.userId,
                              servicePostBloc: _servicePostBloc,
                              userProfileBloc: _userProfileBloc,
                              isFav: widget.servicePost.isFavorited!,
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: UserContactButtons(
                      key: Key('UserContactButtons_${widget.servicePost.id}'),
                      userId: widget.servicePost.userId!,
                      servicePostBloc: _servicePostBloc,
                      userContactBloc: _userContactBloc,
                    ),
                  ),
                  const SizedBox(height: 10,),
                  if(widget.servicePost.categoriesId != 7)
                    Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: LocationButtonWidget(
                      locationLatitudes: widget.servicePost.locationLatitudes!,
                      locationLongitudes: widget.servicePost.locationLongitudes!,
                      width: 15,),
                  ),
                  if(widget.servicePost.categoriesId != 7)Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 2,
                      child: SizedBox(
                        height: 200,
                        child: GestureDetector(
                          onTap: () {
                            final url = 'https://www.google.com/maps/search/?api=1&query=${widget.servicePost.locationLatitudes},${widget.servicePost.locationLongitudes}';
                            launchUrl(Uri.parse(url));
                          },
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(widget.servicePost.locationLatitudes!, widget.servicePost.locationLongitudes!),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('user-location'),
                                position: LatLng(widget.servicePost.locationLatitudes!, widget.servicePost.locationLongitudes!),
                                infoWindow: const InfoWindow(title: 'User Location'),
                              ),
                            },
                          ),
                        )
                      ),
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
