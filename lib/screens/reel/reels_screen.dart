import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
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

class ReelsHomeScreen extends StatefulWidget {
  const ReelsHomeScreen({Key? key, required this.userId, this.servicePost, required this.user})
      : super(key: key);
  final int userId;
  final User user;
  final ServicePost? servicePost;

  @override
  State<ReelsHomeScreen> createState() => _ReelsHomeScreenState();
}

class _ReelsHomeScreenState extends State<ReelsHomeScreen> {
  late UserProfileBloc _userProfileBloc;
  late ServicePostBloc _servicePostBloc;
  late CommentBloc _commentBloc;

  int _currentPage = 1;
  List<ServicePost> _servicePosts = [];
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, int> _servicePostMediaIndices = {};
  late PageController _scrollCategoryPostController = PageController();
  bool _hasReachedMax = false;
  final ValueNotifier<Duration> _videoProgress = ValueNotifier(Duration.zero);
  bool _isUserChangingSlider = false;
  final double iconSize = 40;
  late final bool _autoPlay = true;
  final Map<int, bool> _videoLoadings = {};
  final Map<int, List<VoidCallback>> _videoListeners = {};
  int _currentPostIndex = 0;
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    _userProfileBloc = context.read<UserProfileBloc>()
      ..add(UserProfileRequested(id: widget.userId));
    _commentBloc = context.read<CommentBloc>();
    _servicePostBloc = context.read<ServicePostBloc>()
      ..add(GetServicePostsRealsEvent(_currentPage));
    _scrollCategoryPostController = PageController()
      ..addListener(_onScrollReelPost);
    WidgetsFlutterBinding.ensureInitialized();

    Timer.periodic( const Duration(seconds: 0), (Timer t) {
      final currentPage = _scrollCategoryPostController.page?.round() ?? 0;
      if (currentPage >= _servicePosts.length) {
        // Avoid indexing out of bounds
        return;
      }
      final post = _servicePosts[currentPage];
      final mediaIndex = _servicePostMediaIndices[post.id!] ?? 0;

      if (mediaIndex >= post.photos!.length) {
        return;
      }

      final media = post.photos![mediaIndex];

      if (!_isUserChangingSlider &&
          media.isVideo == true &&
          _videoControllers[media.id!]!.value.isInitialized) {
        _videoProgress.value = _videoControllers[media.id!]!.value.position;
      }
    });
  }

  void _loadNextPage() {
    if (!_hasReachedMax) {
      _currentPage += 1;
      _servicePostBloc.add(GetServicePostsRealsEvent(_currentPage));
    }
  }

  void _onScrollReelPost() {
    final currentPage = _scrollCategoryPostController.page?.round() ?? 0;
    _handlePageChange(currentPage);
    if (!_hasReachedMax &&
        _scrollCategoryPostController.offset >=
            _scrollCategoryPostController.position.maxScrollExtent &&
        !_scrollCategoryPostController.position.outOfRange) {
      _loadNextPage();
    }
  }

  Future<void> _handleRefreshReelPost() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _servicePosts.clear();
    _servicePostBloc.add(GetServicePostsRealsEvent(_currentPage));
  }

  void _handleReelPostLoadSuccess(
      List<ServicePost> servicePosts, bool hasReachedMax) {
    setState(() {
      _hasReachedMax = hasReachedMax;
      final previousMediaIndices = Map.from(_servicePostMediaIndices);
      _servicePosts = [..._servicePosts, ...servicePosts];
      for (var post in servicePosts) {
        if (!previousMediaIndices.containsKey(post.id)) {
          _servicePostMediaIndices[post.id!] = 0;
        } else {
          _servicePostMediaIndices[post.id!] =
              previousMediaIndices[post.id]! + 1;
        }
      }
      previousMediaIndices.keys
          .where((id) => !_servicePosts.any((post) => post.id == id))
          .toList()
          .forEach((id) => _disposeVideoPlayerController(id));
    });
  }

  Future<bool> _onWillPopReelPost() async {
    if (_scrollCategoryPostController.offset > 0) {
      _scrollCategoryPostController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
      );
      await Future.delayed(const Duration(milliseconds: 200));
      _handleRefreshReelPost();
      return false;
    } else {
      SystemNavigator.pop(); // Close the app
      return true;
    }
  }

  void _handleMediaScroll(ServicePost post, int mediaIndex) {
    final media = post.photos![mediaIndex];
    if (media.isVideo == true &&
        _videoControllers[media.id!]!.value.isInitialized) {
      _videoControllers[media.id!]?.pause();
      _videoControllers[media.id!]?.seekTo(Duration.zero);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollCategoryPostController.dispose();
    _servicePosts.clear();
    for (var controller in _videoControllers.values) {
      controller.setLooping(false);
      controller.pause();
      controller.dispose();
    }
    _videoControllers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopReelPost,
      child: Scaffold(
        body: BlocListener<ServicePostBloc, ServicePostState>(
          listenWhen: (previous, current) =>
              true, // Listen to all state changes
          bloc: _servicePostBloc,
          listener: (context, state) {
            if (state is ServicePostLoadSuccess) {
              _handleReelPostLoadSuccess(
                  state.servicePosts, state.hasReachedMax);
            } else if (state is ServicePostLoadFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('An error occurred: ${state.errorMessage}')));
            } else if (state is ServicePostFavoriteToggled) {
              isFavorite = state.isFavorite;
              if (isFavorite) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to favourite')));
                setState(() {

                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('removed to favourite')));
                setState(() {

                });
              }
            }
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                _onScrollReelPost();
              }
              return true;
            },
            child: PageView.builder(
              controller: _scrollCategoryPostController,
              itemCount: _servicePosts.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                ServicePost post = _servicePosts[index];
                if (post.photos == null || post.photos!.isEmpty) {
                  return const SizedBox.shrink();
                }
                int mediaIndex = _servicePostMediaIndices[post.id!] ?? 0;
                mediaIndex = min(mediaIndex, post.photos!.length - 1);
                Photo media = post.photos![mediaIndex];
                bool isFavorite = post.isFavorited!;
                return Stack(
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (media.isVideo == true) {
                          _toggleVideoPlayback(media);
                        }
                      },
                      onHorizontalDragEnd: (details) {
                        int currentPostId = _servicePosts[index].id!;
                        if (details.primaryVelocity! > 0) {
                          _showPreviousMedia(currentPostId);
                        } else if (details.primaryVelocity! < 0) {
                          _showNextMedia(currentPostId);
                        }
                      },
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity! > 0) {
                          if (_scrollCategoryPostController.page! > 0) {
                            _scrollCategoryPostController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        } else if (details.primaryVelocity! < 0) {
                          if (_scrollCategoryPostController.page! <
                              _servicePosts.length - 1) {
                            _scrollCategoryPostController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        }
                      },
                      child: media.isVideo == true
                          ? _buildVideoDisplay(media)
                          : _buildImageDisplay(media),
                    ),
                    Positioned(
                      bottom: 0.0,
                      right: 0.0,
                      left: 0,
                      child: media.isVideo!
                          ? ValueListenableBuilder(
                              valueListenable: _videoProgress,
                              builder: (context, value, child) {
                                double maxSeconds =
                                    _videoControllers[media.id!]!
                                            .value
                                            .isInitialized
                                        ? _videoControllers[media.id!]!
                                            .value
                                            .duration
                                            .inSeconds
                                            .toDouble()
                                        : 0.0;
                                double currentSeconds = min(
                                    _videoProgress.value.inSeconds.toDouble(),
                                    maxSeconds);
                                return Slider(
                                  value: currentSeconds,
                                  min: 0.0,
                                  max: maxSeconds,
                                  onChanged: (double newValue) {
                                    setState(() {
                                      _isUserChangingSlider = true;
                                      _videoProgress.value =
                                          Duration(seconds: newValue.toInt());
                                    });
                                  },
                                  onChangeEnd: (double newValue) {
                                    setState(() {
                                      _isUserChangingSlider = false;
                                      _videoControllers[media.id!]
                                          ?.seekTo(_videoProgress.value);
                                    });
                                  },
                                );
                              },
                            )
                          : Container(),
                    ),
                    Positioned(
                      top: 20.0,
                      right: 16.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 25, 10, 0),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '   ${mediaIndex + 1} : ${post.photos?.length ?? 0}', style: const TextStyle(
                            shadows: [
                              Shadow(
                                color: Colors.white, // Shadow color
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon:  const Icon(
                                Icons.arrow_back,
                                size: 30,
                                shadows: [
                                  Shadow(
                                    color: Colors.white, // Shadow color
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 60,
                      child: Column(
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    const Color.fromARGB(238, 249, 230, 248),
                                radius: 25,
                                child: CircleAvatar(
                                  radius: 23,
                                  backgroundImage: Image.network(
                                    '${Constants.apiBaseUrl}/storage/${post.userPhoto!}',
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      return const CircleAvatar(
                                        radius: 22,
                                        backgroundImage:
                                            AssetImage('assets/avatar.png'),
                                      );
                                    },
                                  ).image,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.favorite_rounded,
                                        size: iconSize,
                                        color: isFavorite
                                            ? Colors.red
                                            : Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(
                                                0.5), // Shadow color
                                            offset: const Offset(0,
                                                0), // Shadow offset (vertical, horizontal)
                                            blurRadius:
                                                2, // Blur radius of the shadow
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        _servicePostBloc.add(
                                            ToggleFavoriteServicePostEvent(
                                                servicePostId: post.id!));
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        post.favoritesCount.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                  1), // Shadow color
                                              offset: const Offset(0,
                                                  0), // Shadow offset (vertical, horizontal)
                                              blurRadius:
                                                  4, // Blur radius of the shadow
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CommentModalBottomSheet(
                                      iconSize: iconSize,
                                      userProfileBloc: _userProfileBloc,
                                      commentBloc: _commentBloc,
                                      servicePost: post, user: widget.user,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        post.commentsCount.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                  1), // Shadow color
                                              offset: const Offset(1,
                                                  0), // Shadow offset (vertical, horizontal)
                                              blurRadius:
                                                  2, // Blur radius of the shadow
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ContactModalBottomSheet(
                                  iconSize: iconSize,
                                  userProfileBloc: _userProfileBloc,
                                  userId: widget.userId,
                                  servicePost: post,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.share,
                                    size: iconSize,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black
                                            .withOpacity(1), // Shadow color
                                        offset: const Offset(0, 0),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    await Share.share(
                                        '${Constants.apiBaseUrl}/api/service_posts/${widget.servicePost?.id!}');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoDisplay(Photo media) {
    return VisibilityDetector(
      key: Key('video_${media.id}'), // Ensure a unique key for each video
      onVisibilityChanged: (VisibilityInfo info) {
        // Retrieve the corresponding video controller
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
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: VideoPlayer(_getVideoPlayerController(media)),
        ),
      ),
    );
  }


  Widget _buildImageDisplay(Photo media) {
    return Center(
      child: Hero(
        tag: 'photo_${widget.servicePost?.id}_${_servicePostMediaIndices[widget.servicePost?.id] ?? 0}', // Use the same tag as in ServicePostCardView
        child: FutureBuilder(
          future: precacheImage(NetworkImage(media.src!), context),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.lightPrimaryColor
                      : AppTheme.darkPrimaryColor,
                ),
              );
            }
            return Image.network(media.src!);
          },
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
  }

  void _handlePageChange(int pageIndex) {
    _currentPostIndex = pageIndex;
    if (pageIndex >= 0 && pageIndex < _servicePosts.length) {
      final previousIndex = _currentPostIndex;
      final previousPost = _servicePosts[previousIndex];
      final previousMediaIndex = _servicePostMediaIndices[previousPost.photos?.length] ?? 0;
      final previousMedia = previousPost.photos![previousMediaIndex];
      if (previousMedia.isVideo == true &&
          _videoControllers[previousMedia.id!]!.value.isInitialized) {
        _videoControllers[previousMedia.id!]?.pause();
        _videoControllers[previousMedia.id!]?.seekTo(Duration.zero);
      }

      final currentPost = _servicePosts[_currentPostIndex];
      final currentMediaIndex = _servicePostMediaIndices[currentPost.photos?.length] ?? 0;
      final currentMedia = currentPost.photos![currentMediaIndex];
      if (currentMedia.isVideo == true &&
          _videoControllers[currentMedia.id!]!.value.isInitialized) {
        _videoControllers[currentMedia.id!]?.play();
      }
    }
  }

  void _showPreviousMedia(int postId) {
    if (_servicePostMediaIndices[postId]! > 0) {
      int currentMediaIndex = _servicePostMediaIndices[postId]!;
      setState(() {
        _servicePostMediaIndices[postId] = currentMediaIndex - 1;
      });
      Photo previousMedia = _servicePosts
          .firstWhere((post) => post.id == postId)
          .photos![currentMediaIndex];
      if (previousMedia.isVideo == true &&
          _videoControllers[previousMedia.id!]!.value.isInitialized) {
        _videoControllers[previousMedia.id!]?.pause();
        _videoControllers[previousMedia.id!]?.seekTo(Duration.zero);
      }
      Photo newMedia = _servicePosts
          .firstWhere((post) => post.id == postId)
          .photos![currentMediaIndex - 1];
      if (newMedia.isVideo == true &&
          _videoControllers[newMedia.id!]!.value.isInitialized) {
        _videoControllers[newMedia.id!]?.play();
        _handleMediaScroll(
            _servicePosts.firstWhere((post) => post.id == postId),
            _servicePostMediaIndices[postId]!);
      }
    }
  }

  void _showNextMedia(int postId) {
    int currentMediaIndex = _servicePostMediaIndices[postId]!;
    int totalMediaCount =
        _servicePosts.firstWhere((post) => post.id == postId).photos!.length;
    if (currentMediaIndex < totalMediaCount - 1) {
      setState(() {
        _servicePostMediaIndices[postId] = currentMediaIndex + 1;
      });
      Photo previousMedia = _servicePosts
          .firstWhere((post) => post.id == postId)
          .photos![currentMediaIndex];
      if (previousMedia.isVideo == true &&
          _videoControllers[previousMedia.id!]!.value.isInitialized) {
        _videoControllers[previousMedia.id!]?.pause();
        _videoControllers[previousMedia.id!]?.seekTo(Duration.zero);
      }
      Photo newMedia = _servicePosts
          .firstWhere((post) => post.id == postId)
          .photos![currentMediaIndex + 1];
      if (newMedia.isVideo == true &&
          _videoControllers[newMedia.id!]!.value.isInitialized) {
        _videoControllers[newMedia.id!]?.play();
        _handleMediaScroll(
            _servicePosts.firstWhere((post) => post.id == postId),
            _servicePostMediaIndices[postId]!);
      }
    }
  }

  void _disposeVideoPlayerController(int id) {
    VideoPlayerController? controller = _videoControllers[id];
    List<VoidCallback>? listeners = _videoListeners[id];

    if (controller != null && listeners != null) {
      for (var listener in listeners) {
        controller.removeListener(listener); // remove the listener
      }
      controller.setLooping(false);
      controller.pause();
      controller.dispose();
      _videoControllers.remove(id);
      _videoListeners.remove(id);
    }
  }

  VideoPlayerController _getVideoPlayerController(Photo photo) {
    if (photo.id == null || photo.src == null) {
      throw ArgumentError('Photo must have a non-null ID and source.');
    }

    VideoPlayerController? controller = _videoControllers[photo.id];

    if (controller == null) {
      _videoLoadings[photo.id!] = false; // Indicate the video is loading
      controller = VideoPlayerController.network(photo.src!)
        ..initialize().then((_) {
          setState(() {
            _videoLoadings[photo.id!] = true; // Indicate the video has loaded
          });
          if (_autoPlay) {
            controller?.pause();
          }
          controller?.setLooping(true);
          controller?.seekTo(Duration.zero);
        });

      errorListener() {
        if (controller!.value.hasError) {
          if (kDebugMode) {
            print(
                'Video player had an error: ${controller.value.errorDescription}');
          }
        }
      }

      controller.addListener(errorListener);
      completionListener() {
        if (controller?.value.position == controller?.value.duration) {
          controller?.seekTo(Duration.zero);
        }
      }

      controller.addListener(completionListener);
      // Remember these listeners.
      _videoListeners[photo.id!] = [errorListener, completionListener];
      _videoControllers[photo.id!] = controller;
    }
    return controller;
  }
}
