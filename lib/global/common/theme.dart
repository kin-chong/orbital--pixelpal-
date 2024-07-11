import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade200,
    primary: Colors.grey.shade300,
    secondary: const Color.fromARGB(255, 52, 75, 86),
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
    secondary: const Color.fromARGB(255, 169, 192, 203),
    tertiary: Colors.white,
    onPrimary: Colors.white,
    onPrimaryContainer: Colors.grey.shade300,
    onSecondary: Colors.black,
  ),
);

ThemeData lightBlue = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.lightBlue[100], // Light blue background
  colorScheme: ColorScheme.light(
    primary: Colors.blue, // Primary color
    secondary: Colors.deepPurpleAccent, // Secondary color
    surface: Colors.white, // Surface color
    error: Colors.red, // Error color
    onPrimary: Colors.white, // Text color on primary color
    onSecondary: Colors.white, // Text color on secondary color
    onSurface: Colors.black87, // Text color on surface color
    onError: Colors.white, // Text color on error color
  ),
);

ThemeData lightGreen = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor:
      Colors.lightGreen[100], // Pastel light green background
  colorScheme: ColorScheme.light(
    primary: Colors.green, // Primary color
    secondary: Colors.deepOrangeAccent, // Secondary color
    surface: Colors.lightGreen.shade100, // Surface color
    error: Colors.red, // Error color
    onPrimary: Colors.white, // Text color on primary color
    onSecondary: Colors.white, // Text color on secondary color
    onSurface: Colors.black87, // Text color on surface color
    onError: Colors.white, // Text color on error color
  ),
);
