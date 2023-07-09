import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;

  const FullScreenImage({Key? key, required this.mediaUrls, required this.initialIndex})
      : super(key: key);

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Widget _buildMediaWidget(String url) {
    if (url.endsWith('.mp4')) {
      final betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
      );
      final betterPlayerController = BetterPlayerController(
        const BetterPlayerConfiguration(
          autoPlay: true,
          looping: true,
          aspectRatio: 9 / 16,
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterPlayer(
          controller: betterPlayerController,
        ),
      );
    } else if (url.endsWith('.mp3')) {
      return GestureDetector(
        onTap: () {
          // Handle audio file tap here if needed
        },
        child: const Icon(Icons.audiotrack),
      );
    } else {
      return FadeInImage(
        placeholder: const AssetImage('assets/loading.gif'),
        image: CachedNetworkImageProvider(url),
        fit: BoxFit.cover,
      );
    }
  }



  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 4,
        child: PageView.builder(
          itemCount: widget.mediaUrls.length,
          controller: _pageController,
          itemBuilder: (context, index) {
            final url = widget.mediaUrls[index];
            return Center(
              child: _buildMediaWidget(url),
            );
          },
        ),
      ),
    );
  }
}
