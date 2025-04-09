import 'package:flutter/material.dart';

class ThemeColors {
  // Green Theme
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color darkGreen = Color(0xFF2E7D32);

  // Orange Theme
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color lightOrange = Color(0xFFFFF3E0);
  static const Color darkOrange = Color(0xFFF57C00);

  // Purple Theme
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color lightPurple = Color(0xFFF3E5F5);
  static const Color darkPurple = Color(0xFF7B1FA2);

  // Blue Theme
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkBlue = Color(0xFF1976D2);

  // Chat Bubble Colors
  static const Color userBubbleColor = Color(0xFFF5F5F5);
  static const Color assistantBubbleColor = Color(0xFFFFFFFF);
}

class AppThemeData {
  final String name;
  final Color primaryColor;
  final Color lightColor;
  final Color darkColor;
  final bool isDark;

  const AppThemeData({
    required this.name,
    required this.primaryColor,
    required this.lightColor,
    required this.darkColor,
    this.isDark = false,
  });
}

final List<AppThemeData> availableThemes = [
  AppThemeData(
    name: 'Green',
    primaryColor: ThemeColors.primaryGreen,
    lightColor: ThemeColors.lightGreen,
    darkColor: ThemeColors.darkGreen,
  ),
  AppThemeData(
    name: 'Orange',
    primaryColor: ThemeColors.primaryOrange,
    lightColor: ThemeColors.lightOrange,
    darkColor: ThemeColors.darkOrange,
  ),
  AppThemeData(
    name: 'Purple',
    primaryColor: ThemeColors.primaryPurple,
    lightColor: ThemeColors.lightPurple,
    darkColor: ThemeColors.darkPurple,
  ),
  AppThemeData(
    name: 'Blue',
    primaryColor: ThemeColors.primaryBlue,
    lightColor: ThemeColors.lightBlue,
    darkColor: ThemeColors.darkBlue,
  ),
  AppThemeData(
    name: 'Dark Green',
    primaryColor: ThemeColors.primaryGreen,
    lightColor: ThemeColors.lightGreen,
    darkColor: ThemeColors.darkGreen,
    isDark: true,
  ),
  AppThemeData(
    name: 'Dark Orange',
    primaryColor: ThemeColors.primaryOrange,
    lightColor: ThemeColors.lightOrange,
    darkColor: ThemeColors.darkOrange,
    isDark: true,
  ),
];

ThemeData getThemeData(AppThemeData themeData) {
  final isDark = themeData.isDark;

  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    primaryColor: themeData.primaryColor,
    scaffoldBackgroundColor: isDark ? const Color(0xFF303030) : Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: themeData.primaryColor,
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: themeData.primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: themeData.primaryColor,
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
      fillColor: isDark ? const Color(0xFF424242) : Colors.grey[100],
      hintStyle: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: themeData.primaryColor, width: 2),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      color: isDark ? const Color(0xFF424242) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
      bodyMedium: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: themeData.primaryColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ),
  );
}
