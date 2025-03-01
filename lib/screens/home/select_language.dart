import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/language.dart';
import '../auth/welcome_screen.dart';
import '../../theme_cubit.dart';
import '../../app_theme.dart';
import '../../main.dart' as main;

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final Language _language = Language();
  final Map<String, String> _languages = {
    'ar': 'العربية',
    'en': 'English',
  };
  String selectedLanguage = '';
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadInitialSettings();
  }

  Future<void> _loadInitialSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language');
    final brightness = MediaQuery.of(context).platformBrightness;
    final savedTheme = prefs.getInt('selected_theme');

    setState(() {
      selectedLanguage = savedLanguage ?? 'ar';
      isDarkMode = savedTheme != null
          ? savedTheme == 1
          : brightness == Brightness.dark;
    });

    if (savedTheme == null) {
      if (isDarkMode) {
        context.read<ThemeCubit>().emit(AppTheme.darkTheme);
      } else {
        context.read<ThemeCubit>().emit(AppTheme.lightTheme);
      }
    }
  }

  Future<void> _handleLanguageAndThemeChange() async {
    final prefs = await SharedPreferences.getInstance();

    // Update global language and save settings
    main.language = selectedLanguage;
    await prefs.setString('language', selectedLanguage);
    await _language.setLanguage(selectedLanguage);
    await prefs.setBool('language_selected', true);
    await prefs.setBool('is_first_time', false);

    // Save theme settings
    await prefs.setInt('selected_theme', isDarkMode ? 1 : 0);

    // Apply theme
    if (isDarkMode) {
      context.read<ThemeCubit>().emit(AppTheme.darkTheme);
      AppTheme.setSystemBarColors(Brightness.dark, AppTheme.darkPrimaryColor, AppTheme.darkPrimaryColor);
    } else {
      context.read<ThemeCubit>().emit(AppTheme.lightTheme);
      AppTheme.setSystemBarColors(Brightness.light, AppTheme.lightPrimaryColor, AppTheme.lightPrimaryColor);
    }

    // Preserve auth info if exists
    final authToken = prefs.getString('auth_token');
    final userId = prefs.getInt('userId');
    if (authToken != null && userId != null) {
      await prefs.setString('auth_token', authToken);
      await prefs.setInt('userId', userId);
    }

    // Navigate to welcome screen
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false,
      );
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            _language.confirmSettingsText(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            _language.confirmSettingsMessageText(),
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(_language.cancelText()),
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
            ),
            ElevatedButton(
              child: Text(_language.confirmText()),
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleLanguageAndThemeChange();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  _language.chooseLanguageText(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                // Language selection
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: _languages.entries.map((entry) {
                      final isSelected = selectedLanguage == entry.key;
                      return _buildSelectionTile(
                        title: entry.value,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            selectedLanguage = entry.key;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
                // Theme selection
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _language.chooseThemeText(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSelectionTile(
                        title: _language.lightModeText(),
                        isSelected: !isDarkMode,
                        icon: Icons.light_mode,
                        onTap: () {
                          setState(() {
                            isDarkMode = false;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildSelectionTile(
                        title: _language.darkModeText(),
                        isSelected: isDarkMode,
                        icon: Icons.dark_mode,
                        onTap: () {
                          setState(() {
                            isDarkMode = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Continue button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _showConfirmationDialog,
                      child: Text(
                        _language.continueText(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionTile({
    required String title,
    required bool isSelected,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    SizedBox(width: 12),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}