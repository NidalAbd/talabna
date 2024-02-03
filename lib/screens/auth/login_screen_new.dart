import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/provider/language.dart';
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
  final Language language = Language();

  @override
  void initState() {
    super.initState();
    language.getLanguage(); // No need to call setState here
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationInProgress) {
          // Set _isLoading to true when the authentication request is in progress.
          setState(() {
            _isLoading = true;
          });
        } else if (state is AuthenticationFailure) {
          // Set _isLoading to false when authentication fails.
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text('Some Error Happen ${state.error},' , style: TextStyle(color: Colors.white),),
            ),
          );
        } else if (state is AuthenticationSuccess) {
          // Set _isLoading to false when authentication succeeds.
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacementNamed(context, "home");
          // Navigate to the home screen or perform any necessary action.
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
                                  labelText: language.emailText(),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return language.enterEmailText();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: language.tPasswordText(),
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
                                    return language.enterPasswordText();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20.0),
                              SizedBox(
                                width: MediaQuery.of(context).size.width /
                                    1.1,
                                child: ElevatedButton(
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
                                        email:
                                        _emailController
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
                                      : Text(
                                    language.loginText(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: () {
                                  // Implement the "Create one" functionality here
                                  Navigator.pushNamed(context, 'registerNew');
                                },
                                child: Text(
                                  language.createAccountText(),
                                  style: const TextStyle(
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
                      icon: Icon(
                        Icons.brightness_6_sharp,
                        color: Theme.of(context).brightness ==
                            Brightness.dark
                            ? AppTheme.darkPrimaryColor
                            : AppTheme.lightPrimaryColor,
                      ),
                      onPressed: () =>
                          BlocProvider.of<ThemeCubit>(context)
                              .toggleTheme(),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    left: 10,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).brightness ==
                            Brightness.dark
                            ? AppTheme.darkPrimaryColor
                            : AppTheme.lightPrimaryColor,
                      ),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
