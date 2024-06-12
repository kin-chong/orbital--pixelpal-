import 'package:flutter/material.dart';
import 'package:pixelpal/global/common/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = darkMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void setLightMode() {
    _themeData = lightMode;
    notifyListeners();
  }

  void setDarkMode() {
    _themeData = darkMode;
    notifyListeners();
  }
}
