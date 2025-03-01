import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneWidget extends StatelessWidget {
  final String? phone;
  const PhoneWidget({Key? key, this.phone}) : super(key: key);

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
              Icons.phone_outlined,
              color: primaryColor,
              size: 20,
            ),
          ),
          title: const Text(
            'Phone',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            phone ?? 'لا يوجد بيانات',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          onTap: () async {
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
          },
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