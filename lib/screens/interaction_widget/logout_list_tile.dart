import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';

class LogoutListTile extends StatefulWidget {
  const LogoutListTile({Key? key}) : super(key: key);

  @override
  State<LogoutListTile> createState() => _LogoutListTileState();
}

class _LogoutListTileState extends State<LogoutListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout_outlined,color: Colors.white,),
      title: const Text('Logout',style: TextStyle(color: Colors.white),),
      onTap: () async {
        Navigator.pop(context);
        final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Logout',style: TextStyle(color: Colors.white),),
              content: const Text('Are you sure you want to log out?',style: TextStyle(color: Colors.white),),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL',style: TextStyle(color: Colors.white),),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('LOGOUT',style: TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        );

        if (confirmed == true) {
          authenticationBloc.add(LoggedOut());
        }
      },
    );

  }
}
