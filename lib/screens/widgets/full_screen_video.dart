import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../data/models/photos.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<Photo> images;
  final List<String?> localImages;
  final int initialIndex;
  final bool deleteApi;

  const FullScreenImageViewer({super.key,
    required this.images,
    required this.localImages,
    required this.initialIndex,
    required this.deleteApi,
  });

  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Implement your delete functionality here
            },
          ),
        ],
      ),
      body: Container(
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            String? localImage = widget.localImages[index];
            bool isLocal = localImage != null;
            String image = isLocal ? localImage : widget.images[index].src!;
            bool isVideo = widget.images[index].isVideo != null && widget.images[index].isVideo!;
            return PhotoViewGalleryPageOptions(
              imageProvider: isLocal ? FileImage(File(image)) : NetworkImage(image) as ImageProvider,
              initialScale: PhotoViewComputedScale.contained * 1,
              heroAttributes: PhotoViewHeroAttributes(tag: index),
            );
          },
          itemCount: widget.images.length,
          loadingBuilder: (context, progress) => Center(
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(value: progress == null ? null : progress.cumulativeBytesLoaded / progress.expectedTotalBytes!),
            ),
          ),
          backgroundDecoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
          ),
          pageController: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
