import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/auth/welcome_screen.dart';

class LogoutListTile extends StatefulWidget {
  const LogoutListTile({super.key, required this.language});
  final  Language language;

  @override
  State<LogoutListTile> createState() => _LogoutListTileState();
}

class _LogoutListTileState extends State<LogoutListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout_outlined),
      title: Text(widget.language.tLogoutText()),
      onTap: () async {
        final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(Icons.logout),
                  const SizedBox(width: 8),
                  Text(
                    widget.language.tLogoutText(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Text(
                widget.language.logoutConfirmationText(),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    widget.language.cancelText(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ), backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    widget.language.tLogoutText(),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
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
