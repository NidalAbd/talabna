import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
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
  late  bool _obscurePassword = false;
  late AnimationController _animationController;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationController.forward();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }
  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
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
      resizeToAvoidBottomInset: false, // Add this line
      body: Container(
          decoration:   BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.lightPrimaryColor
                    : AppTheme.darkPrimaryColor,
                AppTheme.accentColor,
              ],
            ),
          ),
          child: _buildRegisterScreen()
      ),
    );
  }
  Widget _buildRegisterScreen() {
    return Center(
      child: SingleChildScrollView (
        child: Form(
          key: _formKey,
          child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
              listener: (context, state) {
                if (state is AuthenticationFailure) {
                  setState(() {
                    _isLoading = false;
                  });
                }
                else if (state is AuthenticationSuccess) {
                  // Set _isLoading to false when authentication succeeds.
                  setState(() {
                    _isLoading = false;
                  });
                  // Navigate to the home screen or perform any necessary action.
                  // Example: Navigator.pushReplacementNamed(context, 'home');
                }
              },
              builder: (context, state) {
              return Stack(
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
                        padding: const EdgeInsets.fromLTRB(0, 40, 0, 8),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextFromField(
                                maxLength: 150,
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
                                maxLength: 20,
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
                                maxLength: 50,
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
                                obscureText: _obscurePassword,
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
                              TextFromField(
                                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                                maxLength: 50,
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
                                obscureText: _obscurePassword,
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
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 1.1,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          _isLoading = true; // Start the login process
                                        });
                                        clearSharedPreferences();
                                        context.read<AuthenticationBloc>().add(Register(
                                          name: _nameController.text,
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                        ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(

                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10), // Adjust the radius as per your requirement
                                        ),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                      width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator())
                                        :  const Text(
                                      'تسجيل',
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, 'login');
                                },
                                child: const Text(
                                  'هل لديك حساب؟ تسجيل الدخول',
                                ),
                              ),
                              // const GoogleFaceLoginWidget()
                            ]),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -30,
                    right: MediaQuery.of(context).size.width / 2.5,
                    child: Container(
                      decoration: BoxDecoration(
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
                      child:  CircleAvatar(
                        backgroundColor:    Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.lightPrimaryColor
                            : AppTheme.darkPrimaryColor,
                        radius: 40,
                        child: Icon(Icons.lock, size: 60, color: AppTheme.accentColor,),
                      ),
                    ),
                  ),
                ]
              );
            }
          ),
        ),
      ),
    );
  }
}
