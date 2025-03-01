import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/profile/change_email_screen.dart';
import 'package:talbna/screens/profile/change_password_screen.dart';
import 'package:talbna/utils/restart_helper.dart';
import 'package:talbna/screens/interaction_widget/logout_list_tile.dart';
import 'package:talbna/screens/interaction_widget/theme_toggle.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../blocs/authentication/authentication_bloc.dart';
import '../../blocs/authentication/authentication_event.dart';
import '../../theme_cubit.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key, required this.userId, required this.user});
  final int userId;
  final User user;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> with SingleTickerProviderStateMixin {
  final Language _language = Language();
  String selectedLanguage = 'en'; // Default to English to avoid null issues
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  final List<String> _languages = [
    'ar',
    'en',
    'Español',
    '中文',
    'हिन्दी',
    'Português',
    'Русский',
    '日本語',
    'Français',
    'Deutsch',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Initialize language asynchronously
    _initializeLanguage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeLanguage() async {
    try {
      final lang = await _language.getLanguage();
      if (mounted) {
        setState(() {
          selectedLanguage = lang;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _animationController.forward();
      }
    }
  }

  Future<void> _showLanguageChangeConfirmationDialog() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            _language.tConfirmChangeText(),
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            _language.tLanguageChangeDescText(),
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                _language.tCancelText(),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => RestartHelper.restartApp(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_language.tConfirmText()),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final backgroundColor = isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  _language.tSelectLanguageText(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _languages.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final language = _languages[index];
                      final isSelected = selectedLanguage == language;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.grey.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            language,
                            style: TextStyle(
                              color: isSelected ? primaryColor : textColor,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: primaryColor)
                              : Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          onTap: () async {
                            SharedPreferences pref = await SharedPreferences.getInstance();
                            await pref.setString('language', language);
                            setState(() {
                              selectedLanguage = language;
                            });
                            Navigator.pop(context);
                            _showLanguageChangeConfirmationDialog();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (iconColor ?? primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (trailing != null)
                  trailing
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.withOpacity(0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Future<void> toggleNotifications(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool currentNotificationStatus = prefs.getBool('notifications_enabled') ?? true;

      // Toggle the notification status
      await prefs.setBool('notifications_enabled', !currentNotificationStatus);

      // Show a snackbar to provide feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              !currentNotificationStatus
                  ? 'Notifications Enabled'
                  : 'Notifications Disabled'
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Handle any errors that might occur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating notifications: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Help Center Function
  Future<void> openHelpCenter(BuildContext context) async {
    // Replace with your actual help center URL
    final Uri helpCenterUrl = Uri.parse('https://www.yourapp.com/help');

    try {
      if (await canLaunchUrl(helpCenterUrl)) {
        await launchUrl(
          helpCenterUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback if URL can't be launched
        _showFallbackHelpDialog(context);
      }
    } catch (e) {
      // Show error if launching fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open Help Center: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Privacy Policy Function
  Future<void> openPrivacyPolicy(BuildContext context) async {
    // Replace with your actual privacy policy URL
    final Uri privacyPolicyUrl = Uri.parse('https://www.yourapp.com/privacy');

    try {
      if (await canLaunchUrl(privacyPolicyUrl)) {
        await launchUrl(
          privacyPolicyUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback if URL can't be launched
        _showFallbackPrivacyPolicyDialog(context);
      }
    } catch (e) {
      // Show error if launching fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open Privacy Policy: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // About App Function
  void showAboutDialog(BuildContext context) {
    // Replace with your app's actual details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Our App'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('App Name: Your App Name'),
                const Text('Version: 1.0.0'),
                const Text('Description: A brief description of your app.'),
                const SizedBox(height: 10),
                const Text(
                  'Developed with passion by Your Company Name',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fallback Help Dialog
  void _showFallbackHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help Center'),
          content: const Text(
            'We are unable to open the help center at the moment. '
                'Please contact our support team at support@yourapp.com',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fallback Privacy Policy Dialog
  void _showFallbackPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Privacy Policy'),
          content: const Text(
            'We are unable to open the privacy policy at the moment. '
                'Please contact our support team at support@yourapp.com for more information.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeToggleButton() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    return Container(
      height: 30,
      width: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: primaryColor.withOpacity(0.1),
      ),
      child: Center(
        child: Icon(
          isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: primaryColor,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final backgroundColor = isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            _language.tSettingsText(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Profile avatar text or fallback
    String avatarText = '';
    if (widget.user.name != null && widget.user.name!.isNotEmpty) {
      avatarText = widget.user.name!.substring(0, 1).toUpperCase();
    } else {
      avatarText = 'U';
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _language.tSettingsText(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      // Avoid using FadeTransition directly on the body
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeInAnimation.value,
            child: child,
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Profile section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: primaryColor.withOpacity(0.2),
                        child: Text(
                          avatarText,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.user.name ?? _language.tUserText(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                _buildSectionTitle(_language.tPreferencesText()),

                _buildSettingCard(
                  icon: Icons.language,
                  title: _language.tChangeLanguageText(),
                  onTap: () => _showLanguageBottomSheet(context),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      selectedLanguage,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // For appearance/theme toggle, use a custom implementation
                _buildSettingCard(
                  icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  title: _language.tAppearanceText(),
                  onTap: () {
                    BlocProvider.of<ThemeCubit>(context).toggleTheme();

                  },
                  trailing: IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      // Implement theme toggle logic here
                    },
                  ),
                ),
                _buildSectionTitle(_language.tAccountText()),

                _buildSettingCard(
                  icon: Icons.email_outlined,
                  title: _language.tChangeEmailText(),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChangeEmailScreen(userId: widget.user.id),
                      ),
                    );
                  },
                ),

                _buildSettingCard(
                  icon: Icons.lock_outline,
                  title: _language.tChangePasswordText(),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(userId: widget.user.id),
                      ),
                    );
                  },
                ),

                _buildSettingCard(
                  icon: Icons.notifications_outlined,
                  title: _language.tNotificationsText(),
                  onTap: () {
                    // Navigate to notifications settings
                  },
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // Handle notification toggle
                    },
                    activeColor: primaryColor,
                  ),
                ),

                _buildSectionTitle(_language.tSupportText()),

                _buildSettingCard(
                  icon: Icons.help_outline,
                  title: _language.tHelpCenterText(),
                  onTap: () {
                    // Navigate to help center
                  },
                ),

                _buildSettingCard(
                  icon: Icons.privacy_tip_outlined,
                  title: _language.tPrivacyPolicyText(),
                  onTap: () {
                    // Navigate to privacy policy
                  },
                ),

                _buildSettingCard(
                  icon: Icons.info_outline,
                  title: _language.tAboutText(),
                  onTap: () {
                    // Navigate to about page
                  },
                ),

                _buildSectionTitle(_language.tOtherText()),

                _buildSettingCard(
                  icon: Icons.logout,
                  title: _language.tLogoutText(),
                  onTap: () {
                    // Show logout confirmation dialog
                    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text(
                          _language.tConfirmLogoutText(),
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(_language.tConfirmLogoutDescText()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              _language.tCancelText(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Dispatch LoggedOut event to the authentication bloc
                              BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());

                              // Close the dialog
                              Navigator.of(context).pop();

                              // Clear any stored credentials or tokens
                              SharedPreferences.getInstance().then((prefs) {
                                prefs.remove('token');
                                prefs.remove('user_id');
                                // Keep language preference but clear other settings
                              });

                              // Navigate to login screen and clear navigation stack
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login', // Your login route
                                    (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(_language.tLogoutText()),
                          ),
                        ],
                      ),
                    );
                  },
                  iconColor: Colors.redAccent,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}