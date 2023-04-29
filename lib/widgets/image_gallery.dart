import 'package:flutter/material.dart';

class ImageGallery extends StatefulWidget {
  final List<String> imageUrls;

  const ImageGallery({Key? key, required this.imageUrls}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  void _handlePageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _handleDoubleTap() {
    setState(() {
      if (_pageController.position.pixels ==
          _pageController.position.minScrollExtent) {
        _pageController.animateToPage(
          _currentPageIndex + 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else if (_pageController.position.pixels ==
          _pageController.position.maxScrollExtent) {
        _pageController.animateToPage(
          _currentPageIndex - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        if (_pageController.page! - _currentPageIndex < 0) {
          _pageController.animateToPage(
            _currentPageIndex - 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        } else {
          _pageController.animateToPage(
            _currentPageIndex + 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      }
    });
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _pageController.animateToPage(
      _currentPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GestureDetector(
        onDoubleTap: _handleDoubleTap,
        onScaleStart: _handleScaleStart,
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: _handlePageChanged,
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                widget.imageUrls[index],
                height: 200,
                width: 300,
              ),
            );
          },
        ),
      ),
    );
  }
}
