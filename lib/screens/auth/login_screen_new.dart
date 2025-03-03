import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/theme_cubit.dart';
import 'package:talbna/routes.dart';
import '../check_auth.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreenNew extends StatefulWidget {
  const LoginScreenNew({super.key});

  @override
  _LoginScreenNewState createState() => _LoginScreenNewState();
}

class _LoginScreenNewState extends State<LoginScreenNew> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController = TextEditingController();
  late bool _obscurePassword = true;
  bool _isLoading = false;
  final Language language = Language();
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    language.getLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationInProgress) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is AuthenticationFailure) {
          setState(() {
            _isLoading = false;
          });

          // Determine the most appropriate error type and message
          AuthErrorType errorType;
          String userFriendlyMessage;

          // Convert error to lowercase for case-insensitive checking
          String errorMessage = state.error.toLowerCase();

          if (errorMessage.contains('password') ||
              errorMessage.contains('credentials') ||
              errorMessage.contains('invalid') ||
              errorMessage.contains('unauthorized')) {
            errorType = AuthErrorType.invalidCredentials;
            userFriendlyMessage = 'Incorrect email or password. Please try again.';
          } else if (errorMessage.contains('network') ||
              errorMessage.contains('connection') ||
              errorMessage.contains('timeout')) {
            errorType = AuthErrorType.networkError;
            userFriendlyMessage = 'Unable to connect. Please check your internet connection.';
          } else if (errorMessage.contains('verify') ||
              errorMessage.contains('email')) {
            errorType = AuthErrorType.emailNotVerified;
            userFriendlyMessage = 'Please verify your email address before logging in.';
          } else if (errorMessage.contains('server') ||
              errorMessage.contains('internal')) {
            errorType = AuthErrorType.serverError;
            userFriendlyMessage = 'We\'re having trouble connecting right now. Please try again later.';
          } else {
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
          setState(() {
            _isLoading = false;
            _isGoogleLoading = false;

          });
          Routes.navigateToHome(context, state.userId!);
        }
      },
      builder: (context, state) {
        return BlocBuilder<ThemeCubit, ThemeData>(
          builder: (context, theme) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
            final backgroundColor = isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor;
            final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;

            // Set system UI overlay style based on theme
            AppTheme.setSystemBarColors(
                isDarkMode ? Brightness.light : Brightness.dark,
                backgroundColor,
                backgroundColor
            );

            return Scaffold(
              backgroundColor: backgroundColor,
              body: SafeArea(
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                )
                    : SingleChildScrollView(
                  child: Column(
                      children: [
                  // Top toolbar with back button and theme toggle
                  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      InkWell(
                        onTap: () {
                          // Instead of simple pop, navigate back to welcome screen
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                      ),

                      // Theme toggle
                      InkWell(
                        onTap: () {
                          BlocProvider.of<ThemeCubit>(context).toggleTheme();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main login form
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Title section
                        const SizedBox(height: 40),
                        Text(
                          language.loginText(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome back! Please sign in to continue',
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: language.emailText(),
                            filled: true,
                            fillColor: primaryColor.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                            prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                            labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                          ),
                          style: TextStyle(color: textColor),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return language.enterEmailText();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: language.tPasswordText(),
                            filled: true,
                            fillColor: primaryColor.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide(color: primaryColor, width: 2),
                            ),
                            prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                            labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          style: TextStyle(color: textColor),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return language.enterPasswordText();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Navigate to forgot password screen
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: isDarkMode ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                context.read<AuthenticationBloc>().add(
                                  LoginRequest(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  ),
                                );
                              }
                            },
                            child: _isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              language.loginText(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Google Sign-In Button
                        GoogleSignInButton(
                          isLoading: _isGoogleLoading,
                        ),
                        const SizedBox(height: 24),


                        // Register option
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: Text(
                                language.createAccountText(),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
            ),
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