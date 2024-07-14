import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/bottom_nav_bar.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/forum_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/front_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/no_animation_page_route.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/profile_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/scan_ticket.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/settings.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/theme_page.dart';
import 'package:pixelpal/global/common/list_tile.dart';
import 'package:pixelpal/global/common/toast.dart';

class ProfileMenu extends StatefulWidget {
  ProfileMenu({super.key});

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
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

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('User not authenticated')),
      );
    }

    bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(
              child: Text(
                "No data available for user ${user?.uid}",
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          //print('User Data: $userData');

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 25.0),
                      child: Image.asset(
                        isLightTheme
                            ? 'assets/images/logo_dark.png'
                            : 'assets/images/logo.png',
                        width: 200,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          _image != null
                              ? ClipOval(
                                  child: Image.memory(
                                    _image!,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  size: 96,
                                ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 250,
                                child: Text(
                                  userData['username'],
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    fontSize: 35,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(
                                width: 250,
                                child: Text(
                                  userData['bio'],
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    MyListTile(
                      icon: Icons.settings,
                      text: 'Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                    MyListTile(
                      icon: Icons.format_paint,
                      text: 'Themes',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ThemePage(),
                          ),
                        );
                      },
                    ),
                    MyListTile(
                      icon: Icons.local_movies,
                      text: 'Saved Movies',
                      onTap: () {},
                    ),
                    MyListTile(
                      icon: Icons.confirmation_number,
                      text: 'Saved Tickets',
                      onTap: () {},
                    ),
                    MyListTile(
                      icon: Icons.logout,
                      text: 'Logout',
                      textColor: Colors.red,
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index != 3) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: FrontPage()),
                );
              case 1:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ScanPage()),
                );
              case 2:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ForumPage()),
                );
              case 3:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ProfileMenu()),
                );
            }
          }
        },
      ),
    );
  }
}
