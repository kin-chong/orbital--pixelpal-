import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade200,
    primary: Colors.grey.shade300,
    secondary: Color.fromARGB(255, 52, 75, 86),
    tertiary: Colors.black,
    onPrimary: Colors.black,
    onPrimaryContainer: Colors.grey.shade700,
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
    onPrimary: Colors.white,
    onPrimaryContainer: Colors.grey.shade300,
    onSecondary: Colors.black,
  ),
);
