import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/screens/reel/reels_screen.dart';
import 'package:video_player/video_player.dart';
import 'full_screen_image.dart';

class ImageGrid extends StatefulWidget {
  final List<String> imageUrls;
  final bool canClick;
  final Function(String)? onImageTap;
  final int userId;
  final ServicePost servicePost;

  const ImageGrid({Key? key, required this.imageUrls, this.onImageTap, required this.canClick, required this.userId,required this.servicePost})
      : super(key: key);

  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  void _navigateToFullScreenImage(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(
          mediaUrls: widget.imageUrls,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(); // Return an empty container if there are no images
    }

    int crossAxisCount = 2;

    if (widget.imageUrls.length == 1) {
      crossAxisCount = 1;
    } else if (widget.imageUrls.length == 2) {
      crossAxisCount = 2;
    } else if (widget.imageUrls.length == 3) {
      crossAxisCount = 2;
    } else if (widget.imageUrls.length == 4) {
      crossAxisCount = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.imageUrls.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        final url = widget.imageUrls[index];
        return GestureDetector(
          onTap: () {
            widget.canClick ? _navigateToFullScreenImage(context, index) : null;
          },
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: url.endsWith('.mp4') ? VideoItem(url: url, userId: widget.userId, servicePost: widget.servicePost,) : _buildImageWidget(url),
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(String url) {
    return FadeInImage(
      placeholder: const AssetImage('assets/loading.gif'),
      image: CachedNetworkImageProvider(url),
      fit: BoxFit.cover,
    );
  }
}

class VideoItem extends StatefulWidget {
  final String url;
  final int userId;
  final ServicePost servicePost;

  const VideoItem({super.key, required this.url, required this.userId, required this.servicePost});

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool isPlaying = false;

  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _toggleVideoPlayback() {
    setState(() {
      if (isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      isPlaying = !isPlaying;
    });
  }
  @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReelsHomeScreen(
                    userId: widget.userId,  // Replace with your user id
                    servicePost: widget.servicePost,
                  ),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.white,
                      bufferedColor: Colors.white54,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
