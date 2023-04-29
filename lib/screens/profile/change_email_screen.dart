import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/screens/widgets/error_widget.dart';
import 'package:talbna/screens/widgets/success_widget.dart';

class ChangeEmailScreen extends StatefulWidget {
  final int userId;
  const ChangeEmailScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Load the user profile data
    BlocProvider.of<UserProfileBloc>(context)
        .add(UserProfileRequested(id: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<UserProfileBloc, UserProfileState>(
          listener: (context, state) {
            if (state is UserEmailUpdateSuccess) {
              SuccessWidget.show(context, 'Email changed successfully');
              setState(() {
                _isLoading = false;
              });
            } else if (state is UserEmailUpdateFailure) {
              ErrorCustomWidget.show(context, state.error);
              setState(() {
                _isLoading = false;
              });
            }
          },
          builder: (context, state) {
            if (state is UserProfileLoadSuccess) {
              // Update the email controller with the old email
              _emailController.text = state.user.email ?? '';
            }
            return Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Change Email',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          BlocProvider.of<UserProfileBloc>(context).add(
                            UpdateUserEmail(
                              userId: widget.userId,
                              newEmail: _emailController.text,
                              password: _passwordController.text,
                            ),
                          );
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Update Email'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
