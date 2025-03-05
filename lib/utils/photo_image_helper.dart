import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:talbna/data/models/photos.dart';
import 'constants.dart';

/// A utility class for handling profile image URLs and creating profile image widgets
class ProfileImageHelper {
  /// Gets the appropriate profile image URL based on the photo
  ///
  /// [photo] The Photo object
  /// [baseApiUrl] Optional base URL for internal images (defaults to Constants.apiBaseUrl)
  /// [placeholderUrl] Optional placeholder image URL
  static String getProfileImageUrl(
      Photo? photo, {
        String? baseApiUrl,
        String placeholderUrl = 'https://via.placeholder.com/150',
      }) {
    // If photo is null or src is empty, return placeholder
    if (photo?.src == null || photo!.src!.isEmpty) {
      return placeholderUrl;
    }

    // If photo is marked as external, use src directly
    if (photo.isExternal == true) {
      return photo.src!;
    }

    // For internal images, prepend the base API URL
    return '${baseApiUrl ?? Constants.apiBaseUrl}/storage/${photo.src}';
  }

  /// Creates a customizable profile image widget
  ///
  /// [photo] The Photo object
  /// [width] Optional width of the image
  /// [height] Optional height of the image
  /// [fit] BoxFit for the image (defaults to BoxFit.cover)
  /// [blur] Optional blur effect (set to true to apply blur)
  /// [blurSigma] Blur intensity (defaults to 10)
  /// [overlay] Optional color overlay
  static Widget buildProfileImage({
    required Photo? photo,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    bool blur = false,
    double blurSigma = 10,
    Color? overlay,
    String placeholderUrl = 'https://via.placeholder.com/150',
  }) {
    final imageUrl = getProfileImageUrl(photo, placeholderUrl: placeholderUrl);

    Widget networkImage = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      color: overlay,
      errorBuilder: (context, error, stackTrace) {
        return Image.network(
          placeholderUrl,
          width: width,
          height: height,
          fit: fit,
        );
      },
      colorBlendMode: overlay != null ? BlendMode.darken : null,
    );

    // Apply blur if requested
    if (blur) {
      return ImageFiltered(
        imageFilter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma
        ),
        child: networkImage,
      );
    }

    return networkImage;
  }
}