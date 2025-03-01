import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppIconButtonWidget extends StatelessWidget {
  final String? whatsAppNumber;
  final double width;
  final VoidCallback? onDismiss;

  const WhatsAppIconButtonWidget({
    Key? key,
    this.whatsAppNumber,
    required this.width,
    this.onDismiss
  }) : super(key: key);

  String formatWhatsAppNumber(String number) {
    // Remove leading '00'
    number = number.replaceFirst(RegExp(r'^00'), '');
    // Remove any non-digit characters
    number = number.replaceAll(RegExp(r'\D'), '');
    return number;
  }

  void launchWhatsApp(BuildContext context) async {
    // Call dismiss callback if provided
    onDismiss?.call();

    // Check if WhatsApp number exists
    if (whatsAppNumber == null || whatsAppNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No WhatsApp number available')),
      );
      return;
    }

    final formattedNumber = formatWhatsAppNumber(whatsAppNumber!);

    // Construct WhatsApp URL
    final url = 'https://wa.me/$formattedNumber';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch WhatsApp')),
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
    return GestureDetector(
      onTap: () => launchWhatsApp(context),
      child: Image.asset(
        'assets/WhatsApp_logo.png',
        width: width,
        height: width,
      ),
    );
  }
}