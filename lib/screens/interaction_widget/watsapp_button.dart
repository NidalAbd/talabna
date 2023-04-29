import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppButtonWidget extends StatelessWidget {
  final String? whatsAppNumber;
  final String username;

  const WhatsAppButtonWidget({Key? key, this.whatsAppNumber, required this.username}) : super(key: key);

  String formatWhatsAppNumber(String number) {
    // Remove leading '00'
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
    return GestureDetector(onTap: launchWhatsApp,child: Image.asset('assets/WhatsApp_logo.png', width: 24, height: 24,));
  }
}
