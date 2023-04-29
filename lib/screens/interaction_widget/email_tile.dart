import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailTile extends StatelessWidget {
  final String email;
  const EmailTile({Key? key, required this.email}) : super(key: key);

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
        title: const Text('البريد الالكتروني'),
        subtitle: Text(email),
        onTap: _launchEmailApp,
      ),
    );
  }
}
