import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ImageGrid extends StatefulWidget {
  final List<String> imageUrls;
  final Function(String)? onImageTap;

  const ImageGrid({Key? key, required this.imageUrls, this.onImageTap})
      : super(key: key);

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width * (4 / 3),
      child: PageView.builder(
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
    );
  }

  Widget _buildImageWidget(String url) {
    return Image.network(
      url,
      fit: BoxFit.fitHeight,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class VideoItem extends StatefulWidget {
  final String url;
  // Add the shouldPlay parameter
  final bool shouldPlay;

  // Update the constructor to include the shouldPlay parameter
  const VideoItem({Key? key, required this.url, this.shouldPlay = false}) : super(key: key);

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.setLooping(true);
    // Auto-play based on the shouldPlay parameter is handled in didUpdateWidget
  }

  @override
  void didUpdateWidget(VideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Control play/pause based on the shouldPlay parameter
    if (widget.shouldPlay) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.url),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction > 0.5) {
          if (!_controller.value.isPlaying) {
            _controller.play();
          }
        } else {
          if (_controller.value.isPlaying) {
            _controller.pause();
          }
        }
      },
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
