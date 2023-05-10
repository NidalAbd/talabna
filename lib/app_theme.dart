import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0B2826);
  static const Color accentColor = Color(0xFFFFB400);
  static const Color lightBackgroundColor = Color(0xFFEFEFEF);
  static const Color lightForegroundColor = Color(0xFF282828);
  static const Color lightDisabledColor = Color(0xFFC4C4C4);
  static const Color darkBackgroundColor = Color(0xFF313131);
  static const Color darkForegroundColor = Color(0xFFFFFFFF);
  static const Color darkDisabledColor = Color(0xFF6E6E6E);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    cardColor: Color.lerp(darkBackgroundColor, Colors.white, 0.50),
    dialogBackgroundColor: lightBackgroundColor,
    bottomAppBarTheme: const BottomAppBarTheme(color: lightBackgroundColor),
    dividerColor: Colors.grey,
    appBarTheme: AppBarTheme(
      color: primaryColor,
      elevation: 0,
      iconTheme:
      const IconThemeData(color: lightBackgroundColor),
      toolbarTextStyle: const TextTheme(
        titleLarge: TextStyle(
          color: lightForegroundColor,
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
        color: lightForegroundColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: lightForegroundColor),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontSize: 16, ),
      titleSmall: TextStyle(fontSize: 14, color: lightForegroundColor),
      bodyLarge: TextStyle(fontSize: 16, color: lightForegroundColor),
      bodySmall: TextStyle(fontSize: 12, color: lightForegroundColor),
      labelSmall:
      TextStyle(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5),
    ),
    iconTheme: const IconThemeData(
      color: lightForegroundColor,
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
    ).copyWith(secondary: accentColor),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: Color.lerp(darkBackgroundColor, Colors.black, 0.50),
    dialogBackgroundColor: darkBackgroundColor,
    bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
    dividerColor: Colors.grey,
    appBarTheme: AppBarTheme(
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
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryColor,
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
