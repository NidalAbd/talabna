import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ImageGrid extends StatefulWidget {
  final List<String> imageUrls;
  final Function(String)? onImageTap;

  const ImageGrid({
    Key? key,
    required this.imageUrls,
    this.onImageTap,
  }) : super(key: key);

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
      height: MediaQuery.of(context).size.width * (4 / 3), // Aspect ratio of 16:9
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
            child: url.endsWith('.mp4') ? VideoItem(url: url) : _buildImageWidget(url),
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(String url) {
    return Image.network(
      url,
      fit: BoxFit.fitHeight, // This will ensure the image is fully visible, but could leave space on the sides
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

  const VideoItem({Key? key, required this.url}) : super(key: key);

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;
  bool _isPlaying = false; // To keep track of playing state

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {
          _controller.play(); // Play the video as soon as it's initialized
          _isPlaying = true;
        });
      });
    _controller.setLooping(true); // Loop the video
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.isInitialized) {
      return GestureDetector(
        onTap: _togglePlayPause, // Toggle play/pause on tap
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
