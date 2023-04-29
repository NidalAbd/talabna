import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneButtonWidget extends StatelessWidget {
  final String? phone;
  const PhoneButtonWidget({Key? key, this.phone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () async {
      if (phone != null) {
        final Uri phoneLaunchUri = Uri(
          scheme: 'tel',
          path: phone!,
        );
        if (await canLaunchUrl(phoneLaunchUri)) {
          await launchUrl(phoneLaunchUri);
        } else {
          throw 'Could not launch phone app.';
        }
      }
    },child: const Icon(Icons.phone),);

  }
}
