import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/profile_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/settings.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/theme_page.dart';
import 'package:pixelpal/global/common/list_tile.dart';

class ProfileMenu extends StatelessWidget {
  ProfileMenu({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(user?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(
              child: Text(
                "No data available",
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

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
                      padding: const EdgeInsets.only(
                          top: 10,
                          left: 25.0), // Adjust the left padding as needed
                      child: Image.asset(
                        isLightTheme
                            ? 'assets/images/logo_dark.png'
                            : 'assets/images/logo.png',
                        width: 200, // Adjust the width as needed
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
                          Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.tertiary,
                            size: 96,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['username'],
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontSize: 35,
                                ),
                              ),
                              Container(
                                width: 200, // Adjust width as needed
                                child: Text(
                                  userData['bio'],
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines:
                                      1, // Set the maximum number of lines
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
                      icon: Icons.abc_rounded,
                      text: 'Placeholder',
                      onTap: () {},
                    ),
                    MyListTile(
                      icon: Icons.abc_rounded,
                      text: 'Placeholder',
                      onTap: () {},
                    ),
                    MyListTile(
                      icon: Icons.abc_rounded,
                      text: 'Placeholder',
                      onTap: () {},
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Container(
                    width: 150,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Logout",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          /* return const Center(
            child: CircularProgressIndicator(),
          ); */
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/front');
              break;
            case 1:
              Navigator.pushNamed(context, '/scan');
              break;
            case 2:
              Navigator.pushNamed(context, '/forum');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
