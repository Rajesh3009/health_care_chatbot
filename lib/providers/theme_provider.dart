import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(getThemeData(availableThemes[0])) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('selected_theme') ?? 0;
    state = getThemeData(availableThemes[themeIndex]);
  }

  Future<void> setTheme(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_theme', index);
    state = getThemeData(availableThemes[index]);
  }

  List<AppThemeData> getAvailableThemes() => availableThemes;
}

class AppTheme {
  final String name;
  final ThemeData theme;

  AppTheme({
    required this.name,
    required this.theme,
  });
}
