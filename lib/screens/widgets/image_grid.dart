import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../app_theme.dart';

class ImageGrid extends StatefulWidget {
  final List<String> imageUrls;
  final Function(String)? onImageTap;

  const ImageGrid({super.key, required this.imageUrls, this.onImageTap});

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> with RouteAware {
  late PageController _pageController;
  int _currentIndex = 0;
  late RouteObserver<PageRoute> routeObserver;

  // Global variable to keep track of mute status
  static bool _isMuted = false;

  // List of all active video controllers
  static final List<VideoPlayerController> _activeControllers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver = ModalRoute.of(context)?.navigator?.widget.observers
        .firstWhere((observer) => observer is RouteObserver<PageRoute>, orElse: () => RouteObserver<PageRoute>()) as RouteObserver<PageRoute>;
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    setState(() {
      // Resume video playback if returning to this screen
    });
  }

  @override
  void didPush() {
    // Pause all videos when this screen is pushed
    _pauseAllVideos();
  }

  @override
  void didPop() {
    // Pause all videos when this screen is popped
    _pauseAllVideos();
  }

  @override
  void didPushNext() {
    // Pause all videos when navigating to the next screen
    _pauseAllVideos();
  }

  void _pauseAllVideos() {
    for (var controller in _activeControllers) {
      controller.pause();
    }
  }

  static void _toggleMute() {
    _isMuted = !_isMuted;
    for (var controller in _activeControllers) {
      controller.setVolume(_isMuted ? 0 : 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width * (3 / 2.5), // Adjust as needed
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final url = widget.imageUrls[index];
              return GestureDetector(
                onTap: () => widget.onImageTap?.call(url),
                child: url.endsWith('.mp4')
                    ? VideoItem(url: url, shouldPlay: _currentIndex == index)
                    : _buildImageWidget(url),
              );
            },
          ),
          Positioned(
            bottom: 16, // Distance from bottom
            child: SmoothPageIndicator(
              controller: _pageController,  // Connect the controller
              count: widget.imageUrls.length,  // Number of items in the PageView
              effect: const WormEffect(
                dotWidth: 7.0,
                dotHeight: 7.0,
                activeDotColor: Colors.black,  // Active dot color
                dotColor: Colors.white,  // Inactive dot color
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),  // Adjust the radius as needed
      child: Image.network(
        url,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _pageController.dispose();
    super.dispose();
  }
}

class VideoItem extends StatefulWidget {
  final String url;
  final bool shouldPlay;

  const VideoItem({super.key, required this.url, this.shouldPlay = false});

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;
  bool _isControllerDisposed = false;
  final ValueNotifier<Duration> _videoProgress = ValueNotifier(Duration.zero);
  bool _isUserChangingSlider = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.setVolume(_ImageGridState._isMuted ? 0 : 1);
          _ImageGridState._activeControllers.add(_controller);
        }
      });
    _controller.setLooping(true);
    _controller.addListener(() {
      if (!_isUserChangingSlider) {
        _videoProgress.value = _controller.value.position;
      }
    });
  }

  @override
  void didUpdateWidget(VideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isControllerDisposed) {
      if (widget.shouldPlay && !_controller.value.isPlaying) {
        for (var controller in _ImageGridState._activeControllers) {
          if (controller != _controller) {
            controller.pause();
          }
        }
        _controller.play();
      } else if (!widget.shouldPlay && _controller.value.isPlaying) {
        _controller.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),  // Same corner radius as images
      child: Stack(
        children: [
          Center(
            child: VisibilityDetector(
              key: Key(widget.url),
              onVisibilityChanged: (VisibilityInfo info) {
                if (_isControllerDisposed) return;  // Check if controller is disposed.

                if (info.visibleFraction > 0.5 && !_controller.value.isPlaying) {
                  for (var controller in _ImageGridState._activeControllers) {
                    if (controller != _controller) {
                      controller.pause();
                    }
                  }
                  _controller.play();
                } else if (info.visibleFraction <= 0.5 && _controller.value.isPlaying) {
                  _controller.pause();
                }
              },
              child: _controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  : AspectRatio(
                aspectRatio: 4 / 3,  // Common video aspect ratio
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.lightPrimaryColor
                        : AppTheme.darkPrimaryColor,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            for (var controller in _ImageGridState._activeControllers) {
                              if (controller != _controller) {
                                controller.pause();
                              }
                            }
                            _controller.play();
                          }
                        });
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _videoProgress,
                      builder: (context, value, child) {
                        final maxDuration = _controller.value.duration;
                        return Slider(
                          value: value.inSeconds.toDouble(),
                          min: 0.0,
                          max: maxDuration.inSeconds.toDouble(),
                          onChanged: (newValue) {
                            setState(() {
                              _isUserChangingSlider = true;
                              _videoProgress.value = Duration(seconds: newValue.toInt());
                            });
                          },
                          onChangeEnd: (newValue) {
                            setState(() {
                              _isUserChangingSlider = false;
                              _controller.seekTo(_videoProgress.value);
                            });
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _ImageGridState._isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _ImageGridState._toggleMute();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    _ImageGridState._activeControllers.remove(_controller);
    _controller.dispose();
    _isControllerDisposed = true;  // Set the flag to indicate disposal.
    super.dispose();
  }
}
