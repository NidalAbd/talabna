import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:talbna/screens/widgets/success_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class UserContact extends StatelessWidget {

  final String username;
  final String? whatsApp;
  final String? phone;
  final String? email;


  const UserContact({Key? key, required this.username, this.whatsApp, this.phone, this.email}) : super(key: key);

  String formatWhatsAppNumber(String number) {
    // Remove leading '00'
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
        phones: [Phone(whatsApp! ,label: PhoneLabel.mobile),Phone(phone! ,label: PhoneLabel.mobile)],
        emails: [Email(email!),]
      );

      await FlutterContacts.insertContact(newContact);
      SuccessWidget.show(context,'تم اضافة المستخدم الى جهة الاتصال بنجاح');
    } else {
      print('Contacts permission denied.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: IconButton(onPressed: () => addToContacts(context), icon: const Icon(Icons.person)),
        title: const Text('المستخدم'),
        subtitle: Text(username),
        trailing: IconButton(onPressed: () => addToContacts(context), icon: const Icon(Icons.add_box)),
      ),
    );
  }
}
