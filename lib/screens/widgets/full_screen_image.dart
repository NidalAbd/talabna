import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImage({Key? key, required this.imageUrls, required this.initialIndex})
      : super(key: key);

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
          itemCount: imageUrls.length,
          controller: PageController(initialPage: initialIndex),
          itemBuilder: (context, index) {
            return Center(
              child: FadeInImage(
                placeholder: const AssetImage('assets/loading.gif',), // Use the local loading gif
                image:CachedNetworkImageProvider(imageUrls[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
