import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/constants.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ImageGrid extends StatefulWidget {
  final List<String> imageUrls;
  final Function(String)? onImageTap;
  final bool autoPlayVideos;
  final bool showFullscreenOption;
  final String uniqueId; // Add a unique identifier for this instance

  const ImageGrid({
    super.key,
    required this.imageUrls,
    this.onImageTap,
    this.autoPlayVideos = true,
    this.showFullscreenOption = true,
    // Use a default unique ID if not provided, but encourage users to provide one
    this.uniqueId = '',
  });

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> with RouteAware {
  late PageController _pageController;
  int _currentIndex = 0;
  late RouteObserver<PageRoute> routeObserver;
  bool _isMuted = true;
  final Map<String, VideoPlayerController> _activeControllers = {};
  static const double MAX_MEDIA_HEIGHT = 500.0;

  // Used to detect when the user is manually scrolling
  bool _isUserScrolling = false;

  // Track if the grid is visible on screen
  bool _isVisible = false;
  bool _isPaused = false;

  // Track auto-scrolling for videos that finish
  Timer? _autoScrollTimer;

  // Unique key for visibility detector
  late final String _visibilityKey;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Create a unique key for this instance's visibility detector
    _visibilityKey = widget.uniqueId.isNotEmpty
        ? 'image_grid_${widget.uniqueId}'
        : 'image_grid_${hashCode}';

    // Add scroll listener to detect user interaction
    _pageController.addListener(_handleScroll);
  }

  void _handleScroll() {
    // This helps us determine if the user is manually scrolling
    if (_pageController.page != _currentIndex.toDouble()) {
      _isUserScrolling = true;
      // Reset after short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _isUserScrolling = false;
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      routeObserver = ModalRoute.of(context)
          ?.navigator
          ?.widget
          .observers
          .firstWhere((observer) => observer is RouteObserver<PageRoute>,
          orElse: () => RouteObserver<PageRoute>())
      as RouteObserver<PageRoute>;
      routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    } catch (e) {
      // Handle the case where route observer is not available
      print('Warning: Could not register route observer: $e');
    }
  }

  @override
  void didPopNext() {
    _resumeCurrentVideoIfVisible();
  }

  @override
  void didPush() => _pauseAllVideos();

  @override
  void didPop() => _pauseAllVideos();

  @override
  void didPushNext() {
    _pauseAllVideos();
    _isPaused = true;
  }

  void _pauseAllVideos() {
    for (var controller in _activeControllers.values) {
      if (controller.value.isInitialized && controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void _resumeCurrentVideoIfVisible() {
    // Only resume if the widget is visible
    if (!_isVisible || _isPaused) return;

    _isPaused = false;

    // Check if there's a video at the current index
    if (_currentIndex < widget.imageUrls.length) {
      final currentUrl = widget.imageUrls[_currentIndex];
      if (currentUrl.endsWith('.mp4') && widget.autoPlayVideos) {
        final fullUrl = '${Constants.apiBaseUrl}/$currentUrl';
        final controller = _activeControllers[fullUrl];
        if (controller != null && controller.value.isInitialized) {
          controller.play();
        }
      }
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });

    for (var controller in _activeControllers.values) {
      if (controller.value.isInitialized) {
        controller.setVolume(_isMuted ? 0 : 1);
      }
    }
  }

  void _handleVideoEnd() {
    // If this is not the last item, auto-advance after video ends
    if (_currentIndex < widget.imageUrls.length - 1) {
      _autoScrollTimer?.cancel();
      _autoScrollTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted && !_isUserScrolling) {
          _pageController.animateToPage(
            _currentIndex + 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _releaseUnusedControllers() {
    // Find controllers that are not at the current index or neighboring indices
    // to release resources for videos that aren't likely to be viewed soon

    final currentUrl = widget.imageUrls[_currentIndex];
    final currentFullUrl = '${Constants.apiBaseUrl}/$currentUrl';

    // Keep the current, previous, and next controllers
    final keysToKeep = <String>{};
    if (_activeControllers.containsKey(currentFullUrl)) {
      keysToKeep.add(currentFullUrl);
    }

    // Add previous and next if they exist
    if (_currentIndex > 0) {
      final prevUrl = widget.imageUrls[_currentIndex - 1];
      if (prevUrl.endsWith('.mp4')) {
        final prevFullUrl = '${Constants.apiBaseUrl}/$prevUrl';
        if (_activeControllers.containsKey(prevFullUrl)) {
          keysToKeep.add(prevFullUrl);
        }
      }
    }

    if (_currentIndex < widget.imageUrls.length - 1) {
      final nextUrl = widget.imageUrls[_currentIndex + 1];
      if (nextUrl.endsWith('.mp4')) {
        final nextFullUrl = '${Constants.apiBaseUrl}/$nextUrl';
        if (_activeControllers.containsKey(nextFullUrl)) {
          keysToKeep.add(nextFullUrl);
        }
      }
    }

    // Dispose controllers that are not needed
    final keysToRemove = <String>[];
    _activeControllers.forEach((url, controller) {
      if (!keysToKeep.contains(url)) {
        if (controller.value.isInitialized) {
          controller.pause();
          controller.dispose();
        }
        keysToRemove.add(url);
      }
    });

    for (final key in keysToRemove) {
      _activeControllers.remove(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final currentUrl = widget.imageUrls[_currentIndex];
    final isVideo = currentUrl.toLowerCase().endsWith('.mp4');

    // Wrap the entire widget with a visibility detector
    return VisibilityDetector(
      key: Key(_visibilityKey),
      onVisibilityChanged: (info) {
        final isVisible = info.visibleFraction > 0.1; // Consider visible if at least 10% is shown

        if (mounted && isVisible != _isVisible) {
          setState(() {
            _isVisible = isVisible;
          });

          if (isVisible) {
            _resumeCurrentVideoIfVisible();
          } else {
            _pauseAllVideos();
          }
        }
      },
      child: Container(
        width: screenWidth,
        height: MAX_MEDIA_HEIGHT,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Render content
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _isUserScrolling = false;
                });
                // Handle video playback when page changes
                _pauseAllVideos();
                _resumeCurrentVideoIfVisible();

                // Clean up unused controllers to save memory
                _releaseUnusedControllers();
              },
              itemBuilder: (context, index) {
                final url = widget.imageUrls[index];
                final isCurrentVideo = url.toLowerCase().endsWith('.mp4');

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.05),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isCurrentVideo
                        ? VideoItem(
                      url: '${Constants.apiBaseUrl}/$url',
                      shouldPlay: _currentIndex == index && widget.autoPlayVideos && _isVisible && !_isPaused,
                      isMuted: _isMuted,
                      onToggleMute: _toggleMute,
                      maxHeight: MAX_MEDIA_HEIGHT,
                      onVideoEnd: _handleVideoEnd,
                      onControllerCreated: (controller, url) {
                        _activeControllers[url] = controller;
                      },
                      onPlayStateChanged: (isPlaying) {
                        // You could track play state here if needed
                      },
                    )
                        : GestureDetector(
                      onTap: widget.onImageTap != null
                          ? () => widget.onImageTap!(url)
                          : null,
                      child: ImageContainer(
                        url: url,
                        maxHeight: MAX_MEDIA_HEIGHT,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Page indicator
            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: widget.imageUrls.length,
                      effect: WormEffect(
                        dotWidth: 8,
                        dotHeight: 8,
                        activeDotColor: Colors.white,
                        dotColor: Colors.white.withOpacity(0.5),
                        radius: 4,
                      ),
                    ),
                  ),
                ),
              ),

            // Media type indicator
            Positioned(
              top: 16,
              left: 16,
              child: _buildMediaTypeIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTypeIndicator() {
    final currentUrl = widget.imageUrls[_currentIndex];
    final isVideo = currentUrl.toLowerCase().endsWith('.mp4');

    if (!isVideo) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.videocam,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          const Text(
            'VIDEO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.removeListener(_handleScroll);
    _pageController.dispose();

    // Clean up all video controllers
    for (var controller in _activeControllers.values) {
      controller.dispose();
    }
    _activeControllers.clear();

    try {
      routeObserver.unsubscribe(this);
    } catch (e) {
      // Handle the case where unsubscribe fails
      print('Warning: Could not unsubscribe from route observer: $e');
    }
    super.dispose();
  }
}

class ImageContainer extends StatelessWidget {
  final String url;
  final double maxHeight;

  const ImageContainer({
    super.key,
    required this.url,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CachedNetworkImage(
          imageUrl: '${Constants.apiBaseUrl}/$url',
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) {
            return Image(
              image: imageProvider,
              fit: BoxFit.cover,
              height: maxHeight,
              width: constraints.maxWidth,
            );
          },
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.grey[400],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VideoItem extends StatefulWidget {
  final String url;
  final bool shouldPlay;
  final bool isMuted;
  final VoidCallback onToggleMute;
  final double maxHeight;
  final VoidCallback? onVideoEnd;
  final Function(bool isPlaying)? onPlayStateChanged;
  final Function(VideoPlayerController controller, String url)? onControllerCreated;

  const VideoItem({
    super.key,
    required this.url,
    this.shouldPlay = false,
    required this.isMuted,
    required this.onToggleMute,
    required this.maxHeight,
    this.onVideoEnd,
    this.onPlayStateChanged,
    this.onControllerCreated,
  });

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  final ValueNotifier<Duration> _videoProgress = ValueNotifier(Duration.zero);
  bool _isUserInteracting = false;
  bool _showControls = false;
  late AnimationController _animationController;
  Timer? _controlsTimer;
  bool _isBuffering = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    try {
      if (!mounted) return;

      setState(() {
        _isBuffering = true;
      });

      await _controller.initialize();

      if (_isDisposed) {
        return;
      }

      _controller.setLooping(true);
      _controller.setVolume(widget.isMuted ? 0 : 1);

      // Notify parent about the controller
      widget.onControllerCreated?.call(_controller, widget.url);

      // Register listeners
      _controller.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isBuffering = false;
        });

        if (widget.shouldPlay) {
          _controller.play();
          widget.onPlayStateChanged?.call(true);
        }
      }
    } catch (e) {
      print('Error initializing video: $e');
      print('Video URL: ${widget.url}');
      if (mounted) {
        setState(() {
          _isBuffering = false;
        });
      }
    }
  }

  void _videoListener() {
    if (_isDisposed) return;

    if (_controller.value.isBuffering && !_isBuffering) {
      if (mounted) {
        setState(() {
          _isBuffering = true;
        });
      }
    } else if (!_controller.value.isBuffering && _isBuffering) {
      if (mounted) {
        setState(() {
          _isBuffering = false;
        });
      }
    }

    // Update progress
    if (!_isUserInteracting && mounted) {
      _videoProgress.value = _controller.value.position;
    }

    // Handle video ended event
    if (_controller.value.position >= _controller.value.duration &&
        _controller.value.duration.inMilliseconds > 0) {
      widget.onVideoEnd?.call();
    }
  }

  void _showControlsWithAutoHide() {
    if (!mounted) return;

    setState(() {
      _showControls = true;
    });
    _resetControlsTimer();
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (!mounted || !_isInitialized) return;

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        widget.onPlayStateChanged?.call(false);
      } else {
        _controller.play();
        widget.onPlayStateChanged?.call(true);
        _resetControlsTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return SizedBox(
        height: widget.maxHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final videoWidth = _controller.value.size.width;
        final videoHeight = _controller.value.size.height;
        final videoAspectRatio = videoWidth / videoHeight;
        final screenWidth = constraints.maxWidth;

        // Calculate dimensions
        double finalWidth = screenWidth;
        double finalHeight = screenWidth / videoAspectRatio;

        // Handle tall videos (center crop) vs short videos (letterbox)
        BoxFit fitMode;
        Alignment alignment;

        if (finalHeight > widget.maxHeight) {
          // Video is taller than our max height - we'll center crop
          finalHeight = widget.maxHeight;
          fitMode = BoxFit.cover;
          alignment = Alignment.center;
        } else {
          // Video is shorter than max height - we'll letterbox
          fitMode = BoxFit.contain;
          alignment = Alignment.center;
        }

        return GestureDetector(
          onTap: _showControlsWithAutoHide,
          child: Container(
            width: finalWidth,
            height: finalHeight,
            color: Colors.black,
            child: Stack(
              children: [
                // Video player
                Positioned.fill(
                  child: FittedBox(
                    fit: fitMode,
                    alignment: alignment,
                    child: SizedBox(
                      width: videoWidth,
                      height: videoHeight,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),

                // Buffering indicator
                if (_isBuffering)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),

                // Video controls overlay (conditionally visible)
                if (_showControls)
                  _buildVideoControls(),

                // Play button when paused (only when controls are not showing)
                if (!_showControls && !_controller.value.isPlaying)
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _togglePlayPause,
                        customBorder: const CircleBorder(),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Volume status indicator
                Positioned(
                  top: 16,
                  right: 16,
                  child: AnimatedOpacity(
                    opacity: widget.isMuted ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.volume_off,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoControls() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.7, 1.0],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Progress section
              ValueListenableBuilder(
                valueListenable: _videoProgress,
                builder: (context, Duration value, _) {
                  // Make sure we have valid double values for the slider
                  final maxDuration = _controller.value.duration.inSeconds.toDouble().isFinite
                      ? _controller.value.duration.inSeconds.toDouble()
                      : 0.0;
                  final current = value.inSeconds.toDouble().clamp(0.0, maxDuration > 0 ? maxDuration : 0.0);

                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withOpacity(0.3),
                        ),
                        child: Slider(
                          value: current,
                          min: 0.0,
                          max: maxDuration > 0.0 ? maxDuration : 1.0, // Ensure max is never 0
                          onChangeStart: (_) {
                            _isUserInteracting = true;
                            _controlsTimer?.cancel(); // Don't hide controls while interacting
                          },
                          onChanged: (newValue) {
                            _videoProgress.value = Duration(seconds: newValue.toInt());
                          },
                          onChangeEnd: (newValue) {
                            _isUserInteracting = false;
                            try {
                              _controller.seekTo(Duration(seconds: newValue.toInt()));
                            } catch (e) {
                              print('Error seeking: $e');
                            }
                            _resetControlsTimer(); // Resume auto-hide
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(value),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              _formatDuration(_controller.value.duration),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Control buttons
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        widget.isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        widget.onToggleMute();
                        _resetControlsTimer();
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        // Handle fullscreen mode here
                        _resetControlsTimer();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void didUpdateWidget(VideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If URL changed, we need to reinitialize the controller
    if (oldWidget.url != widget.url) {
      _controller.removeListener(_videoListener);
      _controller.dispose();
      _isInitialized = false;
      _initializeController();
      return;
    }

    // Handle mute state changes
    if (oldWidget.isMuted != widget.isMuted && _isInitialized) {
      _controller.setVolume(widget.isMuted ? 0 : 1);
    }

    // Handle play state changes
    if (_isInitialized) {
      if (widget.shouldPlay && !_controller.value.isPlaying) {
        _controller.play();
        widget.onPlayStateChanged?.call(true);
      } else if (!widget.shouldPlay && _controller.value.isPlaying) {
        _controller.pause();
        widget.onPlayStateChanged?.call(false);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controlsTimer?.cancel();
    _animationController.dispose();

    if (_isInitialized) {
      _controller.removeListener(_videoListener);
      // Note: We don't dispose the controller here as it's now managed by the parent
      // The parent will handle disposing it when appropriate
    }

    super.dispose();
  }
}