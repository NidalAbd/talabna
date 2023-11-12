import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/widgets/error_widget.dart';
import 'package:talbna/screens/widgets/success_widget.dart';

import '../../provider/language.dart';

class ChangeEmailScreen extends StatefulWidget {
  final int userId;
  const ChangeEmailScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final Language _language = Language();

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(_language.tChangeEmailText()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<UserProfileBloc, UserProfileState>(
          listener: (context, state) {
            if (state is UserProfileUpdateSuccess) {
              SuccessWidget.show(context, 'Email changed successfully');
              setState(() {
                _isLoading = false;
              });
              _passwordController.clear();

            } else if (state is UserProfileUpdateFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('error happen when Email change'),
                  duration: Duration(seconds: 2),
                ),
              );
              setState(() {
                _isLoading = false;
              });
            }
          },
          builder: (context, state) {
            final User user;
            if (state is UserProfileLoadSuccess) {
               user = state.user;
              // Update the email controller with the old email
              _emailController.text = state.user.email ?? '';
              return Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration:  InputDecoration(
                      labelText: _language.tChangeEmailText(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: _language.tPasswordText(),
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
                  FractionallySizedBox(
                    widthFactor: 1.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                                5), // Adjust the radius as per your requirement
                          ),
                        ),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        BlocProvider.of<UserProfileBloc>(context).add(
                          UpdateUserEmail(
                            newEmail: _emailController.text,
                            password: _passwordController.text,
                            user:  user,
                          ),
                        );
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          :  Text(_language.tUpdateText()),
                    ),
                  ),
                ],
              );
            }else {
              return const Center(child: CircularProgressIndicator());
            }
          }
        ),
      ),
    );
  }
}
