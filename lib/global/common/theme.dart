import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade200,
    primary: Colors.grey.shade400,
    secondary: Color.fromARGB(255, 52, 75, 86),
    tertiary: Colors.black,
    onSecondary: Colors.white,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.black,
    primary: Colors.grey.shade800,
    secondary: Color.fromARGB(255, 169, 192, 203),
    tertiary: Colors.white,
    onSecondary: Colors.black,
  ),
);
