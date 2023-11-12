import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/auth/welcome_screen.dart';

class LogoutListTile extends StatefulWidget {
  const LogoutListTile({Key? key, required this.language}) : super(key: key);
  final  Language language;

  @override
  State<LogoutListTile> createState() => _LogoutListTileState();
}

class _LogoutListTileState extends State<LogoutListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout_outlined),
      title:  Text(widget.language.tLogoutText()),
      onTap: () async {
        final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title:  Text(widget.language.tLogoutText()),
              content:  Text(widget.language.logoutConfirmationText()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child:  Text(widget.language.cancelText()),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child:  Text(widget.language.tLogoutText()),
                ),
              ],
            );
          },
        );

        if (confirmed == true) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const WelcomeScreen(),
            ),
          );
          authenticationBloc.add(LoggedOut());
        }
      },
    );

  }
}
