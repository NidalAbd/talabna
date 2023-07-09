import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/screens/auth/login_screen.dart';
import 'package:talbna/screens/auth/login_screen_new.dart';
import 'package:talbna/screens/auth/welcome_screen.dart';
import 'package:talbna/screens/home/home_screen.dart';
import 'package:talbna/screens/widgets/success_widget.dart';
import 'package:talbna/utils/fcm_handler.dart';

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({Key? key}) : super(key: key);

  @override
  _CheckAuthScreenState createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  bool _isConnected = true; // Initially assuming there is internet connection

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected =
          connectivityResult != ConnectivityResult.none; // Update the connectivity status
    });
  }

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
        } else if (state is AuthenticationFailure) {
          if (_isConnected) {
            print(state.error);
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                content: Text('Invalid login credentials or email taken ${state.error}'),

              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You are currently offline'),
              ),
            );
          }
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
            return  const LoginScreenNew();
          }
        },
      ),
    );
  }
}
