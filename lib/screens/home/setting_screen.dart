import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/home/privacy_policy_screen.dart';
import 'package:talbna/screens/profile/change_email_screen.dart';
import 'package:talbna/screens/profile/change_password_screen.dart';
import 'package:talbna/utils/restart_helper.dart';
import '../../blocs/authentication/authentication_bloc.dart';
import '../../blocs/authentication/authentication_event.dart';
import '../../provider/language_theme_selector.dart';
import 'about_screen.dart';
import 'help_center_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key, required this.userId, required this.user});
  final int userId;
  final User user;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> with SingleTickerProviderStateMixin {
  final Language _language = Language();
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  bool _dataSaverEnabled = false;

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

    // Initialize notification settings asynchronously
    _initializeSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeSettings() async {
    try {
      // Get notification setting
      final notificationStatus = await NotificationService.getNotificationStatus();

      // Get data saver setting
      final dataSaverStatus = await DataSaverService.getDataSaverStatus();

      if (mounted) {
        setState(() {
          _notificationsEnabled = notificationStatus;
          _dataSaverEnabled = dataSaverStatus;
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

  // Handle language change callback
  void _onLanguageChanged() {
    // Force a rebuild of the screen with the new language
    setState(() {
      // No need to clear _welcomeContent as it doesn't exist in this class
    });

    // Restart animation if needed
    _animationController.reset();
    _animationController.forward();

    // Show a confirmation toast/snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _language.getLanguage() == 'ar'
                ? 'تم تغيير اللغة بنجاح'
                : 'Language changed successfully'
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Future<void> _toggleDataSaver() async {
    try {
      // Toggle data saver status
      final newStatus = await DataSaverService.toggleDataSaver();

      setState(() {
        _dataSaverEnabled = newStatus;
      });

      // Show a snackbar to provide feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              newStatus
                  ? _language.getLanguage() == 'ar'
                  ? 'تم تفعيل وضع توفير البيانات'
                  : 'Data Saver Mode Enabled'
                  : _language.getLanguage() == 'ar'
                  ? 'تم تعطيل وضع توفير البيانات'
                  : 'Data Saver Mode Disabled'
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Handle any errors that might occur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_language.getLanguage() == 'ar'
              ? 'خطأ في تحديث وضع توفير البيانات: $e'
              : 'Error updating data saver mode: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleNotifications() async {
    try {
      // Toggle notification status
      final newStatus = await NotificationService.toggleNotifications();

      setState(() {
        _notificationsEnabled = newStatus;
      });

      // Show a snackbar to provide feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              newStatus
                  ? _language.tNotificationsEnabledText()
                  : _language.tNotificationsDisabledText()
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

                // Using the new LanguageThemeSelector widget
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LanguageThemeSelector(
                    compactMode: false,
                    showThemeToggle: true,
                    showConfirmationDialog: true, // Show confirmation before changing
                    onLanguageChanged: _onLanguageChanged,
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
                  onTap: () => _toggleNotifications(),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      _toggleNotifications();
                    },
                    activeColor: primaryColor,
                    activeTrackColor: primaryColor.withOpacity(0.5),
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ),

                _buildSettingCard(
                  icon: Icons.data_saver_on_outlined,
                  title: _language.getLanguage() == 'ar' ? 'وضع توفير البيانات' : 'Data Saver Mode',
                  onTap: () => _toggleDataSaver(),
                  trailing: Switch(
                    value: _dataSaverEnabled,
                    onChanged: (value) {
                      _toggleDataSaver();
                    },
                    activeColor: primaryColor,
                  ),
                ),

                _buildSectionTitle(_language.tSupportText()),

                _buildSettingCard(
                  icon: Icons.help_outline,
                  title: _language.tHelpCenterText(),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HelpCenterScreen(),
                      ),
                    );
                  },
                ),

                _buildSettingCard(
                  icon: Icons.privacy_tip_outlined,
                  title: _language.tPrivacyPolicyText(),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),

                _buildSettingCard(
                  icon: Icons.info_outline,
                  title: _language.tAboutText(),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
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


class NotificationService {
  static const String _notificationsKey = 'notifications_enabled';

  // Get current notification status
  static Future<bool> getNotificationStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Default to true if not set
    return prefs.getBool(_notificationsKey) ?? true;
  }

  // Set notification status
  static Future<bool> setNotificationStatus(bool isEnabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_notificationsKey, isEnabled);
  }

  // Toggle notification status
  static Future<bool> toggleNotifications() async {
    final currentStatus = await getNotificationStatus();
    return await setNotificationStatus(!currentStatus);
  }
}

// Add this method to your NotificationService class
class DataSaverService {
  static const String _dataSaverKey = 'data_saver_enabled';

  // Get current data saver status
  static Future<bool> getDataSaverStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Default to false if not set
    return prefs.getBool(_dataSaverKey) ?? false;
  }

  // Set data saver status
  static Future<bool> setDataSaverStatus(bool isEnabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_dataSaverKey, isEnabled);
  }

  // Toggle data saver status
  static Future<bool> toggleDataSaver() async {
    final currentStatus = await getDataSaverStatus();
    return await setDataSaverStatus(!currentStatus);
  }
}