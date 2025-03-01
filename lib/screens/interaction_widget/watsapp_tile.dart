import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppWidget extends StatelessWidget {
  final String? whatsAppNumber;
  final String username;

  const WhatsAppWidget({Key? key, this.whatsAppNumber, required this.username})
      : super(key: key);

  String formatWhatsAppNumber(String number) {
    number = number.replaceFirst(RegExp(r'^00'), '');
    return number;
  }

  void launchWhatsApp() async {
    final url = formatWhatsAppNumber(whatsAppNumber ?? 'لا يوجد بيانات');
    if (await canLaunch('https://wa.me/$url')) {
      await launch('https://wa.me/$url');
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset(
          'assets/WhatsApp_logo.png',
          width: 20,
          height: 20,
        ),
      ),
      title: const Text(
        'WhatsApp',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        '+ ${formatWhatsAppNumber(whatsAppNumber ?? 'no data')}',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      onTap: whatsAppNumber != null ? launchWhatsApp : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
