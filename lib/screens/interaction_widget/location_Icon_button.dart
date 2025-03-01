import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationIconButtonWidget extends StatelessWidget {
  final double locationLatitudes;
  final double locationLongitudes;
  final double width;
  final VoidCallback? onDismiss;

  const LocationIconButtonWidget({
    Key? key,
    required this.locationLatitudes,
    required this.locationLongitudes,
    required this.width,
    this.onDismiss,
  }) : super(key: key);

  Future<void> launchGoogleMap(BuildContext context) async {
    // Call dismiss callback if provided
    onDismiss?.call();

    // Validate coordinates
    if (locationLatitudes == 0 && locationLongitudes == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid location coordinates')),
      );
      return;
    }

    // Construct URL for different map apps
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$locationLatitudes,$locationLongitudes';

    try {
      final Uri parsedUrl = Uri.parse(googleMapsUrl);

      if (await canLaunchUrl(parsedUrl)) {
        await launchUrl(
            parsedUrl,
            mode: LaunchMode.externalApplication
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch maps application')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: IconButton(
        onPressed: () => launchGoogleMap(context),
        icon: const Icon(
          Icons.location_on_outlined,
          size: 22,
        ),
      ),
    );
  }
}