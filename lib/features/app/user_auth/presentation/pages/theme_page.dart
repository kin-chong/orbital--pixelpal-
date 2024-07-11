import 'package:flutter/material.dart';
import 'package:pixelpal/global/common/theme_provider.dart';
import 'package:provider/provider.dart';

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
            title: const Text('Light Mode'),
            leading: const Icon(Icons.wb_sunny),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).setLightMode();
            },
          ),
          ListTile(
            title: const Text('Dark Mode'),
            leading: const Icon(Icons.nights_stay),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).setDarkMode();
            },
          ),
          /* ListTile(
            title: const Text('Light Blue'),
            leading: const Icon(Icons.wb_sunny),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).setlightBlue();
            },
          ), */
          /* ListTile(
            title: const Text('Light Green'),
            leading: const Icon(Icons.wb_sunny),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false)
                  .setlightGreen();
            },
          ), */
        ],
      ),
    );
  }
}
