import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_event.dart';
import 'package:talbna/blocs/other_users/user_profile_state.dart';
import 'package:talbna/screens/interaction_widget/email_tile.dart';
import 'package:talbna/screens/interaction_widget/phone_tile.dart';
import 'package:talbna/screens/interaction_widget/user_contact.dart';
import 'package:talbna/screens/interaction_widget/watsapp_tile.dart';

class UserInfoScreen extends StatefulWidget {
  final int userId;
  final OtherUserProfileBloc otherUserProfileBloc;
    const UserInfoScreen({super.key, required this.userId, required this.otherUserProfileBloc});
  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {

  @override
  void initState() {
    super.initState();
    widget.otherUserProfileBloc.add(OtherUserProfileRequested(id: widget.userId));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<OtherUserProfileBloc, OtherUserProfileState>(
        bloc: widget.otherUserProfileBloc,
        builder: (context, state) {
         if (state is OtherUserProfileLoadSuccess) {
            // The bloc has successfully retrieved the user profile.
            final user = state.user;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    UserContact(username: user.userName!, whatsApp:user.watsNumber , phone:user.phones , email: user.email,),
                    EmailTile(email: user.email),
                    PhoneWidget(phone: user.phones),
                    WhatsAppWidget(whatsAppNumber: user.watsNumber, username: user.userName!,),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('الجنس'),
                        subtitle: Text(user.gender!),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_city),
                        title: const Text('المدينة'),
                        subtitle: Text(user.city!),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.cake),
                        title: const Text('تاريخ الميلاد'),
                        subtitle: Text(user.dateOfBirth.toString()),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: const Text('الحالة'),
                        subtitle: Text(user.isActive!),
                      ),
                    )
                  ],
                ),
              ),
            );
          } else if (state is OtherUserProfileLoadFailure) {
            // An error occurred while retrieving the user profile.
            final error = state.error;
            return Center(
              child: Text('Error: $error'),
            );
          } else {
            // This should never happen.
            return Container();
          }
        },
      ),
    );
  }
}
