import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talbna/data/models/service_post.dart';

class ImagePickerButton extends StatefulWidget {
  final void Function(List<Photo>?) onImagesPicked;
  final ValueNotifier<List<Photo>?> initialPhotosNotifier;

  const ImagePickerButton({Key? key, required this.onImagesPicked, required this.initialPhotosNotifier})
      : super(key: key);
  @override
  ImagePickerButtonState createState() => ImagePickerButtonState();
}

class ImagePickerButtonState extends State<ImagePickerButton> {
  List<Photo> _pickedImages = [];
  List<String?> _localImages = [];

  @override
  void initState() {
    super.initState();

    widget.initialPhotosNotifier.addListener(() {
      if (widget.initialPhotosNotifier.value != null) {
        _pickedImages = widget.initialPhotosNotifier.value!
            .map((photo) => Photo.fromJson({
          'id': photo.id,
          'src': '${Constants.apiBaseUrl}/storage/${photo.src}',
        }))
            .toList();
        _localImages = List<String?>.filled(
            _pickedImages.length, null,
            growable: true);
        setState(() {});
      }
    });
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> imageFiles =
    await picker.pickMultiImage(imageQuality: 50);

    const int maxImages = 4;
    if (_pickedImages.length + imageFiles.length > maxImages) {
      _showMaxImagesDialog(maxImages);
    } else {
      _showProgressDialog(imageFiles.length);
      for (XFile file in imageFiles) {
        final String imagePath = file.path;
        final img.Image? compressedImage =
        await _compressImage(File(imagePath));
        if (compressedImage != null) {
          final String jpegPath = await _convertToJPEG(compressedImage);
          setState(() {
            _pickedImages.add(Photo.fromJson({'src': jpegPath}));
            _localImages.add(jpegPath);
          });
          _submitLocalImages(); // call the new method here
          if (kDebugMode) {
            print('Image added: $jpegPath');
          }
        }
      }
      Navigator.of(context).pop(); // Close the progress dialog
    }
  }
  List<Photo> getLocalImages() {
    return _pickedImages
        .where((photo) => _localImages.contains(photo.src))
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

  Future<void> _showProgressDialog(int numImages) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text('جاري معالجة الصور... 0/$numImages'),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<img.Image?> _compressImage(File file) async {
    final img.Image? originalImage = img.decodeImage(await file.readAsBytes());
    if (originalImage != null) {
      const int maxSize = 1024 * 1024; // 1 MB
      final int originalSize = file.lengthSync();
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

  Future<String> _convertToJPEG(img.Image image) async {
    final List<int> jpegData = img.encodeJpg(image);
    final String jpegPath = await _saveImageToFile(
        jpegData, '${DateTime.now().millisecondsSinceEpoch}.jpg');
    if (kDebugMode) {
    }
    return jpegPath;
  }

  Future<String> _saveImageToFile(
      List<int> imageData, String filePath) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    final File imageFile = File('$tempPath/$filePath');
    await imageFile.writeAsBytes(imageData);
    return imageFile.path;
  }
  void _submitLocalImages() {
    final List<Photo> localImages = _pickedImages
        .where((photo) => _localImages.contains(photo.src))
        .toList();
    widget.onImagesPicked(localImages);
  }

  void _removeImage(int index) async {
    final Photo photo = _pickedImages[index];
    final int? photoUrl = photo.id;
    context.read<ServicePostBloc>().add(
        DeleteServicePostImageEvent(servicePostImageId: photoUrl!));
          setState(() {
            _pickedImages.removeAt(index);
            _localImages.removeAt(index);
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
                if (_pickedImages.length < 4) {
                  return IconButton(
                    onPressed: _pickImages,
                    icon: Icon(Icons.camera_alt,
                        size: MediaQuery.of(context).size.width / 5),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              } else {
                return Stack(
                  children: [
                    Image(
                      image: (_localImages.isNotEmpty && _localImages[index] != null)
                          ? FileImage(File(_localImages[index]!))
                          : FadeInImage(
                        placeholder: const AssetImage('assets/images/loading.gif'),
                        image: NetworkImage(_pickedImages[index].src!),
                        imageErrorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return const Icon(Icons.error);
                        },
                        placeholderErrorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
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
}

