import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static void setSystemBarColors(
      Brightness brightness, Color statusBarColor, Color navigationBarColor) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: statusBarColor, // Set the status bar color here
      statusBarBrightness:
          brightness, // Set the status bar brightness (light or dark) here
      systemNavigationBarColor:
          navigationBarColor, // Set the navigation bar color here
      systemNavigationBarDividerColor:
          null, // Set the navigation bar divider color here
      systemNavigationBarIconBrightness:
          brightness, // Set the navigation bar icon brightness here
    ));
  }

  static const Color lightPrimaryColor = Color(0xFFFFFFFF);
  static const Color darkPrimaryColor = Color(0xFF181616);
  static Color accentColor = lightPrimaryColor.withRed(255).withGreen(180).withBlue(0); // Set blue to 00
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightForegroundColor = Color(0xFF282828);
  static const Color lightTextColor = Color(0xFF000000);
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color lightDisabledColor = Color(0xFFF5F5F5);
  static const Color darkBackgroundColor = Color(0xFF363636);
  static const Color darkForegroundColor = Colors.white;
  static const Color darkDisabledColor = Color(0xFF6E6E6E);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: lightPrimaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    cardColor: Color.lerp(darkBackgroundColor, Colors.white, 0.50),
    dialogBackgroundColor: lightPrimaryColor,
    bottomAppBarTheme:  const BottomAppBarTheme(color: lightPrimaryColor),
    dividerColor: Colors.grey,
    appBarTheme: AppBarTheme(
      color: lightPrimaryColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: darkPrimaryColor),
      toolbarTextStyle: const TextTheme(
        titleLarge: TextStyle(
          color: lightTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ).bodyMedium,
      titleTextStyle: const TextTheme(
        titleLarge: TextStyle(
          color: lightTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ).titleLarge,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: lightTextColor),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      headlineMedium:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      headlineSmall:  TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      titleMedium:  TextStyle(
        fontSize: 16,
      ),
      titleSmall: TextStyle(fontSize: 14, color: lightTextColor),
      bodyLarge: TextStyle(fontSize: 16, color: lightTextColor),
      bodySmall: TextStyle(fontSize: 12, color: lightTextColor),
      labelSmall:  TextStyle(
          fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5),
    ),
    iconTheme: const IconThemeData(
      color: darkPrimaryColor,
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimaryColor,
      secondary: lightPrimaryColor,
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
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: Color.lerp(darkBackgroundColor, Colors.black, 0.50),
    dialogBackgroundColor: darkPrimaryColor,
    bottomAppBarTheme: const BottomAppBarTheme(color: darkPrimaryColor),
    dividerColor: Colors.grey,
    appBarTheme: AppBarTheme(
      elevation: 0,
      color: darkPrimaryColor,
      iconTheme:  const IconThemeData(color: lightPrimaryColor),
      toolbarTextStyle:  const TextTheme(
        titleLarge: TextStyle(
          color: darkTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ).bodyMedium,
      titleTextStyle:  const TextTheme(
        titleLarge: TextStyle(
          color: darkTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ).titleLarge,
    ),
    textTheme:  const TextTheme(
      titleLarge: TextStyle(
        color: darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: darkTextColor),
      labelLarge:  TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      headlineMedium:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      headlineSmall:  TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      titleMedium:  TextStyle(
        fontSize: 16,
      ),
      titleSmall: TextStyle(fontSize: 14, color: darkTextColor),
      bodyLarge: TextStyle(fontSize: 16, color: darkTextColor),
      bodySmall: TextStyle(fontSize: 12, color: darkTextColor),
      labelSmall: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5),
    ),
    iconTheme:  const IconThemeData(
      color: lightPrimaryColor,
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: darkPrimaryColor,
      secondary: darkPrimaryColor,
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
