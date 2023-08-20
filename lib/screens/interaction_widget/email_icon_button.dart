import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailIconButton extends StatelessWidget {
  final String email;
  final double width;

  const EmailIconButton({Key? key, required this.email, required this.width})
      : super(key: key);

  void _launchEmailApp() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch email app.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _launchEmailApp,
      icon: const Icon(Icons.email),
    );
  }
}
