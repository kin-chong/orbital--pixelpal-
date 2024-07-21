import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pixelpal/global/common/toast.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar(
      {required this.currentIndex, required this.onTap, super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final user = FirebaseAuth.instance.currentUser;

  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    getProfilePic();
  }

  Future<void> getProfilePic() async {
    final storageref = FirebaseStorage.instance.ref().child('profile_pic/');
    final imageref = storageref.child("${user?.uid}.jpg");

    try {
      final img = await imageref.getData();
      if (img == null) {
        return;
      }
      setState(() {
        _image = img;
      });
    } catch (e) {
      // showToast(message: 'Profile picture not found');
    }
  }

  void updateProfilePic(Uint8List? newImage) {
    setState(() {
      _image = newImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.home),
          label: 'Home',
          tooltip: 'Home Page',
        ),
        const BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.qrcode),
          label: 'Scan',
          tooltip: 'Scan Ticket',
        ),
        const BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.newspaper),
          label: 'Forum',
          tooltip: 'Forum',
        ),
        const BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.comment),
          label: 'Chats',
          tooltip: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: _image != null
              ? ClipOval(
                  child: SizedBox(
                    width: 30.0, // Set the desired width
                    height: 30.0, // Set the desired height
                    child: Image.memory(_image!),
                  ),
                )
              : const Icon(FontAwesomeIcons.user),
          label: 'Profile',
          tooltip: 'Profile',
        ),
      ],
      currentIndex: widget.currentIndex,
      onTap: (index) {
        if (index != widget.currentIndex) {
          widget.onTap(index);
        }
      },
    );
  }
}
