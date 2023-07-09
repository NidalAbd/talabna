import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_theme.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(AppTheme.lightTheme);

  void toggleTheme() {
    if (state == AppTheme.lightTheme) {
      emit(AppTheme.darkTheme);
    } else {
      emit(AppTheme.lightTheme);
    }
  }
}
