import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/screens/widgets/success_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class UserContact extends StatelessWidget {
  final String username;
  final String? whatsApp;
  final String? phone;
  final String? email;

  const UserContact({super.key, required this.username, this.whatsApp, this.phone, this.email});

  String formatWhatsAppNumber(String number) {
    number = number.replaceFirst(RegExp(r'^00'), '');
    return number;
  }

  Future<void> addToContacts(BuildContext context) async {
    // Request contacts permission
    PermissionStatus status = await Permission.contacts.status;
    if (status.isDenied) {
      status = await Permission.contacts.request();
    }
    if (status.isGranted) {
      final newContact = Contact(
          name: Name(first: username),
          phones: [Phone(whatsApp!, label: PhoneLabel.mobile), Phone(phone!, label: PhoneLabel.mobile)],
          emails: [Email(email!),]
      );

      await FlutterContacts.insertContact(newContact);
      showCustomSnackBar(context, 'success', type: SnackBarType.success);
    } else {
      showCustomSnackBar(context, 'error', type: SnackBarType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode
        ? AppTheme.darkSecondaryColor
        : AppTheme.lightPrimaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 1), // Reduced padding for tight grouping
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.person_outline,
            color: primaryColor,
            size: 20,
          ),
        ),
        title: const Text(
          'Username',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          username,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: IconButton(
          onPressed: () => addToContacts(context),
          icon: Icon(
            Icons.add_circle_outline,
            color: primaryColor,
          ),
          tooltip: 'Add to Contacts',
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}