import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/routes.dart';
import 'package:talbna/screens/check_auth.dart';
import 'package:talbna/screens/splash.dart';
import 'package:talbna/screens/widgets/loading_widget.dart';
import 'package:talbna/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/utils/fcm_handler.dart';
import 'blocs/authentication/authentication_bloc.dart';
import 'data/repositories/authentication_repository.dart';
import 'utils/constants.dart';

class MyApp extends StatefulWidget {
  final AuthenticationRepository authenticationRepository;
  final bool isDarkTheme;

  const MyApp({
    Key? key,
    required this.authenticationRepository,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FCMHandler _fcmHandler = FCMHandler();

  @override
  void initState() {
    super.initState();
    initializeFCM();
  }

  Future<void> initializeFCM() async {
    await _fcmHandler.initializeFCM();
    String deviceToken = await _fcmHandler.getDeviceToken();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        Widget? home;
        if (snapshot.hasData) {
          final String? token = snapshot.data!.getString('auth_token');
          final int? userId = snapshot.data!.getInt('userId');
          if (token != null && token.isNotEmpty || userId != null) {
            home = _buildHome(context, token);
          } else {
            home = const CheckAuthScreen();
          }
        } else {
          home = const Center(child: LoadingWidget());
        }
        return BlocBuilder<ThemeCubit, ThemeData>(
          builder: (context, theme) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: Constants.appName,
                theme: theme,
                onGenerateRoute: (settings) => Routes.generateRoute(settings, context),
                home: Scaffold(body: home),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHome(BuildContext context, String? token) {
    return FutureBuilder<bool>(
      future: widget.authenticationRepository.checkTokenValidity(token!),
      builder: (context, isValidTokenSnapshot) {
        if (isValidTokenSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        } else {
          if (isValidTokenSnapshot.hasData && isValidTokenSnapshot.data!) {
            BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn(token: token));
            return const Splash();
          } else {
            return const CheckAuthScreen();
          }
        }
      },
    );
  }
}
