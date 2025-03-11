import 'package:flutter/material.dart';
import 'package:talbna/data/models/photos.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

class ReelMediaController extends StatefulWidget {
  final ServicePost post;
  final Function(VideoPlayerController?) onControllerInitialized;
  final Function() onMediaTap;
  final bool autoPlay;

  const ReelMediaController({
    super.key,
    required this.post,
    required this.onControllerInitialized,
    required this.onMediaTap,
    this.autoPlay = true,
  });

  @override
  State<ReelMediaController> createState() => _ReelMediaControllerState();
}

class _ReelMediaControllerState extends State<ReelMediaController> {
  int _currentMediaIndex = 0;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;
  bool _showControls = false;

  final PageController _mediaPageController = PageController();

  @override
  void initState() {
    super.initState();
    _initMediaController();
  }

  void _initMediaController() {
    if (widget.post.photos == null || widget.post.photos!.isEmpty) {
      return;
    }

    final media = widget.post.photos![_currentMediaIndex];
    if (media.isVideo == true && media.src != null) {
      _initVideoController(media);
    }
  }

  void _initVideoController(Photo media) {
    final videoUrl = media.src!.startsWith('http')
        ? media.src!
        : '${Constants.apiBaseUrl}/${media.src!}';

    _videoController = VideoPlayerController.network(videoUrl);

    _videoController!.initialize().then((_) {
      if (!mounted) return;

      setState(() {
        _isVideoInitialized = true;
      });

      if (widget.autoPlay) {
        _videoController!.play();
        setState(() {
          _isPlaying = true;
        });
      }

      _videoController!.setLooping(true);
      widget.onControllerInitialized(_videoController);
    });

    // Auto-hide controls after a few seconds
    _videoController!.addListener(() {
      if (_showControls) {
        Future.delayed(Duration(seconds: 3), () {
          if (mounted && _showControls) {
            setState(() {
              _showControls = false;
            });
          }
        });
      }
    });
  }

  void _onChangeMedia(int index) {
    // Dispose previous controller if it exists
    if (_videoController != null) {
      _videoController!.pause();
      _videoController!.dispose();
      _videoController = null;
      _isVideoInitialized = false;
      widget.onControllerInitialized(null);
    }

    setState(() {
      _currentMediaIndex = index;
    });

    // Initialize new controller if needed
    if (widget.post.photos != null &&
        widget.post.photos!.length > index &&
        widget.post.photos![index].isVideo == true) {
      _initVideoController(widget.post.photos![index]);
    }
  }

  void _togglePlayPause() {
    if (_videoController == null || !_isVideoInitialized) return;

    setState(() {
      _isPlaying = !_isPlaying;
      _showControls = true;
    });

    if (_isPlaying) {
      _videoController!.play();
    } else {
      _videoController!.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no media, show placeholder
    if (widget.post.photos == null || widget.post.photos!.isEmpty) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported, color: Colors.white70, size: 64),
              const SizedBox(height: 16),
              Text(
                'No media available',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // If only one media item
    if (widget.post.photos!.length == 1) {
      final media = widget.post.photos!.first;
      return _buildSingleMediaItem(media);
    }

    // For multiple media items
    return Stack(
      children: [
        // Media carousel
        PageView.builder(
          controller: _mediaPageController,
          itemCount: widget.post.photos!.length,
          onPageChanged: _onChangeMedia,
          itemBuilder: (context, index) {
            final media = widget.post.photos![index];
            if (index == _currentMediaIndex) {
              return _buildSingleMediaItem(media);
            } else {
              // Placeholder for other pages
              return media.isVideo == true
                  ? Center(child: CircularProgressIndicator())
                  : _buildImageDisplay(media);
            }
          },
        ),

        // Media indicators
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.post.photos!.length,
                  (index) => Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(
                    index == _currentMediaIndex ? 0.9 : 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleMediaItem(Photo media) {
    if (media.isVideo == true) {
      return _buildVideoPlayer(media);
    } else {
      return _buildImageDisplay(media);
    }
  }

  Widget _buildVideoPlayer(Photo media) {
    if (media.src == null) {
      return Center(child: Text('Invalid video', style: TextStyle(color: Colors.white)));
    }

    if (!_isVideoInitialized || _videoController == null) {
      return Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
        widget.onMediaTap();
        _togglePlayPause();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
          ),

          // Play/pause controls
          if (_showControls)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(12),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),

          // Progress bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Colors.white,
                bufferedColor: Colors.white.withOpacity(0.5),
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay(Photo media) {
    if (media.src == null) {
      return Center(child: Text('Invalid image', style: TextStyle(color: Colors.white)));
    }

    String imageUrl = media.src!.startsWith('http')
        ? media.src!
        : '${Constants.apiBaseUrl}/${media.src!}';

    return GestureDetector(
      onTap: widget.onMediaTap,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        errorWidget: (context, url, error) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image, color: Colors.white, size: 48),
              SizedBox(height: 8),
              Text(
                'Image could not be loaded',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mediaPageController.dispose();
    if (_videoController != null) {
      _videoController!.dispose();
    }
    super.dispose();
  }
}