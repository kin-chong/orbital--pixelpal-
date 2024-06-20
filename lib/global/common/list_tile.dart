import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function()? onTap;
  const MyListTile(
      {super.key, required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.tertiary,
      ),
      onTap: onTap,
      title: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
      ),
    );
  }
}
