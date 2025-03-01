// Create this file at: lib/screens/widgets/profile_incomplete_dialog.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/profile/profile_edit_screen.dart';

class ProfileIncompleteDialog extends StatelessWidget {
  final User user;
  final int userId;
  final Language language = Language();

  ProfileIncompleteDialog({
    super.key,
    required this.user,
    required this.userId,
  });

  Future<void> _skipForNow(BuildContext context) async {
    // Mark profile as completed even if it's not, to prevent further prompts
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profileCompleted', true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final primaryColor = isDarkMode
        ? AppTheme.darkSecondaryColor
        : AppTheme.lightPrimaryColor;

    return AlertDialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        language.incompleteInformationText(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.completeProfilePromptText(),
            style: TextStyle(color: textColor),
          ),
          SizedBox(height: 16),
          Text(
            language.whyCompleteProfileText(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          _buildBulletPoint(language.betterExperienceText(), textColor),
          _buildBulletPoint(language.personalizedContentText(), textColor),
          _buildBulletPoint(language.connectWithOthersText(), textColor),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _skipForNow(context),
          child: Text(
            language.skipForNowText(),
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UpdateUserProfile(
                  userId: userId,
                  user: user,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(language.completeNowText()),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(color: textColor, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}