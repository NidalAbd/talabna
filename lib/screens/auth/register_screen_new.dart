import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/screens/interaction_widget/logo_title.dart';
import 'package:talbna/theme_cubit.dart';

import '../../provider/language.dart';
import '../../routes.dart';
import '../check_auth.dart';

class RegisterScreenNew extends StatefulWidget {
  const RegisterScreenNew({
    Key? key,
    required this.authenticationBloc,
  }) : super(key: key);

  final AuthenticationBloc authenticationBloc;

  @override
  _RegisterScreenNewState createState() => _RegisterScreenNewState();
}

class _RegisterScreenNewState extends State<RegisterScreenNew>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  bool _isLoading = false;
  final Language language = Language();

  @override
  void initState() {
    super.initState();
    language.getLanguage(); // No need to call setState here
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
         if (state is AuthenticationFailure) {
        // Set isLoading to false when authentication fails
        setState(() {
        _isLoading = false;
        });

        // Determine the most appropriate error type and message
        AuthErrorType errorType;
        String userFriendlyMessage;

        // Convert error to lowercase for case-insensitive checking
        String errorMessage = state.error.toLowerCase();

        // Handle validation errors
        if (errorMessage.contains('email') || errorMessage.contains('password')) {
        errorType = AuthErrorType.invalidCredentials;
        userFriendlyMessage = 'Please check your email and password format.';
        }
        // Handle unauthorized access (wrong credentials)
        else if (errorMessage.contains('unauthorized')) {
        errorType = AuthErrorType.invalidCredentials;
        userFriendlyMessage = 'Incorrect email or password. Please try again.';
        }
        // Handle unique email constraint during registration
        else if (errorMessage.contains('unique') || errorMessage.contains('already exists')) {
        errorType = AuthErrorType.invalidCredentials;
        userFriendlyMessage = 'This email is already registered. Try logging in or use a different email.';
        }
        // Handle network or connection issues
        else if (errorMessage.contains('network') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('timeout')) {
        errorType = AuthErrorType.networkError;
        userFriendlyMessage = 'Unable to connect. Please check your internet connection.';
        }
        // Handle server-side errors
        else if (errorMessage.contains('server') ||
        errorMessage.contains('internal') ||
        errorMessage.contains('unable to')) {
        errorType = AuthErrorType.serverError;
        userFriendlyMessage = 'We\'re experiencing technical difficulties. Please try again later.';
        }
        // Handle password-related issues
        else if (errorMessage.contains('password confirmation') ||
        errorMessage.contains('min:')) {
        errorType = AuthErrorType.invalidCredentials;
        userFriendlyMessage = 'Password must be at least 8 characters long.';
        }
        // Catch-all for unknown errors
        else {
        errorType = AuthErrorType.unknownError;
        userFriendlyMessage = 'An unexpected error occurred. Please try again.';
        }

        // Show modern error handling
        AuthSnackBar.show(
        context,
        errorType: errorType,
        customMessage: userFriendlyMessage,
        onRetry: () {
        // Retry login with existing credentials
        context.read<AuthenticationBloc>().add(
        LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        ),
        );
        },
        );
        } else if (state is AuthenticationSuccess) {
          // Set _isLoading to false when authentication succeeds.
          print(state);
          setState(() {
            _isLoading = false;
          });
          Routes.navigateToHome(context, state.userId!);
          // Example: Navigator.pushReplacementNamed(context, 'home');
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
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        ),
                        Positioned.fill(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: SingleChildScrollView(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 160,
                                      ),
                                      TextFormField(
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          labelText: language.usernameText(),
                                          focusedBorder:  OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? AppTheme.lightPrimaryColor
                                                  : AppTheme.darkPrimaryColor,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return language.pleaseEnterUsernameText();
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      TextFormField(
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          labelText: language.emailText(),
                                          focusedBorder:  const OutlineInputBorder(
                                            borderSide: BorderSide(

                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return language.enterEmailText();
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 10.0),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          labelText: language.tPasswordText(),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          focusedBorder:  OutlineInputBorder(
                                            borderSide: BorderSide(
                                            ),
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
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return language.enterPasswordText();
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 10.0),
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          labelText: language.confirmPasswordText(),
                                          focusedBorder:  const OutlineInputBorder(
                                            borderSide: BorderSide(
                                            ),
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
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return language.confirmPasswordText();
                                          }
                                          if (_passwordController.text !=
                                              value) {
                                            return language.passwordsDoNotMatchText();
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 10.0),
                                      FractionallySizedBox(
                                        widthFactor: 1.0,
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    setState(() {
                                                      _isLoading =
                                                          true; // Start the registration process
                                                    });
                                                    clearSharedPreferences();
                                                    context
                                                        .read<
                                                            AuthenticationBloc>()
                                                        .add(Register(
                                                          name: _nameController
                                                              .text,
                                                          email:
                                                              _emailController
                                                                  .text,
                                                          password:
                                                              _passwordController
                                                                  .text,
                                                        ));
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(

                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    10), // Adjust the radius as per your requirement
                                              ),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator())
                                              :  Text(
                                                  language.signUpText(),
                                                ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacementNamed(
                                              context, '/login');
                                        },
                                        child:  Text(
                                          language.alreadyHaveAccountText(),
                                        ),
                                      ),

                                    ],
                                  ),
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
                            icon:  Icon(Icons.brightness_6_sharp ,color: Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.darkPrimaryColor
                                : AppTheme.lightPrimaryColor,),
                            onPressed: () =>
                                BlocProvider.of<ThemeCubit>(context).toggleTheme(),
                          ),
                        ),
                        Positioned(
                          top: 30,
                          left: 10,
                          child: IconButton(
                            icon:  Icon(Icons.arrow_back,color: Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.darkPrimaryColor
                                : AppTheme.lightPrimaryColor,),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        )
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}
