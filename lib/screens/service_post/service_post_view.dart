import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/blocs/user_contact/user_contact_bloc.dart';
import 'package:talbna/blocs/user_contact/user_contact_event.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/interaction_widget/location_button.dart';
import 'package:talbna/screens/profile/user_contact_buttons.dart';
import 'package:talbna/screens/widgets/image_grid.dart';
import 'package:talbna/screens/widgets/service_post_action.dart';
import 'package:talbna/screens/widgets/user_avatar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../blocs/comments/comment_bloc.dart';
import '../../blocs/user_profile/user_profile_bloc.dart';
import '../../blocs/user_profile/user_profile_event.dart';
import '../../provider/language.dart';
import '../../utils/debug_logger.dart';
import '../../utils/photo_image_helper.dart';
import '../../utils/premium_badge.dart';
import '../../utils/share_utils.dart';
import '../reel/like_button.dart';
import '../widgets/comment_sheet.dart';
import 'auto_direction_text.dart';

class ServicePostCardView extends StatefulWidget {
  const ServicePostCardView({
    super.key,
    required this.userProfileId,
    required this.onPostDeleted,
    required this.servicePost,
    required this.canViewProfile,
    required this.user,
    this.showTextOnRight = false,
    this.interactionIconSize = 24.0,
  });

  final Function onPostDeleted;
  final int userProfileId;
  final ServicePost servicePost;
  final bool canViewProfile;
  final User user;
  final bool showTextOnRight;
  final double interactionIconSize;

  @override
  State<ServicePostCardView> createState() => _ServicePostCardViewState();
}

class _ServicePostCardViewState extends State<ServicePostCardView> {
  late ServicePostBloc _servicePostBloc;
  late OtherUserProfileBloc _userProfileBloc;
  late UserContactBloc _userContactBloc;
  late UserProfileBloc _userCurrentProfileBloc;
  late CommentBloc _commentBloc;
  final Language language = Language();
  static final Set<int> _incrementedPostIds = {};

  @override
  void initState() {
    super.initState();
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _userProfileBloc = BlocProvider.of<OtherUserProfileBloc>(context);
    _userCurrentProfileBloc = context.read<UserProfileBloc>()
      ..add(UserProfileRequested(id: widget.user.id));
    _userContactBloc = BlocProvider.of<UserContactBloc>(context)
      ..add(UserContactRequested(user: widget.servicePost.userId!));
    _commentBloc = BlocProvider.of<CommentBloc>(context);

    // Only increment view count once per post per app session
    if (!_incrementedPostIds.contains(widget.servicePost.id)) {
      _incrementedPostIds.add(widget.servicePost.id!);
      _servicePostBloc.add(
          ViewIncrementServicePostEvent(servicePostId: widget.servicePost.id!));
      DebugLogger.log(
          'Incrementing view count for servicePost.id: ${widget.servicePost.id}',
          category: 'SERVICE_POST');
    } else {
      DebugLogger.log(
          'View already incremented for post ${widget.servicePost.id}, skipping',
          category: 'SERVICE_POST');
    }
  }

  String formatTimeDifference(DateTime? postDate) {
    if (postDate == null) {
      return language.getUnknownTimeText();
    }
    Duration difference = DateTime.now().difference(postDate);
    if (difference.inSeconds < 60) {
      return language.getTimeAgoText(difference.inSeconds, 'second');
    } else if (difference.inMinutes < 60) {
      return language.getTimeAgoText(difference.inMinutes, 'minute');
    } else if (difference.inHours < 24) {
      return language.getTimeAgoText(difference.inHours, 'hour');
    } else if (difference.inDays < 30) {
      return language.getTimeAgoText(difference.inDays, 'day');
    } else if (difference.inDays < 365) {
      return language.getTimeAgoText((difference.inDays / 30).round(), 'month');
    } else {
      return language.getTimeAgoText((difference.inDays / 365).round(), 'year');
    }
  }

  Future<void> _shareServicePost() async {
    final postId = widget.servicePost.id.toString();
    final postTitle = widget.servicePost.title ?? 'منشور';
    final url = 'https://talbna.cloud/api/deep-link/service-post/$postId';

    DebugLogger.log('Sharing service post: ID=$postId, Title=$postTitle, URL=$url', category: 'SHARE');

    await ShareUtils.shareServicePost(widget.servicePost.id!, title: widget.servicePost.title, type: 'service-post');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostHeader(),
                _buildPostContent(),
                _buildDivider(),
                _buildInteractionRow(),
                _buildDivider(),
                _buildContactSection(),

                if (widget.servicePost.categoriesId != 7 &&
                    widget.servicePost.locationLatitudes != null &&
                    widget.servicePost.locationLongitudes != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                  infoWindow: InfoWindow(
                                      title: language.getUserLocationText()),
                                ),
                              },
                            ),
                          )),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
      thickness: 0.5,
      height: 32,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: AutoDirectionText(
              text: widget.servicePost.title ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.servicePost.haveBadge != 'عادي')
            PremiumBadge(
              badgeType: widget.servicePost.haveBadge ?? 'عادي',
              size: 22,
            ),
        ],
      ),
      actions: [
        ServicePostAction(
          key: Key('servicePost_${widget.servicePost.id}'),
          servicePostUserId: widget.servicePost.userId,
          userProfileId: widget.userProfileId,
          servicePostId: widget.servicePost.id,
          onPostDeleted: widget.onPostDeleted,
          servicePost: widget.servicePost,
          user: widget.user,
        ),
      ],
    );
  }

  Widget _buildPostHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserAvatar(
            imageUrl: ProfileImageHelper.getProfileImageUrl(
              widget.servicePost.userPhoto,
            ),
            radius: 20,
            fromUser: widget.userProfileId,
            toUser: widget.servicePost.userId!,
            canViewProfile: widget.canViewProfile,
            user: widget.user,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoDirectionText(
                  text: widget.servicePost.userName ?? language.getUnknownUserText(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatTimeDifference(widget.servicePost.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.servicePost.description != null &&
            widget.servicePost.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: AutoDirectionText(
              text: widget.servicePost.description ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        if (widget.servicePost.photos != null &&
            widget.servicePost.photos!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Hero(
              tag: 'photo_${widget.servicePost.id}',
              child: ImageGrid(
                imageUrls: widget.servicePost.photos!
                    .map((photo) => '${photo.src}')
                    .toList(),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              _buildStatItem(
                icon: Icons.favorite,
                count: widget.servicePost.favoritesCount.toString(),
                label: language.getLikesLabel(),
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                icon: Icons.comment,
                count: widget.servicePost.commentsCount.toString(),
                label: language.getCommentsLabel(),
              ),
              Expanded(child: Container()),
              _buildStatItem(
                icon: Icons.remove_red_eye_outlined,
                count: widget.servicePost.viewCount.toString(),
                label: language.getViewsLabel(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionRow() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildShareButton(),
              ),
              _buildVerticalDivider(isDarkMode),
              Expanded(
                child: _buildReportButton(),
              ),
              _buildVerticalDivider(isDarkMode),
              Expanded(
                child: _buildLikeButton(widget.servicePost),
              ),
              _buildVerticalDivider(isDarkMode),
              Expanded(
                child: _buildCommentButton(widget.servicePost),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDarkMode) {
    return Container(
      height: 24,
      width: 1,
      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String count,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
            icon,
            size: 14,
            color: Colors.grey.shade600
        ),
        const SizedBox(width: 4),
        Text(
          count + label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLikeButton(ServicePost post) {
    return Column(
      children: [
        LikeButton(
          showCountOnRight: widget.showTextOnRight,
          iconSize: widget.interactionIconSize,
          isFavorite: post.isFavorited ?? false,
          favoritesCount: post.favoritesCount ?? 0,
          onToggleFavorite: () async {
            final completer = Completer<bool>();

            // Create a stream subscription to listen for the result
            StreamSubscription? subscription;
            subscription = _servicePostBloc.stream.listen((state) {
              if (state is ServicePostFavoriteToggled &&
                  state.servicePostId == post.id) {
                completer.complete(state.isFavorite);
                subscription?.cancel();
              } else if (state is ServicePostOperationFailure &&
                  state.event == 'ToggleFavoriteServicePostEvent') {
                completer.complete(false);
                subscription?.cancel();
              }
            });

            // Dispatch the toggle event
            _servicePostBloc.add(ToggleFavoriteServicePostEvent(servicePostId: post.id!));

            return completer.future;
          },
        ),
      ],
    );
  }

  Widget _buildCommentButton(ServicePost post) {
    return Column(
      children: [
        CommentModalBottomSheet(
          showCountOnRight: widget.showTextOnRight,
          iconSize: widget.interactionIconSize,
          userProfileBloc: _userCurrentProfileBloc,
          commentBloc: _commentBloc,
          servicePost: post,
          user: widget.user,
        ),
      ],
    );
  }

  Widget _buildShareButton() {
    final iconSize = widget.interactionIconSize;

    return InkWell(
      onTap: _shareServicePost,
      child: widget.showTextOnRight
          ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share_outlined, size: iconSize),
            const SizedBox(width: 6),
            Text(
              language.getShareText(),
              style: TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Icon(Icons.share_outlined, size: iconSize),
          const SizedBox(height: 4),
          Text(
            language.getShareText(),
            style: TextStyle(
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton() {
    final iconSize = widget.interactionIconSize;

    return InkWell(
      onTap: () {
        // Report functionality
      },
      child: widget.showTextOnRight
          ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_outlined, size: iconSize),
            const SizedBox(width: 6),
            Text(
              language.getReportText(),
              style: TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Icon(Icons.flag_outlined, size: iconSize),
          const SizedBox(height: 4),
          Text(
            language.getReportText(),
            style: TextStyle(
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.contactDetails(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          UserContactButtons(
            key: Key('UserContactButtons_${widget.servicePost.id}'),
            userId: widget.servicePost.userId!,
            servicePostBloc: _servicePostBloc,
            userContactBloc: _userContactBloc,
          ),
        ],
      ),
    );
  }
}