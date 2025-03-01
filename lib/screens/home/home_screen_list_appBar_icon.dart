import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/home/search_screen.dart';
import 'package:talbna/screens/home/setting_screen.dart';
import 'package:talbna/screens/profile/profile_screen.dart';
import 'package:talbna/screens/profile/purchase_request_screen.dart';
import 'package:talbna/screens/service_post/create_service_post_form.dart';
import 'package:talbna/screens/service_post/favorite_post_screen.dart';
import '../../utils/constants.dart';
import '../profile/profile_edit_screen.dart';
import 'notification_alert_widget.dart';

class VertIconAppBar extends StatelessWidget {
  const VertIconAppBar({
    Key? key,
    required this.userId,
    required this.user,
    required this.showSubcategoryGridView,
    required this.toggleSubcategoryGridView,
  }) : super(key: key);

  final int userId;
  final User user;
  final bool showSubcategoryGridView;
  final Future<void> Function({required bool canToggle}) toggleSubcategoryGridView;

  @override
  Widget build(BuildContext context) {
    final language = Language();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final iconColor = isDarkMode ? AppTheme.darkIconColor : AppTheme.lightIconColor;

    return Row(
      children: [
        _buildIconButton(
          context: context,
          icon: Icons.add_circle_outline_rounded,
          color: primaryColor,
          onPressed: () => _handleAddPost(context, language),
          tooltip: language.tAddPostText(),
        ),
        NotificationsAlert(userID: userId),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
          child: GestureDetector(
            onTap: () => _navigateToProfile(context),
            child: Hero(
              tag: 'profileAvatar${user.id}',
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey[300],
                backgroundImage: (user.photos?.isNotEmpty ?? false)
                    ? NetworkImage('${Constants.apiBaseUrl}/storage/${user.photos?.first.src}')
                    : null,
                child: (user.photos?.isEmpty ?? true)
                    ? Icon(Icons.person, size: 18, color: Colors.grey[700])
                    : null,
              ),
            ),
          ),
        ),
        _buildIconButton(
          context: context,
          icon: Icons.more_vert_rounded,
          color: iconColor,
          onPressed: () => _showMoreOptions(context, language),
          tooltip: language.tMoreOptionsText(),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: IconButton(
            icon: Icon(icon, size: 26),
            color: color,
            onPressed: onPressed,
            splashRadius: 24,
            padding: const EdgeInsets.all(8),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddPost(BuildContext context, Language language) async {
    final isComplete = await _checkProfileCompletion();

    if (isComplete) {
      _navigateToServicePost(context);
    } else {
      _showIncompleteProfileDialog(context, language);
    }
  }

  void _navigateToServicePost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicePostFormScreen(userId: userId),
      ),
    );
  }

  Future<void> _showMoreOptions(
      BuildContext context,
      Language language,
      ) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;

    final isComplete = await _checkProfileCompletion();

    if (isComplete) {
      _showOptionsBottomSheet(context, language, backgroundColor, primaryColor, textColor);
    } else {
      _showIncompleteProfileDialog(context, language);
    }
  }

  void _showOptionsBottomSheet(
      BuildContext context,
      Language language,
      Color backgroundColor,
      Color primaryColor,
      Color textColor,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildOptionTile(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    title: language.tProfileText(),
                    onTap: () => _navigateToProfile(context),
                  ),
                  _buildOptionTile(
                    context: context,
                    icon: Icons.favorite_border_rounded,
                    title: language.tFavoriteText(),
                    onTap: () => _navigateToFavorites(context),
                  ),
                  _buildOptionTile(
                    context: context,
                    icon: Icons.edit_outlined,
                    title: language.tUpdateInfoText(),
                    onTap: () => _navigateToUpdateProfile(context),
                  ),
                  _buildOptionTile(
                    context: context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: language.tPurchasePointsText(),
                    onTap: () => _navigateToPurchase(context),
                  ),
                  _buildOptionTile(
                    context: context,
                    icon: showSubcategoryGridView ? Icons.list_rounded : Icons.grid_view_rounded,
                    title: language.tSwitchSubcategoryList(),
                    onTap: () async {
                      Navigator.pop(context);
                      await toggleSubcategoryGridView(canToggle: true);
                    },
                    isToggle: true,
                  ),
                  _buildOptionTile(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: language.tSettingsText(),
                    onTap: () => _navigateToSettings(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isToggle = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isToggle
            ? Switch(
          value: showSubcategoryGridView,
          onChanged: (value) async {
            Navigator.pop(context);
            await toggleSubcategoryGridView(canToggle: true);
          },
          activeColor: primaryColor,
        )
            : Icon(Icons.chevron_right_rounded, color: primaryColor.withOpacity(0.5)),
        onTap: isToggle ? null : () {
          // First dismiss the bottom sheet
          Navigator.pop(context);
          // Then execute the original onTap action
          onTap();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 40,
      ),
    );
  }

  void _showIncompleteProfileDialog(BuildContext context, Language language) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;
    final backgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, color: primaryColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    language.completeInformationText(),
                    style: TextStyle(
                      color: textColor,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(language.tLaterText()),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToUpdateProfile(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(language.tUpdateNowText()),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          fromUser: userId,
          toUser: userId,
          user: user
        ),
      ),
    );
  }

  void _navigateToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritePostScreen(
          userID: user.id,
          user: user,
        ),
      ),
    );
  }

  void _navigateToUpdateProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateUserProfile(
          userId: user.id,
          user: user,
        ),
      ),
    );
  }

  void _navigateToPurchase(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseRequestScreen(
          userID: user.id,
        ),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingScreen(
          userId: userId,
          user: user,
        ),
      ),
    );
  }

  Future<bool> _checkProfileCompletion() async {
    final prefs = await SharedPreferences.getInstance();

    // First check if profile is explicitly marked as completed
    final isProfileCompleted = prefs.getBool('profileCompleted') ?? false;
    if (isProfileCompleted) return true;

    // Otherwise check each required field individually
    final hasUserName = prefs.getString('userName') != null && prefs.getString('userName')!.isNotEmpty;
    final hasPhones = prefs.getString('phones') != null && prefs.getString('phones')!.isNotEmpty;
    final hasWhatsApp = prefs.getString('watsNumber') != null && prefs.getString('watsNumber')!.isNotEmpty;
    final hasGender = prefs.getString('gender') != null && prefs.getString('gender')!.isNotEmpty;

    // Check both date formats since we have inconsistent naming
    final hasDob = prefs.getString('dob') != null || prefs.getString('dateOfBirth') != null;

    final isComplete = hasUserName && hasPhones && hasWhatsApp && hasGender && hasDob;

    // If all fields are complete, set the profile as completed for future checks
    if (isComplete) {
      await prefs.setBool('profileCompleted', true);
      print('Profile marked as complete based on field check');
    }

    return isComplete;
  }
}