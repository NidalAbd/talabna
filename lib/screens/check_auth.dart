import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/screens/auth/login_screen.dart';
import 'package:talbna/screens/auth/welcome_screen.dart';
import 'package:talbna/screens/home/home_screen.dart';
import 'package:talbna/screens/widgets/loading_widget.dart';
import 'package:talbna/screens/widgets/success_widget.dart';

class CheckAuthScreen extends StatelessWidget {
  const CheckAuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (BuildContext context, AuthenticationState state) {
        if (state is AuthenticationSignOut) {
          SuccessWidget.show(
              context, 'Logged out successfully.'); // Show the success message
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }else if (state is AuthenticationInProgress) {
          const LoadingWidget();
        }else if (state is AuthenticationFailure) {
          print(state.error);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid login credentials'),
              backgroundColor: Colors.red,
            ),
          );
        }
        else if (state is AuthenticationSuccess) {
          SuccessWidget.show(context, 'user make operation successfully');
          Navigator.pushReplacementNamed(context, "home");
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          print(state);
          if (state is AuthenticationInitial) {
            return const WelcomeScreen(); // add this line
          } else if (state is AuthenticationSuccess) {
            return HomeScreen(
              userId: state.userId!,
            );
          }else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
