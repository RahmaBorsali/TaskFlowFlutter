import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsViewModel extends ChangeNotifier {
  static const String _settingsBoxName = 'settings';
  static const String _localeKey = 'locale';
  static const String _notificationsKey = 'notificationsEnabled';

  Locale _locale = const Locale('fr');
  bool _notificationsEnabled = true;

  SettingsViewModel() {
    _loadSettings();
  }

  Locale get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;

  void setLocale(Locale? locale) {
    if (locale == null) return;
    _locale = locale;
    _saveSetting(_localeKey, locale.languageCode);
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    _saveSetting(_notificationsKey, _notificationsEnabled);
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox(_settingsBoxName);
    final langCode = box.get(_localeKey, defaultValue: 'fr');
    _locale = Locale(langCode);
    _notificationsEnabled = box.get(_notificationsKey, defaultValue: true);
    notifyListeners();
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final box = await Hive.openBox(_settingsBoxName);
    await box.put(key, value);
  }
}
