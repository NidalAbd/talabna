import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_theme.dart';

// EmailTile Widget
class EmailTile extends StatelessWidget {
  final String email;
  const EmailTile({super.key, required this.email});

  String _truncateEmail(String email) {
    const maxLength = 20;
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode
        ? AppTheme.darkSecondaryColor
        : AppTheme.lightPrimaryColor;

    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.email_outlined,
              color: primaryColor,
              size: 20,
            ),
          ),
          title: const Text(
            'Email',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            _truncateEmail(email),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          onTap: _launchEmailApp,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        Divider(
          height: 1,
          color: Colors.grey[200],
          indent: 64,
          endIndent: 16,
        ),
      ],
    );
  }
}