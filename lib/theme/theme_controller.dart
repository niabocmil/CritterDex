import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'app_theme_choice';
  static const _customColorKey = 'app_theme_custom_color';
  static const _customBrightnessKey = 'app_theme_custom_brightness';
  static const _boxColorKey = 'app_theme_box_color';
  static const _shelfColorKey = 'app_theme_shelf_color';

  AppThemeChoice _choice = AppThemeChoice.darkGreen;
  Color _customSeedColor = Colors.teal;
  Brightness _customBrightness = Brightness.light;
  // Null means "use the active theme's derived default" — see
  // shelf_visualization.dart / terrarium_slot.dart.
  Color? _boxColor;
  Color? _shelfColor;

  AppThemeChoice get choice => _choice;
  Color get customSeedColor => _customSeedColor;
  Brightness get customBrightness => _customBrightness;
  Color? get boxColor => _boxColor;
  Color? get shelfColor => _shelfColor;

  ThemeData get themeData {
    if (_choice == AppThemeChoice.custom) {
      final base = ColorScheme.fromSeed(
        seedColor: _customSeedColor,
        brightness: _customBrightness,
      );
      // ColorScheme.fromSeed() remaps the seed into a tonal palette, which
      // visibly darkens (or otherwise shifts) whatever color the user
      // actually picked. Overriding primary/onPrimary with the literal
      // chosen color keeps every primary-colored accent (FAB, buttons,
      // focused inputs, etc.) matching the exact color, while the rest of
      // the scheme still derives its harmonious surfaces from the seed.
      final scheme = base.copyWith(
        primary: _customSeedColor,
        onPrimary: _contrastingOnColor(_customSeedColor),
      );
      return AppTheme.themeForScheme(scheme);
    }
    return AppTheme.themeFor(_choice);
  }

  static Color _contrastingOnColor(Color color) =>
      color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      _choice = AppThemeChoice.fromValue(stored);
    }
    final colorValue = prefs.getInt(_customColorKey);
    if (colorValue != null) {
      _customSeedColor = Color(colorValue);
    }
    final brightnessName = prefs.getString(_customBrightnessKey);
    if (brightnessName != null) {
      _customBrightness =
          brightnessName == 'dark' ? Brightness.dark : Brightness.light;
    }
    final boxColorValue = prefs.getInt(_boxColorKey);
    if (boxColorValue != null) {
      _boxColor = Color(boxColorValue);
    }
    final shelfColorValue = prefs.getInt(_shelfColorKey);
    if (shelfColorValue != null) {
      _shelfColor = Color(shelfColorValue);
    }
    notifyListeners();
  }

  Future<void> setChoice(AppThemeChoice choice) async {
    _choice = choice;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, choice.name);
  }

  Future<void> setCustomScheme(Color seedColor, Brightness brightness) async {
    _customSeedColor = seedColor;
    _customBrightness = brightness;
    _choice = AppThemeChoice.custom;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, AppThemeChoice.custom.name);
    await prefs.setInt(_customColorKey, seedColor.toARGB32());
    await prefs.setString(
        _customBrightnessKey, brightness == Brightness.dark ? 'dark' : 'light');
  }

  Future<void> setBoxColor(Color? color) async {
    _boxColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (color == null) {
      await prefs.remove(_boxColorKey);
    } else {
      await prefs.setInt(_boxColorKey, color.toARGB32());
    }
  }

  Future<void> setShelfColor(Color? color) async {
    _shelfColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (color == null) {
      await prefs.remove(_shelfColorKey);
    } else {
      await prefs.setInt(_shelfColorKey, color.toARGB32());
    }
  }
}
