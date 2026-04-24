import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeBoxName = 'settings';
  static const String _themeKey = 'isDarkMode';
  
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox(_themeBoxName);
    _isDarkMode = box.get(_themeKey, defaultValue: false);
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final box = await Hive.openBox(_themeBoxName);
    await box.put(_themeKey, _isDarkMode);
  }
}
