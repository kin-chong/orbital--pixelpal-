import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/profile_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/settings.dart';
import 'package:pixelpal/global/common/list_tile.dart';

class ProfileMenu extends StatelessWidget {
  ProfileMenu({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(
              child: Text(
                "No data available",
                style: TextStyle(color: Colors.white),
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
                    Image.asset(
                      'images/logo.png', // Path to your logo image
                      width: 500,
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 96,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['username'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                ),
                              ),
                              Text(
                                userData['bio'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    MyListTile(
                      icon: Icons.settings,
                      text: 'Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(),
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
                      color: Color.fromARGB(255, 109, 1, 1),
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
        backgroundColor: Colors.black,
        selectedItemColor: Color.fromARGB(255, 206, 186, 6),
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
