import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/screens/interaction_widget/logo_title.dart';
import 'package:talbna/theme_cubit.dart';


class RegisterScreenNew extends StatefulWidget {
  const RegisterScreenNew({
    Key? key,
    required this.authenticationBloc,
  }) : super(key: key);

  final AuthenticationBloc authenticationBloc;

  @override
  _RegisterScreenNewState createState() => _RegisterScreenNewState();
}

class _RegisterScreenNewState extends State<RegisterScreenNew> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
                  SizedBox(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
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
                                const SizedBox(height: 160,),
                                TextFormField(
                                  controller: _nameController,
                                  decoration:  InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(8.0),
                                    ),
                                    labelText: 'Username',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your username';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10,),
                                TextFormField(
                                  controller: _emailController,
                                  decoration:  InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(8.0),
                                    ),
                                    labelText: 'Email',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10.0),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
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
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
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
                                    labelText: 'Confirm Password',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (_passwordController.text != value) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10.0),
                                SizedBox(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width / 1.1,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          _isLoading =
                                          true; // Start the registration process
                                        });
                                        clearSharedPreferences();
                                        context.read<AuthenticationBloc>()
                                            .add(Register(
                                          name: _nameController.text,
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                        ));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor
                                          .withOpacity(0.6),
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
                                        child: CircularProgressIndicator())
                                        : const Text(
                                      'تسجيل',
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, 'loginNew');
                                  },
                                  child: const Text(
                                    'هل لديك حساب؟ تسجيل الدخول',
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

}
