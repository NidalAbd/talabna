import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneIconButtonWidget extends StatelessWidget {
  final String? phone;
  final double width;
  final VoidCallback? onDismiss;

  const PhoneIconButtonWidget({
    super.key,
    this.phone,
    required this.width,
    this.onDismiss
  });

  String _formatPhoneNumber(String number) {
    // Remove any non-digit characters
    return number.replaceAll(RegExp(r'\D'), '');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: IconButton(
        onPressed: () async {
          // Call dismiss callback if provided
          onDismiss?.call();

          // Check if phone number exists
          if (phone == null || phone!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No phone number available')),
            );
            return;
          }

          // Format the phone number
          final formattedPhone = _formatPhoneNumber(phone!);

          final Uri phoneLaunchUri = Uri(
            scheme: 'tel',
            path: formattedPhone,
          );

          try {
            if (await canLaunchUrl(phoneLaunchUri)) {
              await launchUrl(phoneLaunchUri, mode: LaunchMode.externalApplication);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch phone app')),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('An error occurred: $e')),
            );
          }
        },
        icon: const Icon(Icons.phone),
      ),
    );
  }
}