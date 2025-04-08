import 'package:flutter/material.dart';


class ThemeColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color userBubbleColor = Color(0xFFE8F5E9);
  static const Color assistantBubbleColor = Color(0xFF4CAF50);
}

ThemeData getAppTheme({bool isDarkMode = false}) {
  return ThemeData(
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
    primaryColor: ThemeColors.primaryGreen,
    scaffoldBackgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeColors.primaryGreen,
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ThemeColors.primaryGreen,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeColors.primaryGreen,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
      hintStyle: TextStyle(
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.primaryGreen, width: 2),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      color: isDarkMode ? Colors.grey[700] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: const TextStyle(
        color: Colors.black,
      ),
      bodyMedium: const TextStyle(
        color: Colors.black,
      ),
    ),
  );
}
