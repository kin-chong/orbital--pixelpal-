import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
