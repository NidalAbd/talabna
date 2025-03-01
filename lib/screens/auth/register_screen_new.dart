import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/interaction_widget/logo_title.dart';
import 'package:talbna/theme_cubit.dart';
import 'package:talbna/routes.dart';
import '../check_auth.dart';

class RegisterScreenNew extends StatefulWidget {
  const RegisterScreenNew({Key? key}) : super(key: key);

  @override
  _RegisterScreenNewState createState() => _RegisterScreenNewState();
}

class _RegisterScreenNewState extends State<RegisterScreenNew> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController = TextEditingController();
  late final TextEditingController _confirmPasswordController = TextEditingController();
  late bool _obscurePassword = true;
  late bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  final Language language = Language();
  late bool _hasNavigatedToHome = false;

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

          if (errorMessage.contains('email') &&
              (errorMessage.contains('taken') || errorMessage.contains('exists'))) {
            errorType = AuthErrorType.emailAlreadyExists;
            userFriendlyMessage = 'This email is already registered. Please use a different email or try logging in.';
          } else if (errorMessage.contains('password') &&
              (errorMessage.contains('weak') || errorMessage.contains('strong'))) {
            errorType = AuthErrorType.weakPassword;
            userFriendlyMessage = 'Please use a stronger password with at least 8 characters, including numbers and symbols.';
          } else if (errorMessage.contains('network') ||
              errorMessage.contains('connection') ||
              errorMessage.contains('timeout')) {
            errorType = AuthErrorType.networkError;
            userFriendlyMessage = 'Unable to connect. Please check your internet connection.';
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
              // Retry registration with existing credentials
              _submitRegistration();
            },
          );
        } else if (state is AuthenticationSuccess) {
          setState(() {
            _isLoading = false;
          });
          _hasNavigatedToHome = true;

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

                      // Main registration form
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Title section
                              const SizedBox(height: 20),
                              Text(
                                language.tRegisterText(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Create an account to get started',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Full Name field
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
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
                                  prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                                  labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                                ),
                                style: TextStyle(color: textColor),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

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
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

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
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Confirm Password field
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
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
                                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                      color: primaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                style: TextStyle(color: textColor),
                                obscureText: _obscureConfirmPassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Terms and conditions checkbox
                              Theme(
                                data: Theme.of(context).copyWith(
                                  checkboxTheme: CheckboxThemeData(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _agreeToTerms,
                                        activeColor: primaryColor,
                                        onChanged: (value) {
                                          setState(() {
                                            _agreeToTerms = value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'I agree to the Terms of Service and Privacy Policy',
                                        style: TextStyle(
                                          color: textColor.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Register button
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
                                  onPressed: _isLoading || !_agreeToTerms
                                      ? null
                                      : _submitRegistration,
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
                                    language.tRegisterText(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Login option
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 4,
                                children: [
                                  Text(
                                    "Already have an account?",
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.8),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    child: Text(
                                      language.loginText(),
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

  void _submitRegistration() {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      setState(() {
        _isLoading = true;
      });

      // Use the Register event to match your authentication bloc
      context.read<AuthenticationBloc>().add(
        Register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service and Privacy Policy'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}