import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_event.dart';
import 'package:talbna/blocs/other_users/user_profile_state.dart';
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
            EmailTile(email: widget.user.email),
            PhoneWidget(phone: widget.user.phones),
            WhatsAppWidget(whatsAppNumber: widget.user.watsNumber, username: widget.user.userName!,),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('الجنس'),
                subtitle: Text(widget.user.gender!),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('المدينة'),
                subtitle: Text(widget.user.city!),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.cake),
                title: const Text('تاريخ الميلاد'),
                subtitle: Text(widget.user.dateOfBirth.toString()),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('الحالة'),
                subtitle: Text(widget.user.isActive!),
              ),
            )
          ],
        ),
      ),
    );
  }
}
