import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar(
      {required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.home),
          label: 'Home',
          tooltip: 'Home Page',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.qrcode),
          label: 'Scan',
          tooltip: 'Scan Ticket',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.comments),
          label: 'Forum',
          tooltip: 'Forum',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.user),
          label: 'Profile',
          tooltip: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        if (index != currentIndex) {
          onTap(index);
        }
      },
    );
  }
}
