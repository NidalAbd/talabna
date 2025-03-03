import 'dart:ui';
import 'package:flutter/material.dart';
import 'constants.dart';

/// A utility class for handling profile image URLs and creating profile image widgets
class ProfileImageHelper {
  /// Gets the appropriate profile image URL based on the user's photo or direct input
  ///
  /// [input] Can be a User object or a String (userPhoto)
  /// [baseApiUrl] Optional base URL for internal images (defaults to Constants.apiBaseUrl)
  /// [placeholderUrl] Optional placeholder image URL
  static String getProfileImageUrl(
      dynamic input, {
        String? baseApiUrl,
        String placeholderUrl = 'https://via.placeholder.com/150',
        bool? isExternal,
      }) {
    // If input is a direct URL string
    if (input is String) {
      // If isExternal is explicitly set to true, return the input as-is
      if (isExternal == true) {
        return input;
      }

      // If isExternal is explicitly set to false or not specified
      return input.isNotEmpty
          ? '${baseApiUrl ?? Constants.apiBaseUrl}/storage/$input'
          : placeholderUrl;
    }

    // If input is a User object
    final user = input;

    // Check if user or photos are null
    if (user?.photos == null || user.photos.isEmpty) {
      return placeholderUrl;
    }

    final photo = user.photos.first;

    // If photo is external, use its source directly
    if (photo.isExternal == true) {
      return photo.src ?? placeholderUrl;
    }

    // For internal images, prepend the base API URL
    return '${baseApiUrl ?? Constants.apiBaseUrl}/storage/${photo.src}';
  }

  /// Creates a customizable profile image widget
  ///
  /// [user] The user object containing photo information
  /// [width] Optional width of the image
  /// [height] Optional height of the image
  /// [fit] BoxFit for the image (defaults to BoxFit.cover)
  /// [blur] Optional blur effect (set to true to apply blur)
  /// [blurSigma] Blur intensity (defaults to 10)
  /// [overlay] Optional color overlay
  static Widget buildProfileImage({
    required dynamic user,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    bool blur = false,
    double blurSigma = 10,
    Color? overlay,
  }) {
    final imageUrl = getProfileImageUrl(user);

    Widget networkImage = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      color: overlay,
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