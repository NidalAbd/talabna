import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../data/models/service_post.dart';

class ImagePickerButton extends StatefulWidget {
  final Function(List<Photo>?) onImagesPicked;
  final ValueNotifier<List<Photo>?> initialPhotosNotifier;
  final int maxImages;
  final bool deleteApi;

  const ImagePickerButton({
    Key? key,
    required this.onImagesPicked,
    required this.initialPhotosNotifier,
    required this.maxImages,
    required this.deleteApi,
  }) : super(key: key);

  @override
  ImagePickerButtonState createState() => ImagePickerButtonState();
}

class ImagePickerButtonState extends State<ImagePickerButton> {
  List<Photo> _pickedImages = [];
  List<String?> _localMedia = [];


  bool _processing = false;
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    widget.initialPhotosNotifier.addListener(() {
      if (widget.initialPhotosNotifier.value != null) {
        _pickedImages = widget.initialPhotosNotifier.value!
            .map((photo) => Photo.fromJson({
                  'id': photo.id,
                  'src': '${photo.src}',
                }))
            .toList();

        _localMedia =
            List<String?>.filled(_pickedImages.length, null, growable: true);
        setState(() {});
      }
    });
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> imageFiles = await picker.pickMultiImage(imageQuality: 50);

    const int maxImages = 4;

    final totalOperations = imageFiles.length * 2;
    var completedOperations = 0;

    if (_pickedImages.length + imageFiles.length > maxImages) {
      _showMaxImagesDialog(maxImages);
    } else {
      for (XFile file in imageFiles) {
        setState(() {
          _processing = true;
        });
        final String imagePath = file.path;
        final img.Image? compressedImage = await _compressImage(File(imagePath));

        completedOperations++;
        _progressNotifier.value = completedOperations / totalOperations;

        if (compressedImage != null) {
          final String? jpegPath = await _convertToJPEG(compressedImage);

          completedOperations++;
          _progressNotifier.value = completedOperations / totalOperations;

          setState(() {
            _pickedImages.add(Photo(src: jpegPath, isVideo: false));
            _localMedia.add(jpegPath);
          });
          _submitLocalImages();
          if (kDebugMode) {
            print('Image added: $jpegPath');
          }
        }
        setState(() {
          _processing = false;
        });
      }
    }
  }

  List<Photo> getLocalImages() {
    return _pickedImages
        .where((photo) => _localMedia.contains(photo.src))
        .toList();
  }

  Future<void> _showMaxImagesDialog(int maxImages) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('الحد الاعلى من الصور المسموحة'),
          content: Text('يمكنك ان تختار  $maxImages صور.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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

  void _submitLocalImages() {
    final List<Photo> localImages = _pickedImages
        .where((photo) => _localMedia.contains(photo.src))
        .toList();
         widget.onImagesPicked(localImages);
  }

  void _removeImage(int index) async {
    final Photo photo = _pickedImages[index];
    final int? photoUrl = photo.id;

    if (photo.isVideo ?? false) {
      if (index > 0) {
        final String? thumbnailPath = _localMedia[index - 1];
        if (thumbnailPath != null) {
          final File thumbnailFile = File(thumbnailPath);
          if (thumbnailFile.existsSync()) {
            await thumbnailFile.delete();
          }
        }
      }
    }
    final String? localMediaPath = _localMedia[index];
    if (localMediaPath != null) {
      final File localMediaFile = File(localMediaPath);
      if (localMediaFile.existsSync()) {
        await localMediaFile.delete();
      }
    }
    if (widget.deleteApi) {
      if (photoUrl != null) {
        context.read<ServicePostBloc>().add(
          DeleteServicePostImageEvent(servicePostImageId: photoUrl),
        );
      }
    }
    setState(() {
      _pickedImages.removeAt(index);
      if (photo.isVideo ?? false) {
        _localMedia.removeAt(index - 1);
      }
      _localMedia.removeAt(index); // Remove the video or image path
    });

    widget.onImagesPicked(_pickedImages);
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: GridView.builder(
            itemCount: _pickedImages.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, index) {
              if (index == _pickedImages.length) {
                int remainingImageCount =
                    widget.maxImages - _pickedImages.length;
                if (_pickedImages.length < widget.maxImages) {
                  if (kDebugMode) {
                    print(widget.initialPhotosNotifier);
                  }
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: IconButton(
                          onPressed: _pickMedia,
                          icon: Icon(
                            Icons.add_a_photo,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppTheme.accentColor
                                    : AppTheme.primaryColor,
                            size: MediaQuery.of(context).size.width / 5,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 32,
                        left: 37,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor,
                          ),
                          child: Text(
                            remainingImageCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              } else {
                return Stack(
                  alignment: Alignment.center,
                  children: [

                    _processing
                        ? const CircularProgressIndicator()
                        : _pickedImages[index].isVideo ?? false
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image(
                                    image: (_localMedia.isNotEmpty &&
                                        _localMedia[index] != null)
                                        ? FileImage(File(_localMedia[index]!))
                                        : FadeInImage(
                                            placeholder: const AssetImage(
                                                'assets/images/loading.gif'),
                                            image: NetworkImage(
                                                _pickedImages[index].src!),
                                            imageErrorBuilder:
                                                (BuildContext context,
                                                    Object error,
                                                    StackTrace? stackTrace) {
                                              return const Icon(Icons.error);
                                            },
                                            placeholderErrorBuilder:
                                                (BuildContext context,
                                                    Object error,
                                                    StackTrace? stackTrace) {
                                              return const Icon(Icons.error);
                                            },
                                          ).image,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),

                                ],
                              )
                            : Image(
                                image: (_localMedia.isNotEmpty &&
                                    _localMedia[index] != null)
                                    ? FileImage(File(_localMedia[index]!))
                                    : FadeInImage(
                                        placeholder: const AssetImage(
                                            'assets/images/loading.gif'),
                                        image: NetworkImage(
                                            _pickedImages[index].src!),
                                        imageErrorBuilder:
                                            (BuildContext context, Object error,
                                                StackTrace? stackTrace) {
                                          return const Icon(Icons.error);
                                        },
                                        placeholderErrorBuilder:
                                            (BuildContext context, Object error,
                                                StackTrace? stackTrace) {
                                          return const Icon(Icons.error);
                                        },
                                      ).image,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                    Positioned(
                      bottom: -10,
                      left: 15,
                      child: IconButton(
                        onPressed: () => _removeImage(index),
                        icon: const Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _pickMedia() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Choose an image'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Choose a video'),
              onTap: () {
                Navigator.of(context).pop();
                _pickVideo();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    int maxImages = widget.maxImages;
    if (_pickedImages.length + 1 > maxImages) {
      _showMaxImagesDialog(maxImages);
    } else if (pickedFile != null) {
      setState(() {
        _processing = true;
      });
      File file = File(pickedFile.path);

      // Only convert if the file is not in mp4 format
      bool needProcessing = !file.path.toLowerCase().endsWith('.mp4');

      String? videoPath;
      if (needProcessing) {
        videoPath = await convertVideoToMp4(file);
      } else {
        videoPath = file.path;
      }

      if (videoPath != null) {
        String? thumbnailPath = await _generateVideoThumbnail(videoPath);
        setState(() {
          _pickedImages.add(Photo(src: videoPath, isVideo: true));
          if (kDebugMode) {
            print('not null $_pickedImages');
          }
          _localMedia.add(thumbnailPath);
          _localMedia.add(videoPath);
          _thumbnails.add(thumbnailPath!); // Add the thumbnail path to the _thumbnails list
        });
        _submitLocalImages();
        setState(() {
          _processing = false;
        });
        if (kDebugMode) {
          print('Video added: $videoPath');
        }
      }
    }
  }

  final List<String> _thumbnails = [];

  Future<String?> _generateVideoThumbnail(String path) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 150,
      quality: 100,
    );

    final tempDir = await getTemporaryDirectory();
    // Generate a unique filename for each thumbnail
    final filename = '${DateTime.now().millisecondsSinceEpoch}_thumbnail.jpg';
    final file = await File('${tempDir.path}/$filename').writeAsBytes(uint8list!);
    return file.path;
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


}
