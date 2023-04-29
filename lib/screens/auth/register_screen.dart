import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/screens/interaction_widget/logo_title.dart';
import 'package:talbna/screens/widgets/header_continer.dart';
import 'package:talbna/screens/widgets/loading_widget.dart';
import 'package:talbna/screens/widgets/error_widget.dart';
import 'package:talbna/screens/widgets/success_widget.dart';
import 'package:talbna/utils/constants.dart';
import 'package:talbna/widgets/text_form_field.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    Key? key,
    required this.authenticationBloc,
  }) : super(key: key);
  final AuthenticationBloc authenticationBloc;

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin{
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool get _isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  bool _isRegisterButtonEnabled(AuthenticationState state) {
    return state is! AuthenticationInProgress && _isPopulated;
  }
  AuthenticationBloc get _authenticationBloc =>
      BlocProvider.of<AuthenticationBloc>(context);


  @override
  void dispose() {
    _animationController.dispose(); // Add this line to dispose of the Ticker
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.accentColor,
      resizeToAvoidBottomInset: false, // Add this line
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationInProgress) {
            const LoadingWidget();
          }
          else if (state is AuthenticationSuccess) {
            SuccessWidget.show(context, 'user registered successfully');
            Navigator.pushReplacementNamed(context, "home");
          }
          else if (state is AuthenticationFailure) {
            ErrorCustomWidget.show(context, state.error);
          } else{
            ErrorCustomWidget.show(context, 'some error happen');
          }
        },
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return _buildRegisterScreen(state);
          },
        ),
      ),
    );
  }
  Widget _buildRegisterScreen(AuthenticationState state) {
    return Center(
      child: SingleChildScrollView (
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const LogoTitle(fontSize: 50, playAnimation: true, logoSize: 60,),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    TextFromField(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      controller: _emailController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(
                        Icons.email_rounded,
                      ),
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                    ),
                    TextFromField(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      controller: _nameController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Email is required';
                        } else if (Constants.emailRegExp.hasMatch(value)) {
                          return 'Invalid email';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(
                        Icons.person,
                      ),
                      hintText: 'Username',
                      obscureText: false,
                      keyboardType: TextInputType.name,
                    ),
                    TextFromField(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      controller: _passwordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(
                        Icons.lock,
                      ),
                      hintText: 'Password',
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      suffixIcon: const Icon(Icons.visibility,
                      ),
                    ),
                    TextFromField(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(
                        Icons.lock,
                      ),
                      hintText: 'Confirm Password',
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      suffixIcon: const Icon(Icons.visibility,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ElevatedButton(
                        onPressed:() {
                          if (_formKey.currentState!.validate()) {

                            context.read<AuthenticationBloc>().add(Register(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                            );
                           }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'تسجيل',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, 'login');
                      },
                      child: const Text(
                        'هل لديك حساب؟ تسجيل الدخول',
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
    );
  }
}
