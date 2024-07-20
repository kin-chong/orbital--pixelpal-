import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/bottom_nav_bar.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/forum_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/front_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/no_animation_page_route.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/profile_menu.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/scan_ticket.dart';
import 'message.dart'; // Import the MessagePage

class ChatOverview extends StatefulWidget {
  const ChatOverview({super.key});

  @override
  State<ChatOverview> createState() => _ChatOverviewState();
}

class _ChatOverviewState extends State<ChatOverview> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> _getChatRooms() async {
    final String currentUserID = _auth.currentUser!.uid;

    QuerySnapshot chatRoomsSnapshot = await _firestore
        .collection('chat_rooms')
        .where('user1', isEqualTo: currentUserID)
        .get();

    QuerySnapshot chatRoomsSnapshot2 = await _firestore
        .collection('chat_rooms')
        .where('user2', isEqualTo: currentUserID)
        .get();

    List<DocumentSnapshot> chatRooms = [];
    chatRooms.addAll(chatRoomsSnapshot.docs);
    chatRooms.addAll(chatRoomsSnapshot2.docs);

    List<Map<String, dynamic>> chatRoomDetails = [];

    for (var chatRoom in chatRooms) {
      Map<String, dynamic> chatRoomData =
          chatRoom.data() as Map<String, dynamic>;
      String otherUserID = chatRoomData['user1'] == currentUserID
          ? chatRoomData['user2']
          : chatRoomData['user1'];

      DocumentSnapshot userSnapshot =
          await _firestore.collection('Users').doc(otherUserID).get();
      String otherUsername = userSnapshot['username'];
      Uint8List? profilePic = await _getProfilePic(otherUserID);

      chatRoomDetails.add({
        'chatRoomID': chatRoom.id,
        'otherUserID': otherUserID,
        'otherUsername': otherUsername,
        'profilePic': profilePic,
      });
    }

    return chatRoomDetails;
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Chats'),
        automaticallyImplyLeading: false,
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
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ScanPage()),
                );
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ForumPage()),
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ChatOverview()),
                );
                break;
              case 4:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ProfileMenu()),
                );
                break;
            }
          }
        },
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No chat rooms available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> chatRoom = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: chatRoom['profilePic'] != null
                          ? ClipOval(
                              child: Image.memory(
                                chatRoom['profilePic'],
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              ),
                            )
                          : Icon(
                              FontAwesomeIcons.user,
                              color: Theme.of(context).colorScheme.tertiary,
                              size: 25,
                            ),
                    ),
                    title: Text(chatRoom['otherUsername']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessagePage(
                            receiverID: chatRoom['otherUserID'],
                            receiverUsername: chatRoom['otherUsername'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
