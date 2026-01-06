import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);

    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    notifyListeners();
  }

  Future<void> changeTheme(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);

    notifyListeners();
  }
}
