import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneIconButtonWidget extends StatelessWidget {
  final String? phone;
  final double width;

  const PhoneIconButtonWidget({Key? key, this.phone, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: IconButton(
        onPressed: () async {
          if (phone != null) {
            final Uri phoneLaunchUri = Uri(
              scheme: 'tel',
              path: phone!,
            );
            if (await canLaunchUrl(phoneLaunchUri)) {
              print('launch $phone');
              await launchUrl(phoneLaunchUri);
            } else {
              print('Could not launch $phone');

              throw 'Could not launch phone app.';
            }
          }
        }, icon: const Icon(Icons.phone),
      ),
    );

  }
}
