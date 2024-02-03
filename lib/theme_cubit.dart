import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(AppTheme.darkTheme);

  static const String _themeKey = 'selected_theme';

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeKey) ?? 0;

    if (themeModeIndex == 1) {
      emit(AppTheme.darkTheme);
      AppTheme.setSystemBarColors(Brightness.dark, AppTheme.darkPrimaryColor, AppTheme.darkPrimaryColor);
    } else {
      emit(AppTheme.lightTheme);
      AppTheme.setSystemBarColors(Brightness.light, AppTheme.lightPrimaryColor, AppTheme.lightPrimaryColor);
    }
  }

  void toggleTheme() async {
    if (state == AppTheme.lightTheme) {
      await _saveThemePreference(1);
      emit(AppTheme.darkTheme);
      AppTheme.setSystemBarColors(Brightness.dark, AppTheme.darkPrimaryColor, AppTheme.darkPrimaryColor);
    } else {
      await _saveThemePreference(0);
      emit(AppTheme.lightTheme);
      AppTheme.setSystemBarColors(Brightness.light, AppTheme.lightPrimaryColor, AppTheme.lightPrimaryColor);
    }
  }

  void updateTheme() {
    if (state == AppTheme.lightTheme) {
      AppTheme.setSystemBarColors(Brightness.light, AppTheme.lightPrimaryColor, AppTheme.lightPrimaryColor);
    } else {
      AppTheme.setSystemBarColors(Brightness.dark, AppTheme.darkPrimaryColor, AppTheme.darkPrimaryColor);
    }
  }

  Future<void> _saveThemePreference(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, value);
  }
}
