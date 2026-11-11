
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // Uygulama açılırken kayıtlı tercihi oku.
  Future<void> loadTheme() async {
    final savedTheme = await _prefs.getString(_themeKey);

    _themeMode = switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    notifyListeners();
  }

  // Kullanıcının seçtiği temayı kaydet.
  Future<void> setTheme(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);

    _themeMode = mode;
    notifyListeners();
  }
}

// Uygulama genelinde kullanılan tek tema yöneticisi.
final themeService = ThemeService();
