import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/interaction_widget/email_tile.dart';
import 'package:talbna/screens/interaction_widget/phone_tile.dart';
import 'package:talbna/screens/interaction_widget/user_contact.dart';
import 'package:talbna/screens/interaction_widget/watsapp_tile.dart';

class UserInfoWidget extends StatefulWidget {
  final int userId;
  final User user;
    const UserInfoWidget({super.key, required this.userId, required this.user, });
  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            UserContact(username: widget.user.userName!, whatsApp:widget.user.watsNumber , phone:widget.user.phones , email: widget.user.email,),
            const Divider(),

            EmailTile(email: widget.user.email),
            const Divider(),

            PhoneWidget(phone: widget.user.phones),
            const Divider(),

            WhatsAppWidget(whatsAppNumber: widget.user.watsNumber, username: widget.user.userName!,),
            const Divider(),

            Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.lightForegroundColor
                  : AppTheme.darkForegroundColor,
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Gender'),
                subtitle: Text(widget.user.gender!),
              ),
            ),
            const Divider(),

            Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.lightForegroundColor
                  : AppTheme.darkForegroundColor,
              child: ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('city'),
                subtitle: Text(widget.user.city!.name),
              ),
            ),
            const Divider(),

            Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.lightForegroundColor
                  : AppTheme.darkForegroundColor,
              child: ListTile(
                leading: const Icon(Icons.cake),
                title: const Text('date of birth'),
                subtitle: Text(widget.user.dateOfBirth.toString()),
              ),
            ),
            const Divider(),

            Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.lightForegroundColor
                  : AppTheme.darkForegroundColor,
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('state'),
                subtitle: Text(widget.user.isActive!),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
