import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function()? onTap;
  final Color? textColor;
  const MyListTile({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Theme.of(context).colorScheme.tertiary,
      ),
      onTap: onTap,
      title: Text(
        text,
        style: TextStyle(
          color: textColor ?? Theme.of(context).colorScheme.tertiary,
        ),
      ),
    );
  }
}
