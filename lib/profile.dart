import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigationBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.yellow,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: currentIndex,
      onTap: onTap,
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
          icon: Icon(FontAwesomeIcons.cog),
          label: 'Settings',
          tooltip: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.user),
          label: 'Profile',
          tooltip: 'Profile',
        ),
      ],
    );
  }
}
