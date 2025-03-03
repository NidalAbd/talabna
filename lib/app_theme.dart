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
  static const Color lightPrimaryColor = Color(0xFFFF6B35);  // Modern Indigo
  static const Color lightSecondaryColor = Color(0xFFFFC107);  // Teal
  static const Color lightBackgroundColor = Color(0xFFF8F9FA);  // Off-white
  static const Color lightTextColor = Color(0xFF000000);  // Pure Black for all text
  static const Color lightDisabledColor = Color(0xFFBDBDBD);  // Light Grey
  static const Color lightErrorColor = Color(0xFFB00020);  // Material Design error red
  static const Color lightIconColor = Color(0xFF000000);  // Black

  // Dark Theme Colors - Keeping these as is since you said dark design is OK
  static const Color darkPrimaryColor = Color(0xFF000000);  // Dark Grey
  static const Color darkSecondaryColor = Color(0xFFFFC107);  // Amber
  static const Color darkBackgroundColor = Color(0xFF1C1C1C);  // Very Dark Grey
  static const Color darkTextColor = Color(0xFFFFFFFF);  // Pure White for all text
  static const Color darkDisabledColor = Color(0xFF393939);  // Darker Grey
  static const Color darkErrorColor = Color(0xFFCF6679);  // Red
  static const Color darkIconColor = Color(0xFFFFFFFF);  // White

  // Light Theme Definition - Modernized
  static final ThemeData lightTheme = ThemeData(
    primaryColor: lightPrimaryColor,
    scaffoldBackgroundColor: Colors.white,  // Changed to pure white for consistency
    cardColor: Colors.white,
    dialogBackgroundColor: lightBackgroundColor,
    dividerColor: Colors.grey.shade200,
    appBarTheme: const AppBarTheme(
      color: Colors.white,  // Pure white for AppBar
      elevation: 0,
      iconTheme: IconThemeData(color: lightIconColor),
      titleTextStyle: TextStyle(
        color: lightTextColor,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white,  // Pure white status bar
        statusBarIconBrightness: Brightness.dark,  // Dark icons for light background
        systemNavigationBarColor: Colors.white,  // Pure white navigation bar
        systemNavigationBarIconBrightness: Brightness.dark,  // Dark icons for light background
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
      bodySmall: TextStyle(fontSize: 12, color: lightTextColor),
      labelSmall: TextStyle(fontSize: 10, color: lightTextColor),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: lightPrimaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: lightPrimaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightPrimaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightPrimaryColor,
        side: const BorderSide(color: lightPrimaryColor),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightErrorColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightDisabledColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: lightTextColor),
      hintStyle: TextStyle(color: lightTextColor.withOpacity(0.6)),
    ),
    tabBarTheme: const TabBarTheme(
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: lightPrimaryColor, width: 3),
      ),
      labelColor: lightPrimaryColor,
      unselectedLabelColor: Colors.grey,
      labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontSize: 16),
    ),
    colorScheme: const ColorScheme.light(
      primary: lightPrimaryColor,
      secondary: lightSecondaryColor,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: lightTextColor,
      onSurface: lightTextColor,
      onError: Colors.white,
      error: lightErrorColor,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Colors.white,
      elevation: 8,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade100,
      disabledColor: Colors.grey.shade200,
      selectedColor: lightPrimaryColor.withOpacity(0.2),
      secondarySelectedColor: lightSecondaryColor.withOpacity(0.2),
      labelStyle: const TextStyle(color: lightTextColor),
      secondaryLabelStyle: const TextStyle(color: lightTextColor),
      brightness: Brightness.light,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: lightPrimaryColor,
      inactiveTrackColor: lightPrimaryColor.withOpacity(0.2),
      thumbColor: lightPrimaryColor,
      overlayColor: lightPrimaryColor.withOpacity(0.2),
      trackHeight: 4,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: lightPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 8,
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      color: lightTextColor,
      selectedColor: lightPrimaryColor,
      fillColor: lightPrimaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      borderWidth: 1,
      borderColor: Colors.grey.shade300,
      selectedBorderColor: lightPrimaryColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) return lightPrimaryColor;
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) return lightPrimaryColor.withOpacity(0.5);
        return Colors.grey.shade300;
      }),
    ),
  );

  // Dark Theme Definition - Keeping as is
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
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: darkPrimaryColor,  // Black status bar
        statusBarIconBrightness: Brightness.light,  // Light icons for dark background
        systemNavigationBarColor: darkPrimaryColor,  // Black navigation bar
        systemNavigationBarIconBrightness: Brightness.light,  // Light icons for dark background
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
      bodySmall: TextStyle(fontSize: 12, color: darkTextColor),
      labelSmall: TextStyle(fontSize: 10, color: darkTextColor),
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
      surface: darkBackgroundColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: darkTextColor,
      onError: Colors.black,
      error: darkErrorColor,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(color: darkPrimaryColor),
  );
}