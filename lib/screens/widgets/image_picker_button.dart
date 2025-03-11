import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../data/models/photos.dart';
import '../../provider/language.dart';
import '../../utils/constants.dart';

class ImagePickerButton extends StatefulWidget {
  final Function(List<Photo>?) onImagesPicked;
  final ValueNotifier<List<Photo>?> initialPhotosNotifier;
  final int maxImages;
  final bool deleteApi;

  const ImagePickerButton({
    super.key,
    required this.onImagesPicked,
    required this.initialPhotosNotifier,
    required this.maxImages,
    required this.deleteApi,
  });

  @override
  ImagePickerButtonState createState() => ImagePickerButtonState();
}

class ImagePickerButtonState extends State<ImagePickerButton> {
  final Language _language = Language();
  List<Photo> _pickedImages = [];
  List<String?> _localMedia = [];
  final List<String> _thumbnails = [];
  bool _processing = false;
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);

  bool get isProcessing => _processing;

  Future<String?> convertVideoToMp4FromOutside(File file) {
    return convertVideoToMp4(file);
  }

  @override
  void initState() {
    super.initState();
    widget.initialPhotosNotifier.addListener(() {
      if (widget.initialPhotosNotifier.value != null) {
        setState(() {
          _pickedImages = widget.initialPhotosNotifier.value!
              .map((photo) {
            final url = photo.src?.replaceAll('${Constants.apiBaseUrl}/', '');
            return Photo(
              id: photo.id,
              src: url,
              isVideo: photo.isVideo,
            );
          })
              .toList();

          // Initialize _localMedia with null values for API media
          _localMedia = List<String?>.filled(_pickedImages.length, null, growable: true);

          // Generate thumbnails for API videos
          _generateThumbnailsForApiVideos();
        });
      }
    });
  }

  String _getProperUrl(String? src) {
    if (src == null) return '';

    // Check if it's a local file path
    if (src.startsWith('/') || src.startsWith('file://')) {
      return src;
    }

    // Check if it's already a full URL
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return src;
    }

    // Otherwise, construct the full URL
    return '${Constants.apiBaseUrl}/$src';
  }

  // Enhanced permission handling for different Android & iOS versions
  Future<bool> _requestPermissions(bool isVideo) async {
    Map<Permission, PermissionStatus> statuses = {};

    if (Platform.isAndroid) {
      // For Android 13+ (SDK 33+)
      if (isVideo) {
        statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.storage,
        ].request();
      } else {
        statuses = await [
          Permission.photos,
          Permission.storage,
        ].request();
      }

      // Check if any permission is permanently denied
      if (statuses.values.any((status) => status.isPermanentlyDenied)) {
        await _showPermissionPermanentlyDeniedDialog();
        return false;
      }

      // Check if any required permission is denied
      return !statuses.values.any((status) => status.isDenied);
    }
    else if (Platform.isIOS) {
      // For iOS, request photo library permission
      PermissionStatus photoStatus;

      if (isVideo) {
        statuses = await [
          Permission.photos,
          Permission.videos
        ].request();

        return !statuses.values.any((status) => status.isDenied);
      } else {
        photoStatus = await Permission.photos.request();
        return photoStatus.isGranted;
      }
    }

    return true; // Default for other platforms
  }

  // Show permission denied dialog
  Future<void> _showPermissionDeniedDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_language.tPermissionDeniedText()),
          content: Text(_language.tStoragePermissionExplanationText()),
          actions: <Widget>[
            TextButton(
              child: Text(_language.tCancelText()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(_language.tOpenSettingsText()),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  // Show permanently denied permission dialog
  Future<void> _showPermissionPermanentlyDeniedDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_language.tPermissionPermanentlyDeniedText()),
          content: Text(_language.tPermanentStoragePermissionExplanationText()),
          actions: <Widget>[
            TextButton(
              child: Text(_language.tCancelText()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(_language.tOpenSettingsText()),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImages() async {
    // Request permissions specifically for photos
    bool hasPermission = await _requestPermissions(false);
    if (!hasPermission) {
      await _showPermissionDeniedDialog();
      return;
    }

    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> imageFiles = await picker.pickMultiImage(imageQuality: 50);

      if (imageFiles.isEmpty) {
        // User cancelled selection
        return;
      }

      if (_pickedImages.length + imageFiles.length > widget.maxImages) {
        _showMaxImagesSnackBar(widget.maxImages);
        return;
      }

      setState(() {
        _processing = true;
      });

      List<Photo> newImages = [];
      List<String?> newLocalPaths = [];

      for (XFile file in imageFiles) {
        final String imagePath = file.path;
        final img.Image? compressedImage = await _compressImage(File(imagePath));

        if (compressedImage != null) {
          final String? jpegPath = await _convertToJPEG(compressedImage);
          if (jpegPath != null) {
            newImages.add(Photo(
              src: jpegPath,
              isVideo: false,
            ));
            newLocalPaths.add(jpegPath);
          }
        }
      }

      setState(() {
        _pickedImages.addAll(newImages);
        _localMedia.addAll(newLocalPaths);
      });

      _submitLocalImages();
    } catch (e) {
      print('Error processing images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing images: $e')),
      );
    } finally {
      setState(() {
        _processing = false;
      });
    }
  }

  Future<void> _pickVideo() async {
    // Request permissions specifically for videos
    bool hasPermission = await _requestPermissions(true);
    if (!hasPermission) {
      await _showPermissionDeniedDialog();
      return;
    }

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile == null) {
        // User cancelled selection
        return;
      }

      if (_pickedImages.length + 1 > widget.maxImages) {
        _showMaxImagesSnackBar(widget.maxImages);
        return;
      }

      setState(() {
        _processing = true;
        _progressNotifier.value = 0.1; // Start progress
      });

      File file = File(pickedFile.path);
      String videoPath = file.path;
      print('Original video path: $videoPath');

      setState(() {
        _progressNotifier.value = 0.3; // Update progress
      });

      if (!file.path.toLowerCase().endsWith('.mp4')) {
        final convertedPath = await convertVideoToMp4(file);
        if (convertedPath != null) {
          videoPath = convertedPath;
          print('Converted video path: $videoPath');
        } else {
          throw Exception('Failed to convert video');
        }
      }

      setState(() {
        _progressNotifier.value = 0.7; // Update progress
      });

      final thumbnailPath = await _generateVideoThumbnail(videoPath);
      if (thumbnailPath == null) {
        throw Exception('Failed to generate thumbnail');
      }

      // Explicitly set isVideo to true
      final videoPhoto = Photo(
        src: videoPath,
        isVideo: true,
      );

      print('Adding video: ${videoPhoto.src}, isVideo: ${videoPhoto.isVideo}');

      setState(() {
        _pickedImages.add(videoPhoto);
        _localMedia.add(thumbnailPath);
        _thumbnails.add(thumbnailPath);
        _progressNotifier.value = 1.0; // Complete progress
      });

      _submitLocalImages();
    } catch (e) {
      print('Error processing video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing video: $e')),
      );
    } finally {
      setState(() {
        _processing = false;
      });
    }
  }

  void _submitLocalImages() {
    final List<Photo> updatedImages = [];

    for (int i = 0; i < _pickedImages.length; i++) {
      final photo = _pickedImages[i];
      if (photo.id != null) {
        // API media
        updatedImages.add(photo);
      } else {
        // Local media - use the source path directly
        updatedImages.add(Photo(
          src: photo.src,
          isVideo: photo.isVideo,
        ));
      }
    }

    widget.onImagesPicked(updatedImages);
  }

  void _removeImage(int index) async {
    final Photo photo = _pickedImages[index];
    final String? localPath = _localMedia[index];

    if (localPath != null) {
      // Handle local file deletion
      if (photo.isVideo ?? false) {
        // Delete thumbnail
        final File thumbnailFile = File(localPath);
        if (thumbnailFile.existsSync()) {
          await thumbnailFile.delete();
        }
        // Delete video file
        final File videoFile = File(photo.src ?? '');
        if (videoFile.existsSync()) {
          await videoFile.delete();
        }
        _thumbnails.remove(localPath);
      } else {
        // Delete local image
        final File localFile = File(localPath);
        if (localFile.existsSync()) {
          await localFile.delete();
        }
      }
    } else if (widget.deleteApi && photo.id != null) {
      // Handle API deletion
      context.read<ServicePostBloc>().add(
        DeleteServicePostImageEvent(servicePostImageId: photo.id!),
      );
    }

    setState(() {
      _pickedImages.removeAt(index);
      _localMedia.removeAt(index);
    });

    // Submit updated list
    _submitLocalImages();
  }

  List<Photo> getLocalImages() {
    // Return all images, both from API and locally added
    print('Retrieving local images: ${_pickedImages.length}');
    for (int i = 0; i < _pickedImages.length; i++) {
      final photo = _pickedImages[i];
      final isLocal = photo.id == null && photo.src != null;
      final isVideo = photo.isVideo ?? false;

      // Use Dart's min function from dart:math
      final displaySrc = photo.src != null
          ? '${photo.src!.substring(0, math.min(20, photo.src!.length))}...'
          : 'null';

      print('Image $i: id=${photo.id}, isLocal=$isLocal, isVideo=$isVideo, src=$displaySrc');
    }
    return _pickedImages;
  }

  Future<img.Image?> _compressImage(File file) async {
    final img.Image? originalImage = img.decodeImage(await file.readAsBytes());
    if (originalImage != null) {
      const int maxSize = 1024 * 1024; // 1 MB
      final int originalSize = await file.length();
      if (originalSize > maxSize) {
        final img.Image compressedImage =
        img.copyResize(originalImage, width: 1920);
        final double compressionRatio = maxSize / originalSize;
        final List<int> compressedImageData = img.encodeJpg(
          compressedImage,
          quality: (compressionRatio * 100).toInt(),
        );
        await _saveImageToFile(
          compressedImageData,
          '${file.path}_compressed.jpg',
        );
        return compressedImage;
      } else {
        return originalImage;
      }
    }
    return null;
  }

  Future<String?> _convertToJPEG(img.Image image) async {
    final List<int> jpegData = img.encodeJpg(image);
    final String jpegPath = await _saveImageToFile(
      jpegData,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    return jpegPath;
  }

  Future<String> _saveImageToFile(List<int> imageData, String filePath) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    final File imageFile = File('$tempPath/$filePath');
    await imageFile.writeAsBytes(imageData);
    return imageFile.path;
  }

  Future<void> _showMaxImagesSnackBar(int maxImages) async {
    final snackBar = SnackBar(
      content: Text(_language.tMaxImagesLimitText(maxImages)),
      action: SnackBarAction(
        label: _language.tOkText(),
        onPressed: () {},
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_pickedImages.isNotEmpty)
                Container(
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _pickedImages.length,
                    itemBuilder: (context, index) {
                      final photo = _pickedImages[index];
                      final localPath = _localMedia[index];

                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _processing
                                  ? const Center(child: CircularProgressIndicator())
                                  : _buildMediaPreview(photo, localPath),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  iconSize: 18,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () => _removeImage(index),
                                ),
                              ),
                            ),
                            if (photo.isVideo ?? false)
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.videocam,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              if (_pickedImages.length < widget.maxImages)
                InkWell(
                  onTap: _pickMedia,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _language.tAddMediaText(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _language.tRemainingImagesText(widget.maxImages - _pickedImages.length),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_processing)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      ValueListenableBuilder<double>(
                          valueListenable: _progressNotifier,
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            );
                          }
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _language.tProcessingMediaText(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _pickMedia() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _language.tAddMediaText(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  title: Text(_language.tChoosePhotosText()),
                  subtitle: Text(_language.tSelectFromGalleryText()),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImages();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.videocam_outlined,
                      color: Colors.purple,
                    ),
                  ),
                  title: Text(_language.tChooseVideoText()),
                  subtitle: Text(_language.tSelectFromGalleryText()),
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideo();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaPreview(Photo photo, String? localPath) {
    final bool isVideo = photo.isVideo ?? false;
    final bool isLocalFile = photo.src?.startsWith('/') ?? false;
    final bool isApiFile = photo.id != null;

    if (isVideo) {
      Widget thumbnailWidget;
      if (localPath != null) {
        // For both API and local videos, use the thumbnail
        thumbnailWidget = Image.file(
          File(localPath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading video thumbnail: $error');
            return Container(
              color: Colors.grey[200],
              child: const Icon(Icons.video_library, size: 40),
            );
          },
        );
      } else {
        thumbnailWidget = Container(
          color: Colors.grey[200],
          child: const Icon(Icons.video_library, size: 40),
        );
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          thumbnailWidget,
          const Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      );
    }

    // For local images
    if (isLocalFile) {
      return Image.file(
        File(photo.src!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading local image: $error');
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          );
        },
      );
    }

    // For API images
    if (isApiFile) {
      final String url = _getProperUrl(photo.src);
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print('Error loading API image: $error');
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          );
        },
      );
    }

    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.error),
    );
  }

  Future<String?> _generateVideoThumbnail(String path) async {
    try {
      print('Starting thumbnail generation for: $path');  // Debug print

      final uint8list = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 150,
        quality: 100,
      );

      if (uint8list == null) {
        print('Thumbnail generation returned null data');  // Debug print
        return null;
      }

      final tempDir = await getTemporaryDirectory();
      final filename = 'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$filename';

      final file = await File(filePath).writeAsBytes(uint8list);
      print('Thumbnail saved to: ${file.path}');  // Debug print

      return file.path;
    } catch (e) {
      print('Error in thumbnail generation: $e');  // Debug print
      return null;
    }
  }

  Future<String?> convertVideoToMp4(File file) async {
    final outputPath = '${file.path.split('.').first}.mp4';
    final session = await FFmpegKit.executeAsync('-i ${file.path} -c:v copy -c:a copy $outputPath');
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      if (kDebugMode) {
        print("Video converted successfully: $outputPath");
      }
      return outputPath;
    } else {
      if (kDebugMode) {
        print("Video conversion failed");
      }
      return null;
    }
  }

  // Generate thumbnails for API videos
  Future<void> _generateThumbnailsForApiVideos() async {
    for (int i = 0; i < _pickedImages.length; i++) {
      final photo = _pickedImages[i];
      if (photo.isVideo ?? false) {
        final String videoUrl = _getProperUrl(photo.src);
        try {
          final thumbnail = await VideoThumbnail.thumbnailData(
            video: videoUrl,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 150,
            quality: 100,
          );

          if (thumbnail != null) {
            final tempDir = await getTemporaryDirectory();
            final filename = 'thumb_api_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
            final filePath = '${tempDir.path}/$filename';
            await File(filePath).writeAsBytes(thumbnail);

            setState(() {
              _localMedia[i] = filePath;
            });
          }
        } catch (e) {
          print('Error generating thumbnail for API video: $e');
        }
      }
    }
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;

  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 5;
    double distance = 0;

    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    Path dashPath = Path();

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}