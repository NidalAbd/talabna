import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppButtonWidget extends StatelessWidget {
  final String? whatsAppNumber;
  final String username;
  final double width;
  const WhatsAppButtonWidget({super.key, this.whatsAppNumber, required this.username, required this.width});

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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
        ),
        onPressed: launchWhatsApp,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
               SizedBox(width: width), // Add a fixed width SizedBox before the icon
              Image.asset('assets/WhatsApp_logo.png' , width: 25, height: 25,),
               SizedBox(width: width), // Add some space between the icon and text
              Text(
                whatsAppNumber!,
                textAlign: TextAlign.center,
                style:  TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}
