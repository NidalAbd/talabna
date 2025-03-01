import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(AppTheme.darkTheme) {
    loadTheme();
  }

  static const String _themeKey = 'isDarkTheme';
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? true;

      final themeData = _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
      emit(themeData);

      // Force immediate system UI update
      await _updateSystemUIWithDelay();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;
      final newTheme = _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

      // Save preference
      await _saveThemePreference();

      // Emit new theme
      emit(newTheme);

      // Force immediate system UI update with delay
      await _updateSystemUIWithDelay();
    } catch (e) {
      debugPrint('Error toggling theme: $e');
    }
  }

  Future<void> _updateSystemUIWithDelay() async {
    // Initial update
    _updateSystemUI();

    // Add delay and update again to ensure changes are applied
    await Future.delayed(const Duration(milliseconds: 50));
    _updateSystemUI();
  }

  void _updateSystemUI() {
    final brightness = _isDarkMode ? Brightness.dark : Brightness.light;
    final primaryColor = _isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.lightPrimaryColor;
    final backgroundColor = _isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      // Status Bar
      statusBarColor: primaryColor,
      statusBarBrightness: brightness,
      statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,

      // Navigation Bar
      systemNavigationBarColor: primaryColor,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
    ));

    // Also update through AppTheme
    AppTheme.setSystemBarColors(
      brightness,
      primaryColor,
      primaryColor,
    );
  }

  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  // Helper method to get correct colors based on theme
  Color getThemeAwareColor(Color darkColor, Color lightColor) {
    return _isDarkMode ? darkColor : lightColor;
  }
}