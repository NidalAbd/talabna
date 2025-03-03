import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/theme_cubit.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const GoogleSignInButton({
    super.key,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
        final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black87;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            icon: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Image.asset(
              'assets/google_logo.png', // Make sure to add this asset to your pubspec.yaml
              height: 24,
              width: 24,
            ),
            label: Text(
              isLoading ? 'Signing in...' : 'Sign in with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: primaryColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onPressed: isLoading ? null : onPressed ?? () {
              BlocProvider.of<AuthenticationBloc>(context).add(GoogleSignInRequest());
            },
          ),
        );
      },
    );
  }
}