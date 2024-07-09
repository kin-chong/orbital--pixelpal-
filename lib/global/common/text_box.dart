import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;
  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionName,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              onPressed != null
                  ? IconButton(
                      onPressed: onPressed,
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    )
                  : const SizedBox(
                      width:
                          48.0, // Width of IconButton to keep the layout consistent
                      height: 38.0,
                    ),
            ],
          ),
          Text(
            text,
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          ),
        ],
      ),
    );
  }
}
