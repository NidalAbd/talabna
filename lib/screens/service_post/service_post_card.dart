import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/service_post/service_post_view.dart';
import 'package:talbna/screens/widgets/user_avatar.dart';
import 'package:talbna/utils/constants.dart';

import '../widgets/image_grid.dart';

class ServicePostCard extends StatefulWidget {
  const ServicePostCard({
    Key? key,
    this.onPostDeleted,
    required this.servicePost,
    required this.canViewProfile,
    required this.userProfileId,
    required this.user,
  }) : super(key: key);

  final ServicePost servicePost;
  final Function? onPostDeleted;
  final bool canViewProfile;
  final int userProfileId;
  final User user;

  @override
  _ServicePostCardState createState() => _ServicePostCardState();
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
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
      child: InkWell(
        onTap: () => _navigateToPostDetails(context),
        child: Column(
          children: [
            _buildHeader(),
            _buildBody(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ListTile(
      leading: UserAvatar(
        imageUrl:
            '${Constants.apiBaseUrl}/storage/${widget.servicePost.userPhoto}',
        radius: 20,
        fromUser: widget.userProfileId,
        toUser: widget.servicePost.userId!,
        canViewProfile: widget.canViewProfile,
        user: widget.user,
      ),
      title: Text(
        widget.servicePost.userName ?? 'Unknown',
        style: const TextStyle(fontSize: 16),
      ),
      subtitle: Text(
        _formatTimeDifference(widget.servicePost.createdAt),
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing: const Icon(
        Icons.more_vert,
        size: 25,
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.servicePost.description ?? "No description provided.", maxLines: 2,
          overflow: TextOverflow.ellipsis,),
          const SizedBox(
              height: 10), // Adds space between the text and the images
          widget.servicePost.photos != null &&
                  widget.servicePost.photos!.isNotEmpty
              ? ImageGrid(
                  imageUrls: widget.servicePost.photos
                          ?.map((photo) => '${photo.src}')
                          .toList() ??
                      [],
                )
              : Container(), // Optionally display an empty container if there are no photos
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return ListTile(
      leading: SizedBox(
        width: 200,
        child: Row(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.remove_red_eye,
                ),
                const SizedBox(width: 5),
                Text(
                  formatNumber(widget.servicePost.viewCount ?? 0),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.comment,
                ),
                const SizedBox(width: 5),
                Text(
                  formatNumber(widget.servicePost.commentsCount ?? 0),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fmd_bad,
                ),
                const SizedBox(width: 5),
                Text(
                  formatNumber(widget.servicePost.reportCount ?? 0),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      selected: true,
      onTap: () {
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
      },
      title: widget.servicePost.categoriesId != 7
          ? Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                '${widget.servicePost.distance!.clamp(0, 999).toInt().toString()}KM',
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward,
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

  void _editPost(BuildContext context) {
    // Navigate to edit page or display edit UI
  }

  String _formatTimeDifference(DateTime? date) {
    if (date == null) return 'Unknown time';
    Duration difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    return '${difference.inDays} days ago';
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
}
