import 'package:flutter/material.dart';

class FournisseurTheme with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get estSombre => _themeMode == ThemeMode.dark;

  void basculerTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
