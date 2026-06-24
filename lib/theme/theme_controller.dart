import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'app_theme_choice';

  AppThemeChoice _choice = AppThemeChoice.darkGreen;
  AppThemeChoice get choice => _choice;
  ThemeData get themeData => AppTheme.themeFor(_choice);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      _choice = AppThemeChoice.fromValue(stored);
      notifyListeners();
    }
  }

  Future<void> setChoice(AppThemeChoice choice) async {
    _choice = choice;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, choice.name);
  }
}
