// lib/providers/theme_provider.dart
// Robust ThemeProvider: accepts nullable initialMode and defaults to ThemeMode.system.
// Persists selection to SharedPreferences.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode;
  final SharedPreferences prefs;

  /// initialMode can be null (e.g., during hot-reload reassembly),
  /// in which case we default to ThemeMode.system.
  ThemeProvider({
    ThemeMode? initialMode,
    required this.prefs,
  }) : _mode = initialMode ?? ThemeMode.system;

  ThemeMode get mode => _mode;

  /// Set explicit modes
  void setLight() {
    _mode = ThemeMode.light;
    _save('light');
  }

  void setDark() {
    _mode = ThemeMode.dark;
    _save('dark');
  }

  void setSystem() {
    _mode = ThemeMode.system;
    _save('system');
  }

  /// Toggle between dark and light
  void toggleDark() {
    if (_mode == ThemeMode.dark) {
      setLight();
    } else {
      setDark();
    }
  }

  Future<void> _save(String value) async {
    try {
      await prefs.setString('themeMode', value);
    } catch (e) {
      // ignore write errors but still notify so UI updates
    }
    notifyListeners();
  }
}
