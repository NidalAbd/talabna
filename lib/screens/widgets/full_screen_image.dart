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
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Initialize with the initial index
    _pageController = PageController(initialPage: widget.initialIndex);
    _pageController.addListener(() {
      // Check if page index has changed
      if (_pageController.page!.round() != _currentIndex) {
        setState(() {
          _currentIndex = _pageController.page!.round();
        });
      }
    });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("${_currentIndex + 1} / ${widget.mediaUrls.length}", style: TextStyle(color: Colors.white)),
      ),
      body: PageView.builder(
        itemCount: widget.mediaUrls.length,
        controller: PageController(
          initialPage: widget.initialIndex,
          viewportFraction: 0.5, // Set viewport fraction less than 1
        ),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final url = widget.mediaUrls[index];
          return InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: Center(
              child: _buildMediaWidget(url),
            ),
          );
        },
      ),
    );
  }

}
