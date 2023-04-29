import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/user_contact/user_contact_bloc.dart';
import 'package:talbna/blocs/user_contact/user_contact_state.dart';
import 'package:talbna/screens/interaction_widget/email_button.dart';
import 'package:talbna/screens/interaction_widget/phone_button.dart';
import 'package:talbna/screens/interaction_widget/watsapp_button.dart';
import 'package:talbna/screens/widgets/loading_widget.dart';

class UserContactButtons extends StatefulWidget {
  final int userId;
  final ServicePostBloc servicePostBloc;
  final UserContactBloc userContactBloc;
  const UserContactButtons({Key? key, required this.userId, required this.servicePostBloc, required this.userContactBloc}) : super(key: key);
  @override
  State<UserContactButtons> createState() => _UserContactButtonsState();
}

class _UserContactButtonsState extends State<UserContactButtons> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: widget.userContactBloc,
      builder: (context, state) {
        if (state is UserContactLoadSuccess) {
          final user = state.user;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              EmailButton(email: user.email),
              const SizedBox(width: 40),
              PhoneButtonWidget(phone: user.phones),
              const SizedBox(width: 40),
              WhatsAppButtonWidget(
                  whatsAppNumber: user.watsNumber, username: user.userName!),
            ],
          );
        }else {
          // Return a Visibility widget to make the row invisible while preserving its layout space
          return Visibility(
            visible: true,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                EmailButton(email: ''),
                SizedBox(width: 40),
                PhoneButtonWidget(phone: ''),
                SizedBox(width: 40),
                WhatsAppButtonWidget(whatsAppNumber: '', username: ''),
              ],
            ),
          );
        }
      },
    );
  }
}
