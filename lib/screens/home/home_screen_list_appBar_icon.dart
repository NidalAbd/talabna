import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/home/setting_screen.dart';
import 'package:talbna/screens/profile/profile_screen.dart';
import 'package:talbna/screens/profile/purchase_request_screen.dart';
import 'package:talbna/screens/service_post/create_service_post_form.dart';
import 'package:talbna/screens/service_post/favorite_post_screen.dart';
import '../../utils/constants.dart';
import '../../utils/photo_image_helper.dart';
import '../profile/profile_edit_screen.dart';
import 'notification_alert_widget.dart';

class VertIconAppBar extends StatefulWidget {
  const VertIconAppBar({
    super.key,
    required this.userId,
    required this.user,
    required this.showSubcategoryGridView,
    required this.toggleSubcategoryGridView,
  });

  final int userId;
  final User user;
  final bool showSubcategoryGridView;
  final Future<void> Function({required bool canToggle}) toggleSubcategoryGridView;

  @override
  State<VertIconAppBar> createState() => _VertIconAppBarState();
}

class _VertIconAppBarState extends State<VertIconAppBar> {
  bool _isProfileComplete = false;
  bool _isLoading = true;
  final language = Language();

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
  }

  Future<void> _checkProfileCompletion() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if profile is explicitly marked as completed
    final isProfileCompleted = prefs.getBool('profileCompleted') ?? false;

    if (mounted) {
      setState(() {
        _isProfileComplete = isProfileCompleted;
        _isLoading = false;
      });
    }
  }
  String _getProfileImageUrl(User user) {
    print('is External ${user.photos!.first.isExternal}');
    if (user.photos != null && user.photos!.isNotEmpty) {
      final photo = user.photos!.first;

      if (photo.isExternal == true) {
        return photo.src ?? 'https://via.placeholder.com/150';
      }else {
        return '${Constants.apiBaseUrl}/storage/${photo.src}';
      }
    }

    return 'https://via.placeholder.com/150';
  }
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final iconColor = isDarkMode ? AppTheme.darkIconColor : AppTheme.lightIconColor;
    final disabledColor = isDarkMode ? Colors.grey[700] : Colors.grey[400];

    if (_isLoading) {
      return Row(
        children: [
          SizedBox(width: 32), // Placeholder for add button
          SizedBox(width: 32), // Placeholder for notifications
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey[300],
              child: SizedBox(),
            ),
          ),
          SizedBox(width: 32), // Placeholder for menu
        ],
      );
    }

    return Row(
      children: [
        _buildIconButton(
          context: context,
          icon: Icons.add_circle_outline_rounded,
          color: _isProfileComplete ? primaryColor : disabledColor!,
          onPressed: _isProfileComplete ? () => _handleAddPost(context) : () => _navigateToUpdateProfile(context),
          tooltip: _isProfileComplete ? language.tAddPostText() : language.tUpdateInfoText(),
        ),
        _isProfileComplete
            ? NotificationsAlert(userID: widget.userId)
            : Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.notifications,
            color: disabledColor,
            size: 24,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
          child: GestureDetector(
            onTap: () => _isProfileComplete ? _navigateToProfile(context) : _navigateToUpdateProfile(context),
            child: Hero(
              tag: 'profileAvatar${widget.user.id}',
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey[300],
                backgroundImage: (widget.user.photos?.isNotEmpty ?? false)
                    ? NetworkImage(ProfileImageHelper.getProfileImageUrl(widget.user),)
                    : null,
                child: (widget.user.photos?.isEmpty ?? true)
                    ? Icon(Icons.person, size: 18, color: Colors.grey[700])
                    : null,
              ),
            ),
          ),
        ),
        _buildIconButton(
          context: context,
          icon: Icons.more_vert_rounded,
          color: _isProfileComplete ? iconColor : disabledColor!,
          onPressed: _isProfileComplete ? () => _showMoreOptions(context) : () => _navigateToUpdateProfile(context),
          tooltip: _isProfileComplete ? language.tMoreOptionsText() : language.tUpdateInfoText(),
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

  Future<void> _handleAddPost(BuildContext context) async {
    _navigateToServicePost(context);
  }

  void _navigateToServicePost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicePostFormScreen(userId: widget.userId),
      ),
    );
  }

  Future<void> _showMoreOptions(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;

    _showOptionsBottomSheet(context, backgroundColor, primaryColor, textColor);
  }

  void _showOptionsBottomSheet(
      BuildContext context,
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
                    icon: widget.showSubcategoryGridView ? Icons.list_rounded : Icons.grid_view_rounded,
                    title: language.tSwitchSubcategoryList(),
                    onTap: () async {
                      Navigator.pop(context);
                      await widget.toggleSubcategoryGridView(canToggle: true);
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
          value: widget.showSubcategoryGridView,
          onChanged: (value) async {
            Navigator.pop(context);
            await widget.toggleSubcategoryGridView(canToggle: true);
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

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
            fromUser: widget.userId,
            toUser: widget.userId,
            user: widget.user
        ),
      ),
    );
  }

  void _navigateToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritePostScreen(
          userID: widget.user.id,
          user: widget.user,
        ),
      ),
    );
  }

  void _navigateToUpdateProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateUserProfile(
          userId: widget.user.id,
          user: widget.user,
        ),
      ),
    ).then((_) {
      // Re-check profile completion when returning from profile update screen
      _checkProfileCompletion();
    });
  }

  void _navigateToPurchase(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseRequestScreen(
          userID: widget.user.id,
        ),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingScreen(
          userId: widget.userId,
          user: widget.user,
        ),
      ),
    );
  }
}