import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailButton extends StatelessWidget {
  final String email;
  final double width;

  const EmailButton({super.key, required this.email, required this.width});

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
  String _truncateEmail(String email) {
    const maxLength = 24;
    if (email.length > maxLength) {
      return '${email.substring(0, maxLength)}...';
    } else {
      return email;
    }
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
        ),
        onPressed: _launchEmailApp,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
               SizedBox(width: width), // Add a fixed width SizedBox before the icon
               const Icon(Icons.email ),
               SizedBox(width: width), // Add some space between the icon and text
              Text(
                _truncateEmail(email),
                textAlign: TextAlign.center,
                style:  const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
