import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/blocs/authentication/authentication_state.dart';
import 'package:talbna/utils/constants.dart';
import 'package:talbna/widgets/text_form_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isButtonEnabled = false;

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _emailController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateButtonState);
    _emailController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
           if (state is ForgotPasswordSuccess) {
             Center(
              child: Text(state.message),
            );
          } else{
            content: ErrorWidget('some error happen');
          }
        },
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return _buildResetPasswordScreen(state);
          },
        ),
      ),
    );
  }
  Widget _buildResetPasswordScreen(AuthenticationState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Enter your email address to reset your password',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextFromField(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                controller: _emailController,
                obscureText: false,
                maxLength: 50,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Email is required';
                  } else if (Constants.emailRegExp.hasMatch(value)) {
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
              ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                  if (_formKey.currentState!.validate()) {
                      context.read<AuthenticationBloc>().add(ForgotPassword(
                        email: _emailController.text,
                      ));
                  }
                }
                    : null,
                child: const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
