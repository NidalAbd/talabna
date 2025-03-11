import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/screens/widgets/success_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../provider/language.dart'; // Import your Language provider

class UserContact extends StatelessWidget {
  final String username;
  final String? whatsApp;
  final String? phone;
  final String? email;

   UserContact({super.key, required this.username, this.whatsApp, this.phone, this.email});

  String formatWhatsAppNumber(String number) {
    number = number.replaceFirst(RegExp(r'^00'), '');
    return number;
  }
  final Language _language = Language();

  Future<void> addToContacts(BuildContext context) async {

    // Show confirmation dialog before proceeding
    final bool shouldProceed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_language.addContact()),
        content: Text(_language.addContactConfirmation(username)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_language.cancel()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_language.add()),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldProceed) return;

    // Request contacts permission
    PermissionStatus status = await Permission.contacts.status;
    if (status.isDenied) {
      // Show permission explanation dialog
      final bool showPermissionRequest = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_language.permissionRequired()),
          content: Text(_language.contactsPermissionExplanation()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(_language.cancel()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(_language.continueText()),
            ),
          ],
        ),
      ) ?? false;

      if (!showPermissionRequest) return;

      status = await Permission.contacts.request();
    }

    if (status.isGranted) {
      try {
        final newContact = Contact(
          name: Name(first: username),
          phones: [
            if (whatsApp != null && whatsApp!.isNotEmpty)
              Phone(whatsApp!, label: PhoneLabel.mobile),
            if (phone != null && phone!.isNotEmpty && phone != whatsApp)
              Phone(phone!, label: PhoneLabel.other)
          ],
          emails: [
            if (email != null && email!.isNotEmpty)
              Email(email!)
          ],
        );

        await FlutterContacts.insertContact(newContact);

        // Show success message
        if (context.mounted) {
          showCustomSnackBar(
              context,
              _language.contactAddedSuccess(username),
              type: SnackBarType.success
          );
        }
      } catch (e) {
        if (context.mounted) {
          showCustomSnackBar(
              context,
              _language.contactAddError(),
              type: SnackBarType.error
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      // Show settings dialog if permission is permanently denied
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_language.permissionDenied()),
            content: Text(_language.openSettingsExplanation()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_language.cancel()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text(_language.openSettings()),
              ),
            ],
          ),
        );
      }
    } else {
      // Permission denied
      if (context.mounted) {
        showCustomSnackBar(
            context,
            _language.permissionDeniedMessage(),
            type: SnackBarType.error
        );
      }
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
        title: Text(
          _language.username(),
          style: const TextStyle(
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
          tooltip: _language.addToContacts(),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}