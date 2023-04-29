import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/screens/auth/login_screen.dart';
import 'package:talbna/screens/home/home_screen.dart';
import 'package:talbna/screens/widgets/loading_widget.dart';
import 'package:talbna/screens/widgets/success_widget.dart';

class CheckAuthScreen extends StatelessWidget {
  const CheckAuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (BuildContext context, AuthenticationState state) {
        if (state is AuthenticationInitial) {
          SuccessWidget.show(
              context, 'Logged out successfully.'); // Show the success message
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationInitial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            });
            return Container(); // add this line
          } else if (state is AuthenticationSuccess) {
            return HomeScreen(
              userId: state.userId!,
            );
          }else if (state is AuthenticationFailure) {
            return ErrorWidget(state.error);
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
