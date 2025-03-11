import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/service_post/service_post_view.dart';
import 'package:talbna/screens/widgets/user_avatar.dart';
import 'package:talbna/utils/premium_badge.dart';

import '../../utils/photo_image_helper.dart';
import '../widgets/image_grid.dart';
import 'auto_direction_text.dart';

class ServicePostCard extends StatefulWidget {
  const ServicePostCard({
    super.key,
    this.onPostDeleted,
    required this.servicePost,
    required this.canViewProfile,
    required this.userProfileId,
    required this.user,
  });

  final ServicePost servicePost;
  final Function? onPostDeleted;
  final bool canViewProfile;
  final int userProfileId;
  final User user;

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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _navigateToPostDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (widget.servicePost.description != null &&
                widget.servicePost.description!.isNotEmpty)
              _buildDescription(),
            _buildMedia(),
            _buildInteractionRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isPremium = widget.servicePost.haveBadge != 'عادي';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
      child: Row(
        children: [
          UserAvatar(
            imageUrl: ProfileImageHelper.getProfileImageUrl(
              widget.servicePost.userPhoto,
            ),
            radius: 18,
            fromUser: widget.userProfileId,
            toUser: widget.servicePost.userId!,
            canViewProfile: widget.canViewProfile,
            user: widget.user,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.servicePost.userName ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPremium)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: PremiumBadge(
                                badgeType: widget.servicePost.haveBadge ?? 'عادي',
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        _formatTimeDifference(widget.servicePost.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // View Details Icon Button
              _buildViewDetailsButton(),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 24,
                onPressed: () => _showOptionsMenu(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetailsButton() {
    final primaryColor = Theme.of(context).primaryColor;

    return Material(
      color: primaryColor.withOpacity(0.1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _navigateToPostDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: AutoDirectionText(
        text: widget.servicePost.description ?? "",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildMedia() {
    if (widget.servicePost.photos == null || widget.servicePost.photos!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        ImageGrid(
          imageUrls: widget.servicePost.photos
              ?.map((photo) => '${photo.src}')
              .toList() ?? [],
        ),

        // Open Details Indicator
        Positioned(
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'View details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionRow() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black12
            : Colors.grey.shade50,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInteractionButton(
            icon: Icons.remove_red_eye_outlined,
            label: formatNumber(widget.servicePost.viewCount ?? 0),
          ),
          _buildDivider(),
          _buildInteractionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: formatNumber(widget.servicePost.commentsCount ?? 0),
          ),
          _buildDivider(),
          _buildInteractionButton(
            icon: Icons.flag_outlined,
            label: formatNumber(widget.servicePost.reportCount ?? 0),
          ),
          if (widget.servicePost.categoriesId != 7 &&
              widget.servicePost.distance != null) ...[
            _buildDivider(),
            _buildInteractionButton(
              icon: Icons.location_on_outlined,
              label: '${widget.servicePost.distance!.clamp(0, 999).toInt()}KM',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade300,
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPostDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServicePostCardView(
          key: Key('servicePost_${widget.servicePost.id}'),
          onPostDeleted: widget.onPostDeleted ?? (){},
          userProfileId: widget.userProfileId,
          servicePost: widget.servicePost,
          canViewProfile: widget.canViewProfile,
          user: widget.user,
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border_outlined),
              title: const Text('Save'),
              onTap: () {
                Navigator.pop(context);
                // Save functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                // Report functionality
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatTimeDifference(DateTime? date) {
    if (date == null) return 'Unknown time';
    Duration difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  String formatNumber(int number) {
    if (number >= 1000000000) {
      final double formattedNumber = number / 1000000000;
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
}