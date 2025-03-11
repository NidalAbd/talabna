import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/photos.dart';

class ReelsHomeScreen extends StatefulWidget {
  const ReelsHomeScreen({super.key, required this.userId, this.servicePost});
  final int userId;
  final ServicePost? servicePost;

  @override
  State<ReelsHomeScreen> createState() => _ReelsHomeScreenState();
}

class _ReelsHomeScreenState extends State<ReelsHomeScreen> {
  late UserProfileBloc _userProfileBloc;
  late ServicePostBloc _servicePostBloc;
  int _currentPage = 1;
  List<ServicePost> _servicePosts = [];
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, int> _servicePostMediaIndices = {};
  late PageController _scrollCategoryPostController = PageController();
  bool _hasReachedMax = false;

  @override
  void initState() {
    super.initState();
    _userProfileBloc = context.read<UserProfileBloc>()
      ..add(UserProfileRequested(id: widget.userId));
    _servicePostBloc = context.read<ServicePostBloc>()
      ..add(GetServicePostsRealsEvent( page: _currentPage));
    _scrollCategoryPostController = PageController()
      ..addListener(_onScrollReelPost);
  }

  void _loadNextPage() {
    if (!_hasReachedMax) {
      _currentPage += 1;
      _servicePostBloc.add(GetServicePostsRealsEvent( page: _currentPage));
    }
  }

  void _onScrollReelPost() {
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
    _servicePostBloc.add(GetServicePostsRealsEvent( page: _currentPage));
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

  @override
  void dispose() {
    super.dispose();
    _scrollCategoryPostController.dispose();
    _servicePosts.clear();
    _videoControllers.keys.toList().forEach(_disposeVideoPlayerController);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopReelPost,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.lightPrimaryColor.withOpacity(0.8)
            : AppTheme.darkPrimaryColor.withOpacity(0.8),
        body: BlocListener<ServicePostBloc, ServicePostState>(
          listenWhen: (previous, current) =>
              true, // Listen to all state changes
          bloc: _servicePostBloc,
          listener: (context, state) {
            if (state is ServicePostLoadSuccess) {
              _handleReelPostLoadSuccess(
                  state.servicePosts, state.hasReachedMax);
            } else if (state is ServicePostLoadFailure) {
              // Handle the error state
              // You could show an error message to the user, for example
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('An error occurred: ${state.errorMessage}')));
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
                return Stack(
                  children: <Widget>[
                    // Media display
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity! > 0) {
                          // Swipe Down
                          if (_scrollCategoryPostController.page! > 0) {
                            _scrollCategoryPostController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        } else if (details.primaryVelocity! < 0) {
                          // Swipe Up
                          if (_scrollCategoryPostController.page! <
                              _servicePosts.length - 1) {
                            _scrollCategoryPostController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        }
                      },
                      onVerticalDragUpdate: (details) {},
                      onHorizontalDragEnd: (details) {
                        int currentPostId = _servicePosts[index].id!;
                        if (details.primaryVelocity! > 0) {
                          // Swipe Right
                          if (_servicePostMediaIndices[currentPostId]! > 0) {
                            setState(() {
                              _servicePostMediaIndices[currentPostId] =
                                  _servicePostMediaIndices[currentPostId]! - 1;
                            });
                          }
                        } else if (details.primaryVelocity! < 0) {
                          // Swipe Left
                          if (_servicePostMediaIndices[currentPostId]! <
                              _servicePosts[index].photos!.length - 1) {
                            setState(() {
                              _servicePostMediaIndices[currentPostId] =
                                  _servicePostMediaIndices[currentPostId]! + 1;
                            });
                          }
                        }
                      },
                      onHorizontalDragUpdate: (details) {
                        // add horizontal swipe handling
                        // You can monitor continuous swipe status here
                      },
                      child: Center(
                        child: media.isVideo == true
                            ? VideoPlayer(_getVideoPlayerController(media))
                            : Image.network(media.src!), // your Image
                      ),
                    ),
                    Positioned(
                      top: 20.0,
                      right: 16.0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 25, 10, 0),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                post.id.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                '   ${mediaIndex + 1} : ${post.photos?.length ?? 0}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  VideoPlayerController _getVideoPlayerController(Photo photo) {
    VideoPlayerController? controller = _videoControllers[photo.id!];
    if (controller == null) {
      controller = VideoPlayerController.network(photo.src!)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, if the post is still in the list.
          setState(() {});
        });

      _videoControllers[photo.id!] = controller;
    }

    return controller;
  }

  void _disposeVideoPlayerController(int id) {
    VideoPlayerController? controller = _videoControllers[id];
    if (controller != null) {
      controller.dispose();
      _videoControllers.remove(id);
    }
  }
}
