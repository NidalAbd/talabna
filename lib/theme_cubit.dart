import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(AppTheme.lightTheme);

  static const String _themeKey = 'selected_theme';

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeKey) ?? 0;

    if (themeModeIndex == 1) {
      emit(AppTheme.darkTheme);
    } else {
      emit(AppTheme.lightTheme);
    }
  }

  void toggleTheme() async {
    if (state == AppTheme.lightTheme) {
      await _saveThemePreference(1);
      emit(AppTheme.darkTheme);
      _setSystemBarsColors(AppTheme.darkTheme);
    } else {
      await _saveThemePreference(0);
      emit(AppTheme.lightTheme);
      _setSystemBarsColors(AppTheme.lightTheme);
    }
  }

  void _setSystemBarsColors(ThemeData theme) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: theme.primaryColor, // Set status bar color
      systemNavigationBarColor: theme.primaryColor, // Set navigation bar color
      systemNavigationBarIconBrightness:
      theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
    ));
  }


  Future<void> _saveThemePreference(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, value);
  }
}
