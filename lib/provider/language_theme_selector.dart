import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/language.dart';
import '../../theme_cubit.dart';
import '../../app_theme.dart';
import '../../main.dart' as main;
import 'language_change_notifier.dart';
import 'package:restart_app/restart_app.dart';

class LanguageThemeSelector extends StatefulWidget {
  final bool showThemeToggle;
  final bool compactMode;
  final Function? onLanguageChanged;
  final Function? onThemeChanged;
  final bool showConfirmationDialog;

  const LanguageThemeSelector({
    super.key,
    this.showThemeToggle = true,
    this.compactMode = false,
    this.onLanguageChanged,
    this.onThemeChanged,
    this.showConfirmationDialog = true,
  });

  @override
  State<LanguageThemeSelector> createState() => _LanguageThemeSelectorState();
}

class _LanguageThemeSelectorState extends State<LanguageThemeSelector> {
  final Language _language = Language();
  String selectedLanguage = 'ar';
  bool isDarkMode = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialSettings();
  }

  Future<void> _loadInitialSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('language');
      final brightness = MediaQuery.of(context).platformBrightness;
      final savedTheme = prefs.getInt('selected_theme');

      setState(() {
        selectedLanguage = savedLanguage ?? 'ar';
        isDarkMode = savedTheme != null
            ? savedTheme == 1
            : brightness == Brightness.dark;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleThemeChange() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = !isDarkMode;
    });

    await prefs.setInt('selected_theme', isDarkMode ? 1 : 0);

    if (isDarkMode) {
      context.read<ThemeCubit>().emit(AppTheme.darkTheme);
      AppTheme.setSystemBarColors(Brightness.dark, AppTheme.darkPrimaryColor, AppTheme.darkPrimaryColor);
    } else {
      context.read<ThemeCubit>().emit(AppTheme.lightTheme);
      AppTheme.setSystemBarColors(Brightness.light, AppTheme.lightPrimaryColor, AppTheme.lightPrimaryColor);
    }

    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!();
    }
  }

// Fix the _updateLanguage method by removing the WelcomeScreen specific code
  Future<void> _updateLanguage(String language) async {
    // If showing confirmation dialog, don't apply changes immediately
    if (widget.showConfirmationDialog) {
      setState(() {
        selectedLanguage = language;
      });
      Navigator.pop(context); // Close the bottom sheet
      _showConfirmationDialog(language);
      return;
    }

    // Otherwise apply changes immediately
    await _applyLanguageChange(language);
  }

  Future<void> _applyLanguageChange(String language) async {
    // Show loading dialog
    _showLoadingDialog();

    try {
      // Wait a brief moment to ensure dialog is visible
      await Future.delayed(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();

      // Update global language variable
      main.language = language;

      // This is critical - make sure the SharedPreferences value is saved properly
      // The issue might be the order of operations or waiting for the write to complete
      await prefs.setString('language', language);
      await _language.setLanguage(language);

      // Debug to verify what's being saved
      print("Language saved to SharedPreferences: $language");
      print("Current Language in Language class: ${_language.getLanguage()}");

      // Force rebuild by updating state
      setState(() {
        selectedLanguage = language;
      });

      // This is critical for refreshing the UI
      LanguageChangeNotifier().notifyLanguageChanged();

      // Trigger a rebuild of the parent by using the callback
      if (widget.onLanguageChanged != null) {
        widget.onLanguageChanged!();
      }

      // Close loading dialog if it's still open
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show restart confirmation dialog
      _showRestartConfirmationDialog();

    } catch (e) {
      print('Error changing language: $e');
      // Close loading dialog if it's still open
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  void _showRestartConfirmationDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            selectedLanguage == 'ar'  // Use the state variable instead of _language.getLanguage()
                ? 'تم تغيير اللغة'
                : 'Language Changed',
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
          ),
          content: Text(
            selectedLanguage == 'ar'  // Use the state variable instead of _language.getLanguage()
                ? 'يجب إعادة تشغيل التطبيق لتطبيق التغييرات. إعادة تشغيل الآن؟'
                : 'The app needs to restart to apply changes. Restart now?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // 1. Get SharedPreferences
                final prefs = await SharedPreferences.getInstance();

                // 2. Debug output current state
                print("=== LANGUAGE DEBUG BEFORE RESTART ===");
                print("selectedLanguage state variable: $selectedLanguage");
                print("_language.getLanguage(): ${_language.getLanguage()}");
                print("SharedPreferences language: ${prefs.getString('language')}");
                print("main.language: ${main.language}");

                // 3. Make triple-sure language is correctly saved

                // 3a. First update the Language class, which should internally update SharedPreferences
                await _language.setLanguage(selectedLanguage);

                // 3b. Directly update SharedPreferences as a safety measure
                await prefs.setString('language', selectedLanguage);

                // 3c. Update the global variable directly too
                main.language = selectedLanguage;

                // 4. Verify all updates
                print("=== LANGUAGE DEBUG AFTER UPDATES ===");
                print("selectedLanguage state variable: $selectedLanguage");
                print("_language.getLanguage(): ${_language.getLanguage()}");
                print("SharedPreferences language: ${prefs.getString('language')}");
                print("main.language: ${main.language}");

                // 5. Allow some time for SharedPreferences to complete writes
                await Future.delayed(const Duration(milliseconds: 500));

                // 6. Restart the app
                print("Restarting app with language: $selectedLanguage");
                Restart.restartApp();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                selectedLanguage == 'ar' ? 'إعادة تشغيل الآن' : 'Restart Now',
              ),
            ),
          ],
        );
      },
    );
  }


  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    _language.getLanguage() == 'ar'
                        ? 'جاري تغيير اللغة...'
                        : 'Changing language...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(String language) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            _language.confirmSettingsText(),
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
          ),
          content: Text(
            _language.confirmSettingsMessageText(),
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: Text(_language.cancelText()),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _applyLanguageChange(language);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(_language.confirmText()),
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

    final Map<String, String> languageOptions = {
      'ar': 'العربية',
      'en': 'English'
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Text(
                _language.tSelectLanguageText(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),

              // Language options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: languageOptions.entries.map((entry) {
                    final isSelected = selectedLanguage == entry.key;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : Colors.grey.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        leading: isSelected
                            ? Icon(Icons.check_circle, color: primaryColor)
                            : Icon(Icons.language, color: Colors.grey),
                        title: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? primaryColor : textColor,
                          ),
                        ),
                        onTap: () async {
                          Navigator.pop(context);

                          // Then update the language
                          await _applyLanguageChange(entry.key);
                          },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Only show confirm button if not showing a confirmation dialog later
              if (!widget.showConfirmationDialog) ...[
                const SizedBox(height: 16),
                // Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDarkMode ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        // Close the bottom sheet
                        Navigator.pop(context);

                        // Notify the parent component to refresh UI with new language
                        if (widget.onLanguageChanged != null) {
                          widget.onLanguageChanged!();
                        }

                        // Force UI to rebuild by notifying listeners
                        LanguageChangeNotifier().notifyLanguageChanged();
                      },
                      child: Text(
                        _language.confirmText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    if (widget.compactMode) {
      return Row(
        children: [
          // Language selector button
          InkWell(
            onTap: () => _showLanguageBottomSheet(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    selectedLanguage == 'ar' ? 'العربية' : 'English',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (widget.showThemeToggle) ...[
            const SizedBox(width: 12),
            // Theme toggle button
            InkWell(
              onTap: _handleThemeChange,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: primaryColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      );
    } else {
      // Full mode (for settings screen)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language selector
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showLanguageBottomSheet(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.language,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _language.tChangeLanguageText(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          selectedLanguage == 'ar' ? 'العربية' : 'English',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Theme toggle
          if (widget.showThemeToggle)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleThemeChange,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _language.changeThemeText(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: isDarkMode,
                          onChanged: (value) => _handleThemeChange(),
                          activeColor: primaryColor,
                          activeTrackColor: primaryColor.withOpacity(0.5),
                          inactiveThumbColor: Colors.grey[400],
                          inactiveTrackColor: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }
  }
}