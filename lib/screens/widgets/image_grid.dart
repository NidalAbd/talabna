import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'full_screen_image.dart';

class ImageGrid extends StatefulWidget {
  final List<String> imageUrls;
  final bool canClick;
  final Function(String)? onImageTap;

  const ImageGrid({Key? key, required this.imageUrls, this.onImageTap, required this.canClick})
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
        aspectRatio: 9 / 16,
        child: BetterPlayer(
          controller: betterPlayerController,
        ),
      );
    }else if (url.endsWith('.mp3')) {
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
            child: _buildMediaWidget(url),
          ),
        );
      },
    );
  }
}
