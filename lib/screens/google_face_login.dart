import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';

class GoogleFaceLoginWidget extends StatelessWidget {
  const GoogleFaceLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 1,
              width: MediaQuery.of(context).size.width / 8.2,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.lightPrimaryColor
                  : AppTheme.darkPrimaryColor,
              margin: const EdgeInsets.only(right: 10),
            ),
            const Text(
              'تسجيل دخول او انشئ حساب باستخدام',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Container(
              height: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.lightPrimaryColor
                  : AppTheme.darkPrimaryColor,
              width: MediaQuery.of(context).size.width / 8.2,
              margin: const EdgeInsets.only(left: 10),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<AuthenticationBloc>()
                      .add(GoogleSignInRequest());
                },
                icon: Image.asset(
                  "assets/google_logo.png",
                  height: 24,
                ),
                label: const Text("قوقل"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('home');
                },
                icon: Image.asset(
                  "assets/facebook_logo.png",
                  height: 24,
                ),
                label: const Text("الفيس بوك"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ],
    );
  }
}
