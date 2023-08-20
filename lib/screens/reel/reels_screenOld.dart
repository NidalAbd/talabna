import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/screens/interaction_widget/report_tile.dart';
import 'package:talbna/screens/widgets/comment_sheet.dart';
import 'package:talbna/screens/widgets/user_avatar_profile.dart';
import 'package:talbna/utils/constants.dart';
import 'package:video_player/video_player.dart';

class ReelsHomeScreen extends StatefulWidget {
  const ReelsHomeScreen({Key? key, required this.userId, this.servicePost})
      : super(key: key);
  final int userId;
  final ServicePost? servicePost;

  @override
  State<ReelsHomeScreen> createState() => _ReelsHomeScreenState();
}

class _ReelsHomeScreenState extends State<ReelsHomeScreen> {
  late UserProfileBloc _userProfileBloc;
  late ServicePostBloc _servicePostBloc;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  VideoPlayerController? _controller;
  final double iconSize = 35;
  final PageController _pageController = PageController();
  final ScrollController _scrollCategoryPostController = ScrollController();
  List<ServicePost> _servicePostsReel = [];
  int _currentPost = 1;
  int _currentMedia = 1;
  int _totalPostMedia = 1;

  @override
  void initState() {
    super.initState();
    _userProfileBloc = context.read<UserProfileBloc>()
      ..add(UserProfileRequested(id: widget.userId));
    _scrollCategoryPostController.addListener(_onScrollReelPost);

    _servicePostBloc = context.read<ServicePostBloc>()
      ..add(GetServicePostsRealsEvent(_currentPage));

    // Initialize the VideoPlayerController with an empty network URL
    _controller = null;

    // Check if the initial service post contains a video
    if (widget.servicePost != null &&
        widget.servicePost!.photos!.isNotEmpty &&
        isVideo(widget.servicePost!.photos!.first.src!)) {
      // Update the VideoPlayerController with the URL of the video
      _controller = VideoPlayerController.network(
          '${Constants.apiBaseUrl}/storage/${widget.servicePost!.photos!.first.src!}')
        ..initialize().then((_) {
          _controller!.setLooping(true);
          _controller!.play();
          setState(() {});
        });
    }
  }

  bool isVideo(String url) {
    return url.toLowerCase().endsWith('.mp4');
  }

  void _onScrollReelPost() {
    if (!_hasReachedMax &&
        _scrollCategoryPostController.offset >=
            _scrollCategoryPostController.position.maxScrollExtent &&
        !_scrollCategoryPostController.position.outOfRange) {
      _currentPage++;
      _servicePostBloc.add(GetServicePostsRealsEvent(_currentPage));
    }
  }

  Future<void> _handleRefreshReelPost() async {
    _currentPage = 1;
    _hasReachedMax = false;
    _servicePostsReel.clear();
    _servicePostBloc.add(GetServicePostsRealsEvent(_currentPage));
  }

  void _handleReelPostLoadSuccess(
      List<ServicePost> servicePosts, bool hasReachedMax) {
    setState(() {
      _hasReachedMax = hasReachedMax;
      _servicePostsReel = [..._servicePostsReel, ...servicePosts];
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

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _servicePostsReel.clear();
    _scrollCategoryPostController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopReelPost,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.lightPrimaryColor
            : AppTheme.darkPrimaryColor,
        body: BlocListener<ServicePostBloc, ServicePostState>(
          listenWhen: (previous, current) {
            return current is ServicePostLoadSuccess;
          },
          bloc: _servicePostBloc,
          listener: (context, state) {
            if (state is ServicePostLoadSuccess) {
              _handleReelPostLoadSuccess(
                  state.servicePosts, state.hasReachedMax);
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.lightPrimaryColor
                    : AppTheme.darkPrimaryColor,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPost = index + 1;
                      _currentMedia = 1;
                      _totalPostMedia = _servicePostsReel[index].photos!.length;
                      _userProfileBloc.add(UserProfileRequested(id: _servicePostsReel[index].userId!));
                    });
                    if (_controller?.value.isPlaying ?? false) {
                      _controller?.pause();
                    }
                    if (index == _servicePostsReel.length - 1 && !_hasReachedMax) {
                      _currentPage++;
                      _servicePostBloc.add(GetServicePostsRealsEvent(_currentPage));
                    }
                    if (isVideo(_servicePostsReel[index].photos!.first.src!)) {
                      _controller = VideoPlayerController.network(
                          '${Constants.apiBaseUrl}/storage/${_servicePostsReel[index].photos!.first.src!}');
                      _controller!.initialize().then((_) {
                        _controller!.setLooping(true);
                        _controller!.play();
                      });
                    } else {
                      _controller?.dispose();
                      _controller = null;
                    }
                  },
                  itemCount: _hasReachedMax
                      ? _servicePostsReel.length
                      : _servicePostsReel.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= _servicePostsReel.length) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    final servicePost = _servicePostsReel[index];
                    bool isFavorite = _servicePostsReel[index].isFavorited!;
                    return Stack(
                      children: [
                        Center(
                          child: PageView.builder(
                            itemCount: servicePost.photos!.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentMedia =
                                    index + 1; // update current media index
                              });
                            },
                            itemBuilder: (context, photoIndex) {
                              final photo = servicePost.photos![photoIndex];
                              if (isVideo(photo.src!)) {
                                return ReelVideoPlayer(
                                  videoUrl:
                                  '${Constants.apiBaseUrl}/storage/${photo.src!}',
                                  isPlaying: _currentMediaIsVideo() && (_controller?.value.isPlaying ?? false),
                                  onTap: () {
                                    setState(() {
                                      if (_currentMediaIsVideo()) {
                                        if (_controller?.value.isPlaying ?? false) {
                                          _controller?.pause();
                                        } else {
                                          _controller?.play();
                                        }
                                      }
                                    });
                                  },
                                );
                              } else {
                                // The photo is not a video, display it as an image.
                                return Image.network(
                                    '${Constants.apiBaseUrl}/storage/${photo.src!}');
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _currentMediaIsVideo()
                              ? VideoProgressIndicator(
                            _controller!,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Colors.white,
                              bufferedColor: Colors.white54,
                              backgroundColor: Colors.grey,
                            ),
                          )
                              : Container(),
                        ),
                        Positioned(
                          top: 60,
                          right: 20,
                          child: _servicePostsReel.isNotEmpty
                              ? Text(
                            "$_currentMedia / $_totalPostMedia",
                            style:
                            const TextStyle(color: Colors.white),
                          )
                              : const CircularProgressIndicator(),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              BlocConsumer<UserProfileBloc, UserProfileState>(
                                bloc: _userProfileBloc,
                                listener: (context, state) {
                                  if (state is UserProfileUpdateSuccess) {
                                    BlocProvider.of<UserProfileBloc>(context)
                                        .add(UserProfileRequested(
                                        id: widget.userId));
                                  }
                                },
                                builder: (context, state) {
                                  if (state is UserProfileLoadSuccess) {
                                    final user = state.user;
                                    return Column(
                                      children: [
                                        UserAvatarProfile(
                                          imageUrl:
                                          '${Constants.apiBaseUrl}/storage/${user.photos?.first.src}',
                                          radius: 20,
                                          toUser: user.id,
                                          canViewProfile: false,
                                          fromUser: user.id,
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.favorite,
                                      size: iconSize,
                                      color: isFavorite ? Colors.red : Colors.white,
                                    ),
                                    onPressed: () {
                                      _servicePostBloc.add(
                                          ToggleFavoriteServicePostEvent(
                                              servicePostId:
                                              _servicePostsReel[index].id!));
                                    },
                                  ),
                                  Text(
                                    _servicePostsReel[index]
                                        .favoritesCount
                                        .toString(),
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  CommentModalBottomSheet(
                                    iconSize: iconSize,
                                    userProfileBloc: _userProfileBloc,
                                    userId: widget.userId,
                                  ),
                                  Text(
                                    _servicePostsReel[index]
                                        .favoritesCount
                                        .toString(),
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ReportTile(
                                              type: 'service_post',
                                              userId: _servicePostsReel[index].id!,
                                            );
                                          });
                                    },
                                    icon: Icon(
                                      Icons.flag,
                                      size: iconSize,
                                    ),
                                  ),
                                  Text(
                                    _servicePostsReel[index]
                                        .reportCount
                                        .toString(),
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.share,
                                  size: iconSize - 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  scrollDirection: Axis.vertical,
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
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _currentMediaIsVideo() {
    if (_currentPost > 0 && _currentPost <= _servicePostsReel.length) {
      final servicePost = _servicePostsReel[_currentPost - 1];
      if (_currentMedia > 0 && _currentMedia <= servicePost.photos!.length) {
        final photo = servicePost.photos![_currentMedia - 1];
        return isVideo(photo.src!);
      }
    }
    return false;
  }
}

class ReelVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isPlaying;
  final VoidCallback onTap;

  const ReelVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.isPlaying,
    required this.onTap,
  }) : super(key: key);

  @override
  _ReelVideoPlayerState createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        _controller.setLooping(true);
        setState(() {
          _controller.play();
        });
      });
  }

  @override
  void didUpdateWidget(covariant ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.value.isPlaying) {
      _controller.play();
      setState(() {
        _isPlaying = true;
      });
    } else if (!widget.isPlaying && _controller.value.isPlaying) {
      _controller.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double videoAspectRatio = _controller.value.aspectRatio;
    if (videoAspectRatio.isNaN) {
      videoAspectRatio = 16 / 9;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
          _isPlaying = _controller.value.isPlaying;
        });
        widget.onTap();
      },
      child: AspectRatio(
        aspectRatio: videoAspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            if (!_isPlaying)
              const Icon(
                Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
