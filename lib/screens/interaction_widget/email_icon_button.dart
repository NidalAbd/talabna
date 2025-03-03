import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailIconButton extends StatelessWidget {
  final String email;
  final double width;
  final VoidCallback? onDismiss;

  const EmailIconButton({
    super.key,
    required this.email,
    required this.width,
    this.onDismiss
  });

  void _launchEmailApp(BuildContext context) async {
    // Dismiss the bottom sheet if onDismiss is provided
    onDismiss?.call();

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch email app')),
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
    return IconButton(
      onPressed: () => _launchEmailApp(context),
      icon: const Icon(Icons.email),
    );
  }
}