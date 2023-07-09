import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {

  static void setSystemBarColors(Brightness brightness, Color statusBarColor, Color navigationBarColor) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: statusBarColor, // Set the status bar color here
      statusBarBrightness: brightness, // Set the status bar brightness (light or dark) here
      systemNavigationBarColor: navigationBarColor, // Set the navigation bar color here
      systemNavigationBarDividerColor: null, // Set the navigation bar divider color here
      systemNavigationBarIconBrightness: brightness, // Set the navigation bar icon brightness here
    ));
  }
  static const Color primaryColor = Color(0xFF1E406C);
  static const Color accentColor = Color(0xFFFFB400);
  static const Color lightBackgroundColor = Color(0xFFF8F6F6);
  static const Color lightForegroundColor = Color(0xFF1B3A62);
  static const Color textColor = Color(0xFF000000);
  static const Color lightDisabledColor = Color(0xFFF5F5F5);
  static const Color darkBackgroundColor = Color(0xFF1E406C);
  static const Color darkForegroundColor = Color(0xFFFFFFFF);
  static const Color darkDisabledColor = Color(0xFF1E406C);


  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    cardColor: Color.lerp(darkBackgroundColor, Colors.white, 0.50),
    dialogBackgroundColor: primaryColor,
    bottomAppBarTheme: const BottomAppBarTheme(color: lightBackgroundColor),
    dividerColor: Colors.grey,
    appBarTheme: AppBarTheme(
      color: primaryColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      toolbarTextStyle: const TextTheme(
        titleLarge: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ).bodyMedium,
      titleTextStyle: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ).titleLarge,
    ),
    textTheme:  const TextTheme(
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: textColor),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontSize: 16, ),
      titleSmall: TextStyle(fontSize: 14, color: textColor),
      bodyLarge: TextStyle(fontSize: 16, color: textColor),
      bodySmall: TextStyle(fontSize: 12, color: textColor),
      labelSmall:
      TextStyle(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5),
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: accentColor,
      background: lightBackgroundColor,
      surface: Colors.white,
      onPrimary: lightForegroundColor,
      onSecondary: lightForegroundColor,
      onBackground: lightForegroundColor,
      onSurface: lightForegroundColor,
      onError: Colors.white,
      error: Colors.redAccent,
    ).copyWith(error: Colors.redAccent).copyWith(secondary: accentColor),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: Color.lerp(darkBackgroundColor, Colors.black, 0.50),
    dialogBackgroundColor: primaryColor,
    bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
    dividerColor: Colors.grey,
    appBarTheme: AppBarTheme(
      elevation: 0,
      color: primaryColor,
      foregroundColor: darkForegroundColor,
      iconTheme: const IconThemeData(color: Colors.white),
      toolbarTextStyle: const TextTheme(
        titleLarge: TextStyle(
          color: darkForegroundColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ).bodyMedium,
      titleTextStyle: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ).titleLarge,
    ),
    textTheme:  const TextTheme(
      titleLarge: TextStyle(
        color: darkForegroundColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: darkForegroundColor),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontSize: 16, ),
      titleSmall: TextStyle(fontSize: 14, color: darkForegroundColor),
      bodyLarge: TextStyle(fontSize: 16, color: darkForegroundColor),
      bodySmall: TextStyle(fontSize: 12, color: darkForegroundColor),
      labelSmall:
       TextStyle(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5),
    ),
    iconTheme: const IconThemeData(
      color: darkForegroundColor,
    ),
    colorScheme:   const ColorScheme(
      brightness: Brightness.dark,
      primary: accentColor,
      secondary: accentColor,
      background: darkBackgroundColor,
      surface: Colors.white,
      onPrimary: darkForegroundColor,
      onSecondary: darkForegroundColor,
      onBackground: darkForegroundColor,
      onSurface: darkForegroundColor,
      onError: Colors.white,
      error: Colors.redAccent,
    ).copyWith(error: Colors.redAccent).copyWith(secondary: accentColor),
  );
}
