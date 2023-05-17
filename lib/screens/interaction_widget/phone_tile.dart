import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneWidget extends StatelessWidget {
  final String? phone;
  const PhoneWidget({Key? key, this.phone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.lightForegroundColor
          : AppTheme.darkForegroundColor,
      child: ListTile(
        leading: const Icon(Icons.phone),
        title: const Text('الجوال'),
        subtitle: Text(phone ?? 'لا يوجد بيانات'),
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
      ),
    );
  }
}
