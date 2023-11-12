import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/screens/auth/login_screen.dart';
import 'package:talbna/screens/auth/login_screen_new.dart';
import 'package:talbna/screens/auth/register_screen.dart';
import 'package:talbna/screens/auth/register_screen_new.dart';
import 'package:talbna/screens/auth/reset_password.dart';
import 'package:talbna/screens/check_auth.dart';
import 'package:talbna/screens/home/home_screen.dart';
import 'package:talbna/screens/home/select_language.dart';
import 'package:talbna/screens/profile/purchase_request_screen.dart';
import 'package:talbna/screens/service_post/create_service_post_form.dart';
import 'package:talbna/widgets/service_post_view_widget.dart';

class Routes {
  static const String noRoute = '/';
  static const String login = 'login';
  static const String loginNew = 'loginNew';
  static const String selectLang = 'SelectLanguage';

  static const String resetPassword = 'reset_password';

  static const String register = 'register';
  static const String registerNew = 'registerNew';

  static const String home = 'home';
  static const String servicePostDetail = 'service_post_detail';
  static const String servicePostUpdate = 'service_post_update';
  static const String servicePostForm = 'service_post_form';
  static const String purchaseRequest = 'purchase_request';
  static const String profile = 'profile';
  static const String profileEdit = 'profile/edit';

  static Route<dynamic> generateRoute(
      RouteSettings settings, BuildContext context) {
    switch (settings.name) {
      case noRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case selectLang:
        return MaterialPageRoute(builder: (_) =>    const LanguageSelectionScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case loginNew:
        return MaterialPageRoute(builder: (_) => const LoginScreenNew());
      case register:
        return MaterialPageRoute(
            builder: (_) => RegisterScreen(
                  authenticationBloc:
                      BlocProvider.of<AuthenticationBloc>(context),
                ));
      case registerNew:
        return MaterialPageRoute(
            builder: (_) => RegisterScreenNew(
              authenticationBloc:
              BlocProvider.of<AuthenticationBloc>(context),
            ));
      case home:
        return MaterialPageRoute(builder: (_) =>  const CheckAuthScreen());
      case resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      case servicePostDetail:
        return MaterialPageRoute(builder: (_) => const ServicePostViewWidget());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
