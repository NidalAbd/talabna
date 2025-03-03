import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/widgets/success_widget.dart';
import '../../provider/language.dart';

class ChangeEmailScreen extends StatefulWidget {
  final int userId;
  const ChangeEmailScreen({super.key, required this.userId});

  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final Language _language = Language();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<UserProfileBloc>(context)
        .add(UserProfileRequested(id: widget.userId));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit(User user) {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      BlocProvider.of<UserProfileBloc>(context).add(
        UpdateUserEmail(
          newEmail: _emailController.text,
          password: _passwordController.text,
          user: user,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final backgroundColor = isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        title: Text(
          _language.tChangeEmailText(),
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileUpdateSuccess) {
            setState(() => _isLoading = false);
            _passwordController.clear();
            showCustomSnackBar(context, 'success', type: SnackBarType.success);
          } else if (state is UserProfileUpdateFailure) {
            setState(() => _isLoading = false);
            showCustomSnackBar(context, 'error', type: SnackBarType.success);
          }
        },
        builder: (context, state) {
          if (state is UserProfileLoadSuccess) {
            _emailController.text = state.user.email ?? '';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 80,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Update Your Email',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your new email address and current password to make changes',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildEmailField(primaryColor),
                      const SizedBox(height: 24),
                      _buildPasswordField(primaryColor),
                      const SizedBox(height: 32),
                      _buildSubmitButton(state.user, primaryColor),
                    ],
                  ),
                ),
              ),
            );
          }

          return Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmailField(Color primaryColor) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an email address';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'New Email Address',
        hintText: 'Enter your new email',
        prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildPasswordField(Color primaryColor) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: _language.tPasswordText(),
        hintText: 'Enter your current password',
        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: primaryColor,
          ),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(User user, Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _handleSubmit(user),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          _language.tUpdateText(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}