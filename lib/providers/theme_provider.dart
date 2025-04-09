import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(_themes[0].theme) {
    _loadTheme();
  }

  static final List<AppTheme> _themes = [
    AppTheme(
      name: 'Default Green',
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
      ),
    ),
    AppTheme(
      name: 'Ocean Blue',
      theme: ThemeData(
        primaryColor: const Color(0xFF1976D2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
      ),
    ),
    AppTheme(
      name: 'Royal Purple',
      theme: ThemeData(
        primaryColor: const Color(0xFF9C27B0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C27B0),
          brightness: Brightness.light,
        ),
      ),
    ),
    AppTheme(
      name: 'Dark Mode',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
      ),
    ),
  ];

  static List<AppTheme> get themes => _themes;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('selected_theme') ?? 0;
    state = _themes[themeIndex].theme;
  }

  Future<void> setTheme(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_theme', index);
    state = _themes[index].theme;
  }
}

class AppTheme {
  final String name;
  final ThemeData theme;

  AppTheme({
    required this.name,
    required this.theme,
  });
}
