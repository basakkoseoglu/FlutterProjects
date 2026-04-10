import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  final String _themeKey = 'theme_mode';
  final String _notifKey = 'notifications_enabled';
  late SharedPreferences _prefs;
  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;

  ThemeViewModel() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final themeString = _prefs.getString(_themeKey);
    if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    _notificationsEnabled = _prefs.getBool(_notifKey) ?? true;
    _initialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (!_initialized) return;
    _themeMode = mode;
    notifyListeners();
    String modeString = 'system';
    if (mode == ThemeMode.light) modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';
    await _prefs.setString(_themeKey, modeString);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    if (!_initialized) return;
    _notificationsEnabled = value;
    notifyListeners();
    await _prefs.setBool(_notifKey, value);
  }
}
