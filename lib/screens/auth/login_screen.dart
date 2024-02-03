import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/screens/google_face_login.dart';
import 'package:talbna/utils/constants.dart';
import 'package:talbna/widgets/text_form_field.dart';

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
  late  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
          decoration:   BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkPrimaryColor
                    : AppTheme.lightPrimaryColor,

              ],
            ),
          ),
          child: _buildLoginScreen()
      )
    );
  }
  Widget _buildLoginScreen() {
    return Form(
        key: _formKey,
        child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              if (state is AuthenticationFailure) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: Column(
                    children: [
                      // const LogoTitle(fontSize: 40, playAnimation: false , logoSize: 45,),
                      const SizedBox(
                        height: 50,
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 40, 8, 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextFromField(
                                      maxLength: 150,
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
                                      maxLength: 50,
                                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
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
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
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
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width / 1.19,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(

                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(16),
                                                ),
                                              ),
                                            ),
                                            onPressed: _isLoading
                                                ? null
                                                : () {
                                              if (_formKey.currentState!.validate()) {
                                                setState(() {
                                                  _isLoading = true; // Start the login process
                                                });
                                                context
                                                    .read<AuthenticationBloc>()
                                                    .add(LoginRequest(
                                                  email: _emailController.text,
                                                  password: _passwordController.text,
                                                ));
                                              }
                                            },
                                            child: _isLoading
                                                ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator())
                                                : const Text('تسجيل دخول'),
                                          ),
                                        ),

                                      ],
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
                                    // const GoogleFaceLoginWidget()
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -30,
                            right: MediaQuery.of(context).size.width / 2.5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.brown,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 3,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child:   CircleAvatar(
                                backgroundColor: Theme.of(context).brightness == Brightness.dark
                                    ? AppTheme.lightPrimaryColor
                                    : AppTheme.darkPrimaryColor,
                                radius: 40,
                                child: Icon(Icons.lock, size: 60),
                              ),
                            ),
                          ),
                        ]
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      );
  }
}