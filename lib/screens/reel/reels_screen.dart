import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/comments/comment_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/widgets/comment_sheet.dart';
import 'package:talbna/screens/widgets/contact_sheet.dart';
import 'package:talbna/utils/constants.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../data/models/photos.dart';
import '../../utils/photo_image_helper.dart';
import '../../utils/premium_badge.dart';
import '../../utils/share_utils.dart';
import 'like_button.dart';

class ReelsHomeScreen extends StatefulWidget {
  const ReelsHomeScreen({
    super.key,
    required this.userId,
    this.servicePost,
    required this.user
  });
  final int userId;
  final User user;
  final ServicePost? servicePost;
  @override
  State<ReelsHomeScreen> createState() => _ReelsHomeScreenState();
}

// Changed from SingleTickerProviderStateMixin to TickerProviderStateMixin
class _ReelsHomeScreenState extends State<ReelsHomeScreen> with TickerProviderStateMixin {
  // BLoC instances
  late UserProfileBloc _userProfileBloc;
  late ServicePostBloc _servicePostBloc;
  late CommentBloc _commentBloc;

  // Animation controllers
  late AnimationController _navigationAnimationController;

  // Page control variables
  int _currentPage = 1;
  List<ServicePost> _servicePosts = [];
  late PageController _pageController;
  bool _hasReachedMax = false;
  int _currentPostIndex = 0;

  // Video control
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, int> _mediaIndices = {};
  final ValueNotifier<Duration> _videoProgress = ValueNotifier(Duration.zero);
  bool _isUserChangingSlider = false;
  final Map<int, bool> _videoLoadings = {};
  final Map<int, List<VoidCallback>> _videoListeners = {};

  // UI settings
  final double _iconSize = 32;
  final bool _autoPlay = true;
  final ScrollPhysics _pageScrollPhysics = const BouncingScrollPhysics();

  @override
  void initState() {
    super.initState();

    // Initialize Blocs
    _userProfileBloc = context.read<UserProfileBloc>()
      ..add(UserProfileRequested(id: widget.userId));
    _commentBloc = context.read<CommentBloc>();
    _servicePostBloc = context.read<ServicePostBloc>()
      ..add(GetServicePostsRealsEvent(page: _currentPage));

    // Initialize controllers
    _pageController = PageController()..addListener(_onScrollReelPost);
    _navigationAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Video progress update timer
    _initVideoProgressTimer();
  }

  void _initVideoProgressTimer() {
    Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      final currentPage = _pageController.page?.round() ?? 0;
      if (currentPage >= _servicePosts.length) return;

      final post = _servicePosts[currentPage];
      final mediaIndex = _mediaIndices[post.id!] ?? 0;

      if (mediaIndex >= post.photos!.length) return;

      final media = post.photos![mediaIndex];

      if (!_isUserChangingSlider &&
          media.isVideo == true &&
          _videoControllers[media.id!]?.value.isInitialized == true) {
        _videoProgress.value = _videoControllers[media.id!]!.value.position;
      }
    });
  }

  void _loadNextPage() {
    if (!_hasReachedMax) {
      _currentPage += 1;
      _servicePostBloc.add(GetServicePostsRealsEvent(page: _currentPage));
    }
  }

  void _onScrollReelPost() {
    final currentPage = _pageController.page?.round() ?? 0;

    if (_servicePosts.isNotEmpty) {
      _handlePageChange(currentPage);
    }

    // Load more if reaching the end
    if (!_hasReachedMax &&
        _pageController.hasClients &&
        _pageController.offset >= _pageController.position.maxScrollExtent - 300) {
      _loadNextPage();
    }
  }

  Future<void> _handleRefresh() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _disposeAllVideoControllers();
    _servicePosts.clear();
    _servicePostBloc.add(GetServicePostsRealsEvent(page: _currentPage));

    // Return to the first page
    if (_pageController.hasClients) {
      _pageController.jumpTo(0);
    }
  }

  void _handleReelPostLoadSuccess(List<ServicePost> servicePosts, bool hasReachedMax) {
    setState(() {
      _hasReachedMax = hasReachedMax;
      final previousMediaIndices = Map.from(_mediaIndices);
      _servicePosts = [..._servicePosts, ...servicePosts];

      for (var post in servicePosts) {
        if (!previousMediaIndices.containsKey(post.id)) {
          _mediaIndices[post.id!] = 0;
        }
      }

      // Clean up unused controllers
      previousMediaIndices.keys
          .where((id) => !_servicePosts.any((post) => post.id == id))
          .toList()
          .forEach((id) => _disposeVideoPlayerController(id));
    });
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(true);
    return false;
  }

  @override
  void dispose() {
    _navigationAnimationController.dispose();
    _pageController.dispose();
    _disposeAllVideoControllers();
    super.dispose();
  }

  void _disposeAllVideoControllers() {
    for (var controller in _videoControllers.values) {
      controller.setLooping(false);
      controller.pause();
      controller.dispose();
    }
    _videoControllers.clear();
    _videoListeners.clear();
    _videoLoadings.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(isDarkMode),
        body: BlocListener<ServicePostBloc, ServicePostState>(
          listenWhen: (previous, current) => true,
          bloc: _servicePostBloc,
          listener: (context, state) {
            if (state is ServicePostLoadSuccess) {
              _handleReelPostLoadSuccess(state.servicePosts, state.hasReachedMax);
            } else if (state is ServicePostLoadFailure) {
              _showErrorSnackBar(state.errorMessage);
            }
          },
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppTheme.lightPrimaryColor,
            child: _buildReelsPageView(),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(true),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
            ),
            onPressed: _handleRefresh,
          ),
        ),
      ],
    );
  }

  Widget _buildReelsPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _servicePosts.length,
      scrollDirection: Axis.vertical,
      physics: _pageScrollPhysics,
      itemBuilder: (context, index) {
        ServicePost post = _servicePosts[index];
        if (post.photos == null || post.photos!.isEmpty) {
          return const SizedBox.shrink();
        }

        int mediaIndex = _mediaIndices[post.id!] ?? 0;
        mediaIndex = min(mediaIndex, post.photos!.length - 1);
        Photo media = post.photos![mediaIndex];

        return _buildReelContent(post, media, mediaIndex);
      },
    );
  }

  Widget _buildReelContent(ServicePost post, Photo media, int mediaIndex) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Main Media Content
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (media.isVideo == true) {
              _toggleVideoPlayback(media);
            }
          },
          onHorizontalDragEnd: (details) {
            int currentPostId = post.id!;
            if (details.primaryVelocity! > 0) {
              _showPreviousMedia(currentPostId);
            } else if (details.primaryVelocity! < 0) {
              _showNextMedia(currentPostId);
            }
          },
          child: Container(
            color: Colors.black,
            child: media.isVideo == true
                ? _buildVideoDisplay(media)
                : _buildImageDisplay(media),
          ),
        ),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Video Progress Bar (conditionally shown for videos)
        if (media.isVideo!)
          _buildVideoProgressBar(media),

        // Media Counter for multiple media
        if (post.hasMultipleMedia)
          _buildMediaCounter(post, mediaIndex),

        // Side Action Buttons
        _buildSideActionButtons(post, media),

        // User Info and Post Description
        _buildUserInfoAndDescription(post),
      ],
    );
  }

  Widget _buildVideoProgressBar(Photo media) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ValueListenableBuilder(
        valueListenable: _videoProgress,
        builder: (context, value, child) {
          double maxSeconds =
          _videoControllers[media.id!]?.value.isInitialized == true
              ? _videoControllers[media.id!]!.value.duration.inSeconds.toDouble()
              : 0.0;
          double currentSeconds = min(
              _videoProgress.value.inSeconds.toDouble(),
              maxSeconds);

          return SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: AppTheme.lightPrimaryColor,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: currentSeconds,
              min: 0.0,
              max: maxSeconds,
              onChanged: (double newValue) {
                setState(() {
                  _isUserChangingSlider = true;
                  _videoProgress.value = Duration(seconds: newValue.toInt());
                });
              },
              onChangeEnd: (double newValue) {
                setState(() {
                  _isUserChangingSlider = false;
                  _videoControllers[media.id!]?.seekTo(_videoProgress.value);
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaCounter(ServicePost post, int mediaIndex) {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          post.photos!.length,
              (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == mediaIndex
                  ? AppTheme.lightPrimaryColor
                  : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideActionButtons(ServicePost post, Photo media) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          _buildUserAvatarWithFollowButton(post),
          const SizedBox(height: 10),
          _buildLikeButton(post),
          _buildCommentButton(post),
          const SizedBox(height: 10),
          _buildContactButton(post),
          const SizedBox(height: 10),
          _buildShareButton(post),
        ],
      ),
    );
  }

  Widget _buildUserAvatarWithFollowButton(ServicePost post) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.lightPrimaryColor,
              width: 2,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[300],
            backgroundImage: CachedNetworkImageProvider(
              ProfileImageHelper.getProfileImageUrl(post.userPhoto),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLikeButton(ServicePost post) {
    return Column(
      children: [
        LikeButton(
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
          iconSize: _iconSize,
          userProfileBloc: _userProfileBloc,
          commentBloc: _commentBloc,
          servicePost: post,
          user: widget.user,
        ),
      ],
    );
  }

  Widget _buildContactButton(ServicePost post) {
    return Column(
      children: [
        ContactModalBottomSheet(
          iconSize: _iconSize,
          userProfileBloc: _userProfileBloc,
          userId: widget.userId,
          servicePost: post,
        ),
      ],
    );
  }

  Widget _buildShareButton(ServicePost post) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.share_rounded,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () async {
              await ShareUtils.shareServicePost(post.id!, title: post.title, type: 'reels');
            },
          ),
        ),

      ],
    );
  }

  Widget _buildUserInfoAndDescription(ServicePost post) {
    return Positioned(
      left: 16,
      right: 80, // Make room for side action buttons
      bottom: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PremiumBadge(badgeType: post.haveBadge ?? 'عادي'),
              const SizedBox(width: 8),
              Text(
                '@${post.userName ?? 'username'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (post.description != null && post.description!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: Text(
                post.description!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoDisplay(Photo media) {
    return VisibilityDetector(
      key: Key('video_${media.id}'),
      onVisibilityChanged: (VisibilityInfo info) {
        final controller = _videoControllers[media.id];
        if (controller != null && controller.value.isInitialized) {
          if (info.visibleFraction > 0.5) {
            controller.play();
          } else {
            controller.pause();
          }
        }
      },
      child: Center(
        child: AspectRatio(
          aspectRatio: _videoControllers[media.id!]?.value.isInitialized == true
              ? _videoControllers[media.id!]!.value.aspectRatio
              : 16 / 9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_getVideoPlayerController(media)),
              if (_videoLoadings[media.id!] != true)
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              if (_videoControllers[media.id!]?.value.isInitialized == true &&
                  !_videoControllers[media.id!]!.value.isPlaying)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: () => _toggleVideoPlayback(media),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageDisplay(Photo media) {
    String imageUrl = media.src!.startsWith('http')
        ? media.src!
        : '${Constants.apiBaseUrl}/${media.src!}';

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightPrimaryColor,
          strokeWidth: 3,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[900],
        child: const Center(
          child: Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 50,
          ),
        ),
      ),
    );
  }

  void _toggleVideoPlayback(Photo media) {
    if (_videoControllers[media.id!]!.value.isPlaying) {
      _videoControllers[media.id!]?.pause();
    } else {
      _videoControllers[media.id!]?.play();
    }
    setState(() {}); // Update UI to show play/pause button
  }

  VideoPlayerController _getVideoPlayerController(Photo photo) {
    if (photo.id == null || photo.src == null) {
      throw ArgumentError('Photo must have a non-null ID and source.');
    }

    String videoUrl = photo.src!.startsWith('http')
        ? photo.src!
        : '${Constants.apiBaseUrl}/${photo.src!}';

    VideoPlayerController? controller = _videoControllers[photo.id];

    if (controller == null) {
      _videoLoadings[photo.id!] = false; // Video is loading
      controller = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _videoLoadings[photo.id!] = true; // Video has loaded
            });
            if (_autoPlay && _currentPostIndex < _servicePosts.length) {
              final currentPost = _servicePosts[_currentPostIndex];
              final currentMediaIndex = _mediaIndices[currentPost.id] ?? 0;
              if (currentMediaIndex < currentPost.photos!.length) {
                final currentMedia = currentPost.photos![currentMediaIndex];
                if (currentMedia.id == photo.id) {
                  controller?.play();
                }
              }
            }
            controller?.setLooping(true);
          }
        }).catchError((error) {
          if (kDebugMode) {
            print('Video initialization error: $error');
          }
          if (mounted) {
            setState(() {
              _videoLoadings[photo.id!] = false;
            });
          }
        });

      // Listeners
      final List<VoidCallback> listeners = [
        // Error listener
            () {
          if (controller!.value.hasError && kDebugMode) {
            print('Video player error: ${controller.value.errorDescription}');
          }
        },

        // Loop listener
            () {
          if (controller!.value.position >= controller.value.duration - const Duration(milliseconds: 300)) {
            controller.seekTo(Duration.zero);
            controller.play();
          }
        },

        // Progress listener
            () {
          if (!_isUserChangingSlider && mounted) {
            _videoProgress.value = controller!.value.position;
          }
        }
      ];

      // Add all listeners
      for (var listener in listeners) {
        controller.addListener(listener);
      }

      // Store listeners for cleanup
      _videoListeners[photo.id!] = listeners;
      _videoControllers[photo.id!] = controller;
    }

    return controller;
  }

  void _pauseAllVideos() {
    for (var controller in _videoControllers.values) {
      if (controller.value.isInitialized && controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void _handlePageChange(int pageIndex) {
    if (_servicePosts.isEmpty || pageIndex < 0 || pageIndex >= _servicePosts.length) {
      return;
    }

    _currentPostIndex = pageIndex;
    final currentPost = _servicePosts[pageIndex];

    if (currentPost.photos == null || currentPost.photos!.isEmpty) {
      return;
    }

    final currentMediaIndex = _mediaIndices[currentPost.id] ?? 0;
    if (currentMediaIndex < 0 || currentMediaIndex >= currentPost.photos!.length) {
      return;
    }

    final currentMedia = currentPost.photos![currentMediaIndex];

    // Pause all videos first
    _pauseAllVideos();

    // Play current video if applicable
    if (currentMedia.isVideo == true &&
        _videoControllers[currentMedia.id!] != null &&
        _videoControllers[currentMedia.id!]!.value.isInitialized) {
      _videoControllers[currentMedia.id!]?.play();
    }
  }

  void _showPreviousMedia(int postId) {
    // Check if we can go to previous media (index > 0)
    if (_mediaIndices.containsKey(postId) && _mediaIndices[postId]! > 0) {
      int currentMediaIndex = _mediaIndices[postId]!;
      final post = _servicePosts.firstWhere((post) => post.id == postId);

      // Handle current media
      final currentMedia = post.photos![currentMediaIndex];
      if (currentMedia.isVideo == true) {
        _pauseAndResetVideo(currentMedia.id!);
      }

      // Update index (DECREASE to go to previous media)
      setState(() {
        _mediaIndices[postId] = currentMediaIndex - 1;
      });

      // Handle previous media (use the new index)
      final newIndex = _mediaIndices[postId]!;
      if (newIndex >= 0 && newIndex < post.photos!.length) {
        final newMedia = post.photos![newIndex];
        if (newMedia.isVideo == true) {
          _prepareAndPlayVideo(newMedia.id!);
        }
      }
    }
  }

  void _showNextMedia(int postId) {
    // Only proceed if the post exists in our data
    if (!_mediaIndices.containsKey(postId)) return;

    final post = _servicePosts.firstWhere((post) => post.id == postId);
    int currentMediaIndex = _mediaIndices[postId]!;
    int totalMediaCount = post.photos!.length;

    // Check if we can go to next media
    if (currentMediaIndex < totalMediaCount - 1) {
      // Handle current media
      final currentMedia = post.photos![currentMediaIndex];
      if (currentMedia.isVideo == true) {
        _pauseAndResetVideo(currentMedia.id!);
      }

      // Update index
      setState(() {
        _mediaIndices[postId] = currentMediaIndex + 1;
      });

      // Handle next media (use the new index)
      final newIndex = _mediaIndices[postId]!;
      if (newIndex >= 0 && newIndex < post.photos!.length) {
        final newMedia = post.photos![newIndex];
        if (newMedia.isVideo == true) {
          _prepareAndPlayVideo(newMedia.id!);
        }
      }
    }
  }

  void _pauseAndResetVideo(int mediaId) {
    final controller = _videoControllers[mediaId];
    if (controller != null && controller.value.isInitialized) {
      controller.pause();
      controller.seekTo(Duration.zero);
    }
  }

  void _prepareAndPlayVideo(int mediaId) {
    final controller = _videoControllers[mediaId];
    if (controller != null && controller.value.isInitialized) {
      controller.seekTo(Duration.zero);
      controller.play();
    }
  }

  void _disposeVideoPlayerController(int id) {
    VideoPlayerController? controller = _videoControllers[id];
    List<VoidCallback>? listeners = _videoListeners[id];

    if (controller != null) {
      if (listeners != null) {
        for (var listener in listeners) {
          controller.removeListener(listener);
        }
      }
      controller.setLooping(false);
      controller.pause();
      controller.dispose();
      _videoControllers.remove(id);
      _videoListeners.remove(id);
      _videoLoadings.remove(id);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _handleRefresh,
        ),
      ),
    );
  }

  // Helper method to format count numbers (e.g., 1000 -> 1K)
  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }
}

// Extension for ServicePost to check if it has multiple media
extension ServicePostExtension on ServicePost {
  bool get hasMultipleMedia => photos != null && photos!.length > 1;
}