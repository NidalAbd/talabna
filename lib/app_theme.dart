import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static void setSystemBarColors(Brightness brightness, Color statusBarColor, Color navigationBarColor) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarBrightness: brightness,
      systemNavigationBarColor: navigationBarColor,
      systemNavigationBarDividerColor: null,
      systemNavigationBarIconBrightness: brightness,
    ));
  }

  // Light Theme Colors
  static const Color lightPrimaryColor = Color(0xFF4A90E2);  // Soft Blue
  static const Color lightSecondaryColor = Color(0xFFF5A623);  // Bright Orange
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);  // White
  static const Color lightTextColor = Color(0xFF333333);  // Dark Grey
  static const Color lightDisabledColor = Color(0xFFBDBDBD);  // Light Grey
  static const Color lightErrorColor = Color(0xFFFF5252);  // Red
  static const Color lightIconColor = Color(0xFF000000);  // Dark Grey

  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFF000000);  // Dark Grey
  static const Color darkSecondaryColor = Color(0xFFFFC107);  // Amber
  static const Color darkBackgroundColor = Color(0xFF2C2C2C);  // Very Dark Grey
  static const Color darkTextColor = Color(0xFFE0E0E0);  // Light Grey
  static const Color darkDisabledColor = Color(0xFF424242);  // Darker Grey
  static const Color darkErrorColor = Color(0xFFCF6679);  // Red
  static const Color darkIconColor = Color(0xFFE0E0E0);  // Light Grey

  // Light Theme Definition
  static final ThemeData lightTheme = ThemeData(
    primaryColor: lightPrimaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    cardColor: Colors.white,
    dialogBackgroundColor: lightBackgroundColor,
    dividerColor: Colors.grey.shade300,
    appBarTheme: const AppBarTheme(
      color: lightPrimaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: lightIconColor),
      titleTextStyle: TextStyle(
        color: lightTextColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: const IconThemeData(color: lightIconColor),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: lightTextColor),
      displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: lightTextColor),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: lightTextColor),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: lightTextColor),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: lightTextColor),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: lightTextColor),
      bodyLarge: TextStyle(fontSize: 16, color: lightTextColor),
      bodyMedium: TextStyle(fontSize: 14, color: lightTextColor),
      titleSmall: TextStyle(fontSize: 14, color: lightTextColor),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: lightTextColor),
      bodySmall: TextStyle(fontSize: 12, color: lightDisabledColor),
      labelSmall: TextStyle(fontSize: 10, color: lightDisabledColor),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: lightPrimaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: lightTextColor, backgroundColor: lightPrimaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightPrimaryColor, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightPrimaryColor, side: const BorderSide(color: lightPrimaryColor),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightPrimaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightErrorColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightDisabledColor),
      ),
    ),
    tabBarTheme: const TabBarTheme(
      indicator: BoxDecoration(
        border: Border(bottom: BorderSide(color: lightSecondaryColor, width: 3)),
      ),
      labelColor: lightPrimaryColor,
      unselectedLabelColor: Colors.grey,
      labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontSize: 16),
    ),
    colorScheme: const ColorScheme.light(
      primary: darkPrimaryColor,
      secondary: lightSecondaryColor,
      background: lightBackgroundColor,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: lightTextColor,
      onBackground: lightTextColor,
      onSurface: lightTextColor,
      onError: Colors.white,
      error: lightErrorColor,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
        color: lightPrimaryColor

    ),

  );

  // Dark Theme Definition
  static final ThemeData darkTheme = ThemeData(
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: Colors.black,
    dialogBackgroundColor: darkPrimaryColor,
    dividerColor: Colors.grey.shade700,
    appBarTheme: const AppBarTheme(
      color: darkPrimaryColor,
      elevation: 0,
      shadowColor: Colors.transparent,  // No shadow color
      iconTheme: IconThemeData(color: darkIconColor),
      titleTextStyle: TextStyle(
        color: darkTextColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: const IconThemeData(color: darkIconColor),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkTextColor),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkTextColor),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkTextColor),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkTextColor),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor),
      bodyLarge: TextStyle(fontSize: 16, color: darkTextColor),
      bodyMedium: TextStyle(fontSize: 14, color: darkTextColor),
      titleSmall: TextStyle(fontSize: 14, color: darkTextColor),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor),
      bodySmall: TextStyle(fontSize: 12, color: darkDisabledColor),
      labelSmall: TextStyle(fontSize: 10, color: darkDisabledColor),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: darkSecondaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: darkSecondaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkSecondaryColor, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkSecondaryColor, side: const BorderSide(color: darkSecondaryColor),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkSecondaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkErrorColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkDisabledColor),
      ),
    ),
    tabBarTheme: TabBarTheme(
      indicator: const BoxDecoration(
        border: Border(bottom: BorderSide(color: darkSecondaryColor, width: 3)),
      ),
      labelColor: darkSecondaryColor,
      unselectedLabelColor: Colors.grey.shade600,
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 16),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: darkSecondaryColor,
      background: darkBackgroundColor,
      surface: darkBackgroundColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: darkTextColor,
      onSurface: darkTextColor,
      onError: Colors.black,
      error: darkErrorColor,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(color: darkPrimaryColor),
  );
}
