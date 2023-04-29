import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/screens/interaction_widget/logo_title.dart';
import 'package:talbna/screens/widgets/error_widget.dart';
import 'package:talbna/screens/widgets/loading_widget.dart';
import 'package:talbna/utils/constants.dart';
import 'package:talbna/widgets/text_form_field.dart';

import '../../blocs/authentication/authentication_event.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
  TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();
  }
  @override
  void dispose() {
    _animationController.dispose(); // Add this line to dispose of the Ticker object
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.accentColor,
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationInProgress) {
            const LoadingWidget();
          } else if (state is AuthenticationFailure) {
            ErrorCustomWidget.show(context, 'هناك خطا في تسجيل الدخول');
          } else if (state is AuthenticationSuccess) {
            Navigator.pushReplacementNamed(context, 'home');
          } else {
            ErrorCustomWidget.show(context, 'فشل في تسجيل الدخول');
          }
        },
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return _buildLoginScreen(state);
          },
        ),
      ),
    );
  }

  Widget _buildLoginScreen(AuthenticationState state) {
    return Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LogoTitle(fontSize: 50, playAnimation: true, logoSize: 60,),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextFromField(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    controller: _emailController,
                    obscureText: false,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Email is required';
                      } else if (!Constants.emailRegExp.hasMatch(value)) {
                        return 'Invalid email';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(
                      Icons.email_rounded,

                    ),
                    hintText: 'البريد الإلكتروني',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextFromField(

                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'كلمة المرور مطلوبة';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(
                      Icons.lock,

                    ),
                    hintText: 'كلمة المرور',
                    keyboardType: TextInputType.visiblePassword,
                    suffixIcon: const Icon(Icons.visibility),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Navigate to the password reset screen
                          Navigator.pushNamed(context, 'reset_password');
                        },
                        child: const Text(
                          'هل نسيت كلمة المرور؟',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: ElevatedButton(
                      onPressed:
                          () {
                        if (_formKey.currentState!.validate()) {
                          context
                              .read<AuthenticationBloc>()
                              .add(LoginRequest(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ));
                        }
                      },
                      //  _isLoginButtonEnabled(state)? : null,
                      child: const Text('تسجيل دخول'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Implement the "Create one" functionality here
                      Navigator.pushNamed(context, 'register');
                    },
                    child: const Text(
                      'لا تمتلك حساب؟ إنشاء حساب',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 1,
                        width: MediaQuery.of(context).size.width / 8.2,
                        color: AppTheme.primaryColor,
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
                        color: AppTheme.primaryColor,
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
              ),
            ),
          ),
        ),
      );
  }
}