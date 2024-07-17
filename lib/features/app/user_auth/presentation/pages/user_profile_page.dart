import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  Future<Map<String, dynamic>> _getUserDetails(String userId) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .get();
      if (userDoc.exists) {
        var username = userDoc['username'];
        var profilePic = await _getProfilePic(userId);
        return {
          'username': username,
          'profilePic': profilePic,
        };
      } else {
        return {
          'username': 'Anonymous',
          'profilePic': null,
        };
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return {
        'username': 'Anonymous',
        'profilePic': null,
      };
    }
  }

  Future<Uint8List?> _getProfilePic(String userId) async {
    final storageref = FirebaseStorage.instance.ref().child('profile_pic/');
    final imageref = storageref.child("$userId.jpg");

    try {
      final img = await imageref.getData();
      return img;
    } catch (e) {
      print('Profile picture not found: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserDetails(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
          );
        } else {
          var userDetails = snapshot.data!;
          var profilePic = userDetails['profilePic'];
          var username = userDetails['username'];

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 400.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(username),
                    background: profilePic != null
                        ? ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ).createShader(
                                  Rect.fromLTRB(0, 0, rect.width, rect.height));
                            },
                            blendMode: BlendMode.darken,
                            child: Image.memory(
                              profilePic,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ).createShader(
                                  Rect.fromLTRB(0, 0, rect.width, rect.height));
                            },
                            blendMode: BlendMode.darken,
                            child: Container(
                              color: Colors.grey,
                              child: Center(
                                child: Icon(
                                  FontAwesomeIcons.user,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  size: 100,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Username: $username',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 70,
                            ),
                          ),
                          Text(
                            'Username: $username',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 70,
                            ),
                          ),
                          Text(
                            'Username: $username',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 70,
                            ),
                          ),
                          Text(
                            'Username: $username',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 70,
                            ),
                          ),
                          Text(
                            'Username: $username',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 70,
                            ),
                          ),
                          Text(
                            'Username: $username',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 70,
                            ),
                          ),
                          // Add other user details here as needed
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
