import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixelpal/global/common/text_box.dart';
import 'package:pixelpal/global/common/toast.dart';
import 'package:pixelpal/global/common/utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? _image;
  @override
  void initState() {
    super.initState();
    getProfilePic();
  }

  void selectImage() async {
    Uint8List img = await pickImage(context, ImageSource.gallery);
    setState(() {
      _image = img;
    });
    final storageref = FirebaseStorage.instance.ref().child('profile_pic/');
    final imageref = storageref.child("${user?.uid}.jpg");
    await imageref.putData(_image!);
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

  final user = FirebaseAuth.instance.currentUser;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(user?.uid).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                const SizedBox(height: 20),
                Column(
                  children: [
                    _image != null
                        ? Center(
                            child: ClipOval(
                              child: Image.memory(
                                _image!,
                                width: 200,
                                height: 200,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.person,
                              size: 200,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                    SizedBox(height: 5),
                    TextButton(
                      onPressed: selectImage,
                      child: Text(
                        'Change Picture',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
                //const SizedBox(height: 10),
                /* Text(
                  user!.email!,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ), */
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                ),
                MyTextBox(
                  text: user!.email!,
                  sectionName: 'Email',
                  onPressed: null,
                ),
                MyTextBox(
                  text: userData['username'],
                  sectionName: 'Username',
                  onPressed: () => editField('username'),
                ),
                /* MyTextBox(
                  text: user!.email!,
                  sectionName: 'Email',
                  onPressed: () {},
                ), */
                MyTextBox(
                  text: userData['bio'],
                  sectionName: 'Bio',
                  onPressed: () => editField('bio'),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
