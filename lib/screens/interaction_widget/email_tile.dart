import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailTile extends StatelessWidget {
  final String email;
  const EmailTile({super.key, required this.email});

  String _truncateEmail(String email) {
    const maxLength = 15;
    if (email.length > maxLength) {
      return '${email.substring(0, maxLength)}...';
    } else {
      return email;
    }
  }

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
    return Card(
      child: ListTile(
        leading: const Icon(Icons.email),
        title: const Text('Email'),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                _truncateEmail(email),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        onTap: _launchEmailApp,
      ),
    );
  }
}
