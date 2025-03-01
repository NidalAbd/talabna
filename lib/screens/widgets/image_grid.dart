import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app_theme.dart';
import '../../utils/constants.dart';

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
  static bool _isMuted = true;
  static final List<VideoPlayerController> _activeControllers = [];
  static const double MAX_MEDIA_HEIGHT = 500.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver = ModalRoute.of(context)
            ?.navigator
            ?.widget
            .observers
            .firstWhere((observer) => observer is RouteObserver<PageRoute>,
                orElse: () => RouteObserver<PageRoute>())
        as RouteObserver<PageRoute>;
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() => _resumeCurrentVideo();
  @override
  void didPush() => _pauseAllVideos();
  @override
  void didPop() => _pauseAllVideos();
  @override
  void didPushNext() => _pauseAllVideos();

  void _pauseAllVideos() {
    for (var controller in _activeControllers) {
      controller.pause();
    }
  }

  void _resumeCurrentVideo() {
    if (_currentIndex < widget.imageUrls.length &&
        widget.imageUrls[_currentIndex].endsWith('.mp4')) {
      for (var controller in _activeControllers) {
        if (controller.dataSource ==
            '${Constants.apiBaseUrl}/storage/${widget.imageUrls[_currentIndex]}') {
          controller.play();
        }
      }
    }
  }

  static void _toggleMute() {
    _isMuted = !_isMuted;
    for (var controller in _activeControllers) {
      controller.setVolume(_isMuted ? 0 : 1);
    }
  }

  Widget _buildReelsHint() {
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
            Icons.video_library,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          const Text(
            'See in Reels',
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
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final currentUrl = widget.imageUrls[_currentIndex];
    final isVideo = currentUrl.toLowerCase().endsWith('.mp4');

    return SizedBox(
      width: screenWidth,
      height: MAX_MEDIA_HEIGHT,
      child: Stack(
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
                          url: '${Constants.apiBaseUrl}/storage/$url',
                          shouldPlay: _currentIndex == index,
                          isMuted: _isMuted,
                          onToggleMute: _toggleMute,
                          maxHeight: MAX_MEDIA_HEIGHT,
                        )
                      : ImageContainer(
                          url: url,
                          maxHeight: MAX_MEDIA_HEIGHT,
                        ),
                ),
              );
            },
          ),
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
        ],
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

class ImageContainer extends StatelessWidget {
  final String url;
  final double maxHeight;

  const ImageContainer({
    Key? key,
    required this.url,
    required this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CachedNetworkImage(
          imageUrl: '${Constants.apiBaseUrl}/storage/$url',
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

  const VideoItem({
    super.key,
    required this.url,
    this.shouldPlay = false,
    required this.isMuted,
    required this.onToggleMute,
    required this.maxHeight,
  });

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  final ValueNotifier<Duration> _videoProgress = ValueNotifier(Duration.zero);
  bool _isUserInteracting = false;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    try {
      await _controller.initialize();
      _controller.setLooping(true);
      _controller.setVolume(widget.isMuted ? 0 : 1);
      _ImageGridState._activeControllers.add(_controller);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        if (widget.shouldPlay) {
          _controller.play();
        }
      }
    } catch (e) {
      print('Error initializing video: $e');
      print('Video URL: ${widget.url}');
    }

    _controller.addListener(() {
      if (!_isUserInteracting && mounted) {
        _videoProgress.value = _controller.value.position;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return SizedBox(
        height: widget.maxHeight,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
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
          onTap: () {
            setState(() {
              _showControls = !_showControls;
            });
            if (_showControls) {
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() {
                    _showControls = false;
                  });
                }
              });
            }
          },
          child: Container(
            width: finalWidth,
            height: finalHeight,
            color: Colors.black,
            child: Stack(
              children: [
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
                if (_showControls) _buildVideoControls(),
                if (!_showControls && !_controller.value.isPlaying)
                  Center(
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.7, 1.0],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ValueListenableBuilder(
            valueListenable: _videoProgress,
            builder: (context, Duration value, _) {
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
                      value: value.inSeconds.toDouble(),
                      min: 0,
                      max: _controller.value.duration.inSeconds.toDouble(),
                      onChangeStart: (_) => _isUserInteracting = true,
                      onChanged: (newValue) {
                        _videoProgress.value = Duration(seconds: newValue.toInt());
                      },
                      onChangeEnd: (newValue) {
                        _isUserInteracting = false;
                        _controller.seekTo(Duration(seconds: newValue.toInt()));
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
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          _formatDuration(_controller.value.duration),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    widget.isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: widget.onToggleMute,
                ),
              ],
            ),
          ),
        ],
      ),
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
    _controller.setVolume(widget.isMuted ? 0 : 1);

    if (widget.shouldPlay && !_controller.value.isPlaying) {
      _controller.play();
    } else if (!widget.shouldPlay && _controller.value.isPlaying) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _ImageGridState._activeControllers.remove(_controller);
    _controller.dispose();
    super.dispose();
  }
}

