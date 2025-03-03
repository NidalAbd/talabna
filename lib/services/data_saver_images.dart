import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class DataSaverImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool forceLoad;
  final VoidCallback? onTap;
  final Widget? placeholder;
  final Widget? errorWidget;

  const DataSaverImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.forceLoad = false,
    this.onTap,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<DataSaverImage> createState() => _DataSaverImageState();
}

class _DataSaverImageState extends State<DataSaverImage> {
  bool _isLoading = true;
  bool _shouldLoad = false;
  final bool _hasError = false;
  late Future<bool> _dataSaverFuture;

  @override
  void initState() {
    super.initState();
    _dataSaverFuture = _checkDataSaverStatus();
  }

  Future<bool> _checkDataSaverStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isDataSaverEnabled = prefs.getBool('data_saver_enabled') ?? false;

    // Load image if data saver is disabled or if we're forcing a load
    final shouldLoad = !isDataSaverEnabled || widget.forceLoad;

    setState(() {
      _shouldLoad = shouldLoad;
      // If we're not loading the image, then we're not in loading state anymore
      if (!shouldLoad) {
        _isLoading = false;
      }
    });

    return isDataSaverEnabled;
  }

  void _loadFullImage() {
    setState(() {
      _shouldLoad = true;
      _isLoading = true;
    });

    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _dataSaverFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: widget.placeholder ?? const Center(child: CircularProgressIndicator()),
          );
        }

        final bool isDataSaverEnabled = snapshot.data ?? false;

        // If data saver is enabled and we're not forcing a load
        if (isDataSaverEnabled && !_shouldLoad) {
          return GestureDetector(
            onTap: _loadFullImage,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Show a blurred/low-quality version of the image
                  Image.network(
                    widget.imageUrl,
                    width: widget.width,
                    height: widget.height,
                    fit: widget.fit,
                    cacheWidth: 100, // Force low resolution
                    errorBuilder: (context, error, stackTrace) {
                      return widget.placeholder ?? const Center(
                        child: Icon(Icons.image, color: Colors.grey, size: 40),
                      );
                    },
                  ),
                  // Add a blur effect
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Add data saver indicator
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.data_saver_on,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Tap to load image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Normal image loading
        return Image.network(
          widget.imageUrl,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return SizedBox(
              width: widget.width,
              height: widget.height,
              child: Center(
                child: widget.placeholder ?? CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              width: widget.width,
              height: widget.height,
              child: widget.errorWidget ?? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.broken_image, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Extension of the DataSaverImage for lazy loading in lists
class LazyDataSaverImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool isVisible;

  const LazyDataSaverImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.isVisible = false,
  });

  @override
  State<LazyDataSaverImage> createState() => _LazyDataSaverImageState();
}

class _LazyDataSaverImageState extends State<LazyDataSaverImage> {
  bool _shouldLoad = false;

  @override
  void didUpdateWidget(LazyDataSaverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isVisible && widget.isVisible) {
      setState(() {
        _shouldLoad = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible && !_shouldLoad) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
      );
    }

    return DataSaverImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}