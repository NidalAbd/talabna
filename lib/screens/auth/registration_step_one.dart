import 'package:flutter/material.dart';
import 'package:talbna/utils/constants.dart';
import 'package:talbna/widgets/text_form_field.dart';

class RegistrationStepOne extends StatefulWidget {
  final Function(Map<String, String>) onNext;

  const RegistrationStepOne({Key? key, required this.onNext}) : super(key: key);

  @override
  State<RegistrationStepOne> createState() => _RegistrationStepOneState();
}

class _RegistrationStepOneState extends State<RegistrationStepOne> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late  bool _obscurePassword = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final username = _usernameController.text;
      final password = _passwordController.text;

      final formData = {
        'email': email,
        'username': username,
        'password': password,
      };

      widget.onNext(formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
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
                controller: _usernameController,
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
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Next',style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
