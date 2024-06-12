import 'package:flutter/material.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Themes"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Light Mode'),
            leading: Icon(Icons.wb_sunny),
            onTap: () {
              // Logic to switch to light mode will go here
            },
          ),
          ListTile(
            title: Text('Dark Mode'),
            leading: Icon(Icons.nights_stay),
            onTap: () {
              // Logic to switch to dark mode will go here
            },
          ),
        ],
      ),
    );
  }
}
