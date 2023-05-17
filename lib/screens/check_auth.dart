import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/screens/auth/login_screen.dart';
import 'package:talbna/screens/auth/welcome_screen.dart';
import 'package:talbna/screens/home/home_screen.dart';
import 'package:talbna/screens/widgets/success_widget.dart';

class CheckAuthScreen extends StatelessWidget {
  const CheckAuthScreen({Key? key}) : super(key: key);

  void getSuccessScreen(BuildContext context) {
    Navigator.pushReplacementNamed(context, "home");
  }
  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (BuildContext context, AuthenticationState state) {
        if (state is AuthenticationSignOut) {
          SuccessWidget.show(context, 'Logged out successfully');
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else if (state is AuthenticationInProgress) {
            const CircularProgressIndicator();
        } else if (state is AuthenticationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid login credentials or email taken'),
            ),
          );
        } else if (state is AuthenticationSuccess) {
          SuccessWidget.show(context, 'User operation successful');
          Navigator.pushReplacementNamed(context, "home");
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationInitial) {
            clearSharedPreferences();
            return const WelcomeScreen();
          } else if (state is AuthenticationSuccess) {
            return HomeScreen(userId: state.userId!);
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
