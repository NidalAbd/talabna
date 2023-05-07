import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'full_screen_image.dart';

class ImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final bool canClick;
  final Function(String)? onImageTap;

  const ImageGrid({Key? key, required this.imageUrls, this.onImageTap, required this.canClick})
      : super(key: key);
  void _navigateToFullScreenImage(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(
          imageUrls: imageUrls,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Container(); // Return an empty container if there are no images
    }

    int crossAxisCount = 2;

    if (imageUrls.length == 1) {
      crossAxisCount = 1;
    } else if (imageUrls.length == 2) {
      crossAxisCount = 2;
    } else if (imageUrls.length == 3) {
      crossAxisCount = 2;
    } else if (imageUrls.length == 4) {
      crossAxisCount = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imageUrls.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            canClick? _navigateToFullScreenImage(context, index) : null;
          },
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: FadeInImage(
              placeholder: const AssetImage('assets/loading.gif',), // Use the local loading gif
              image: CachedNetworkImageProvider(imageUrls[index]),
              fit: BoxFit.cover,
            ),
          ),
        );

      },
    );
  }
}
