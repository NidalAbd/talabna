import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class VideoPickerButton extends StatefulWidget {
  final Function(List<Photo>?) onImagesPicked;
  final ValueNotifier<List<Photo>?> initialPhotosNotifier;
  final int maxImages;
  final bool deleteApi;

  const VideoPickerButton({
    Key? key,
    required this.onImagesPicked,
    required this.initialPhotosNotifier,
    required this.maxImages,
    required this.deleteApi,
  }) : super(key: key);

  @override
  VideoPickerButtonState createState() => VideoPickerButtonState();
}

class VideoPickerButtonState extends State<VideoPickerButton> {
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
        _localImages = List<String?>.filled(_pickedImages.length, null, growable: true);
        setState(() {});
      }
    });
  }

  Future<void> _pickVideos() async {
    final ImagePicker picker = ImagePicker();
    final XFile? videoFile = await picker.pickVideo(source: ImageSource.gallery);

    if (videoFile != null) {
      final String videoPath = videoFile.path;
      final String? compressedVideoPath = await _compressAndConvertToMP4(videoPath);
      if (compressedVideoPath != null) {
        setState(() {
          final Photo pickedVideo = Photo.fromJson({'src': compressedVideoPath});
          _pickedImages.add(pickedVideo);
          _localImages.add(compressedVideoPath);
        });
        _submitLocalImages();
        if (kDebugMode) {
          print('Video added: $compressedVideoPath');
        }
      }
    }
  }




  Future<String?> _compressAndConvertToMP4(String videoPath) async {
    final VideoPlayerController controller = VideoPlayerController.file(File(videoPath));
    await controller.initialize();

    final Duration videoDuration = controller.value.duration;
    const Duration limitDuration = Duration(seconds: 30);
    final Duration trimmedDuration = videoDuration < limitDuration ? videoDuration : limitDuration;

    final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false,
      includeAudio: true,
      startTime: 0,
    );

    if (mediaInfo != null && mediaInfo.path != null) {
      final compressedVideoPath = mediaInfo.path!;
      return compressedVideoPath;
    } else {
      // Handle the case when compression fails
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Video Compression Error'),
            content: const Text('Failed to compress and convert the video.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return null;
    }
  }

  List<Photo> getLocalImages() {
    return _pickedImages.where((photo) => _localImages.contains(photo.src)).toList();
  }

  List<Photo> getApiImages() {
    return _pickedImages.where((photo) => !_localImages.contains(photo.src)).toList();
  }

  void _submitLocalImages() {
    if (_localImages.length == widget.maxImages) {
      final List<Photo> localImages = getLocalImages();
      widget.onImagesPicked(localImages);
    }
  }

  void _submitApiImages() {
    final List<Photo> apiImages = getApiImages();
    widget.onImagesPicked(apiImages);
  }

  void _removeLocalImage(int index) {
    setState(() {
      final String? localImage = _localImages[index];
      if (widget.deleteApi) {
        final List<Photo> apiImages = getApiImages();
        final int apiImageIndex = _pickedImages.indexOf(apiImages.firstWhere((photo) => photo.src == localImage));
        _pickedImages.removeAt(apiImageIndex);
      }
      _pickedImages.removeAt(index);
      _localImages.removeAt(index);
    });
    _submitLocalImages();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Images',
            style: TextStyle(fontSize: 16),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _pickedImages.length + 1,
          itemBuilder: (context, index) {
            if (index == _pickedImages.length) {
              return IconButton(
                onPressed: _pickVideos,
                icon: Icon(
                  Icons.video_call_rounded,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.accentColor
                      : AppTheme.primaryColor,
                  size: MediaQuery.of(context).size.width / 5,
                ),
              );
            } else {
              final Photo photo = _pickedImages[index];
              return Stack(
                children: [
                  Image.network(
                    photo.src!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return Image.asset(
                        'assets/talabnaLogo512.png', // Replace with the path to your default thumbnail image
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  ),
                  if (_localImages.contains(photo.src))
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        onPressed: () => _removeLocalImage(index),
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}
