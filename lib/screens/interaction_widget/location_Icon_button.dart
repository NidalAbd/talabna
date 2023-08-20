import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationIconButtonWidget extends StatelessWidget {
  final double locationLatitudes;
  final double locationLongitudes;
  final double width;
  const LocationIconButtonWidget({
    Key? key,
    required this.locationLatitudes,
    required this.locationLongitudes,
    required this.width,
  }) : super(key: key);

  Future<void> launchGoogleMap() async {
    final url =
        'geo:$locationLatitudes,$locationLongitudes?q=$locationLatitudes,$locationLongitudes';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: IconButton(
        onPressed: launchGoogleMap,
        icon: const Icon(
          Icons.location_on_outlined,
          size: 22,
        ),
      ),
    );
  }
}
