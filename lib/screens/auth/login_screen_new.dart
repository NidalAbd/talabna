import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/screens/interaction_widget/logo_title.dart';
import 'package:talbna/theme_cubit.dart';

class LoginScreenNew extends StatefulWidget {
  const LoginScreenNew({Key? key}) : super(key: key);

  @override
  _LoginScreenNewState createState() => _LoginScreenNewState();
}

class _LoginScreenNewState extends State<LoginScreenNew> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
  TextEditingController();
  late bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationFailure) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      builder: (context, state) {
        return BlocBuilder<ThemeCubit, ThemeData>(
          builder: (context, theme) {
            return Scaffold(
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(height: 250.0),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(8.0),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword =
                                        !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20.0),
                              SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 1.1,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                                        ? AppTheme.lightPrimaryColor.withOpacity(0.6)
                                        : AppTheme.darkPrimaryColor.withOpacity(0.6),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            10), // Adjust the radius as per your requirement
                                      ),
                                    ),
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                    if (_formKey.currentState!
                                        .validate()) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      context
                                          .read<
                                          AuthenticationBloc>()
                                          .add(LoginRequest(
                                        email: _emailController
                                            .text,
                                        password:
                                        _passwordController
                                            .text,
                                      ));
                                    }
                                  },
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                    CircularProgressIndicator(),
                                  )
                                      : const Text(
                                    'تسجيل دخول',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: () {
                                  // Implement the "Create one" functionality here
                                  Navigator.pushNamed(context, 'registerNew');
                                },
                                child: const Text(
                                  'لا تمتلك حساب؟ إنشاء حساب',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    left: 0,
                    child: LogoTitle(
                      fontSize: 40,
                      playAnimation: false,
                      logoSize: 60,
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: 10,
                    child: IconButton(
                    icon: const Icon(Icons.brightness_6),
                    onPressed: () =>
                        BlocProvider.of<ThemeCubit>(context).toggleTheme(),
                  ),),
                  Positioned(
                    top: 30,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),)
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

