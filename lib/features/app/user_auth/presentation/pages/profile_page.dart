import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixelpal/global/common/select_image.dart';
import 'package:pixelpal/global/common/text_box.dart';
import 'package:pixelpal/global/common/toast.dart';
import 'package:pixelpal/global/common/utils.dart';

class ProfilePage extends StatefulWidget {
  final ValueChanged<Uint8List?> onProfilePicUpdated;

  const ProfilePage({Key? key, required this.onProfilePicUpdated})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? _image;
  final List<String> _availableGenres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'War',
    'Western'
  ];

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

  final user = FirebaseAuth.instance.currentUser;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Future<void> editField(String field,
      {bool isNumeric = false, List<String>? options}) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: options == null
            ? TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                keyboardType:
                    isNumeric ? TextInputType.number : TextInputType.text,
                decoration: InputDecoration(
                  hintText: "Enter new $field",
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  newValue = value;
                },
              )
            : StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((option) {
                      return CheckboxListTile(
                        title: Text(
                          option,
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: newValue.contains(option),
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected == true) {
                              newValue += '$option, ';
                            } else {
                              newValue = newValue.replaceFirst('$option, ', '');
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
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
      if (isNumeric) {
        await usersCollection
            .doc(user?.uid)
            .update({field: int.parse(newValue)});
      } else {
        await usersCollection.doc(user?.uid).update({field: newValue});
      }
    }
  }

  Future<void> editGender() async {
    String? newGender;
    newGender = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Edit Gender",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RadioListTile<String>(
              title: const Text('Male', style: TextStyle(color: Colors.white)),
              value: 'Male',
              groupValue: newGender,
              onChanged: (value) {
                Navigator.of(context).pop(value);
              },
            ),
            RadioListTile<String>(
              title:
                  const Text('Female', style: TextStyle(color: Colors.white)),
              value: 'Female',
              groupValue: newGender,
              onChanged: (value) {
                Navigator.of(context).pop(value);
              },
            ),
            RadioListTile<String>(
              title: const Text('Non-binary',
                  style: TextStyle(color: Colors.white)),
              value: 'Non-binary',
              groupValue: newGender,
              onChanged: (value) {
                Navigator.of(context).pop(value);
              },
            ),
            RadioListTile<String>(
              title: const Text('Prefer not to say',
                  style: TextStyle(color: Colors.white)),
              value: 'Prefer not to say',
              groupValue: newGender,
              onChanged: (value) {
                Navigator.of(context).pop(value);
              },
            ),
          ],
        ),
      ),
    ) as String;

    if (newGender != null && newGender.isNotEmpty) {
      await usersCollection.doc(user?.uid).update({'gender': newGender});
    }
  }

  Future<void> editMoviePreferences(List<String> initialGenres) async {
    List<String> selectedGenres = List.from(initialGenres);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Edit Movie Preferences",
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _availableGenres.map((genre) {
                return ChoiceChip(
                  label: Text(genre),
                  selected: selectedGenres.contains(genre),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedGenres.add(genre);
                      } else {
                        selectedGenres.remove(genre);
                      }
                    });
                  },
                );
              }).toList(),
            );
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
            onPressed: () => Navigator.of(context).pop(selectedGenres),
          ),
        ],
      ),
    );

    if (selectedGenres.isNotEmpty) {
      await usersCollection
          .doc(user?.uid)
          .update({'moviePreferences': selectedGenres});
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
            final userData = snapshot.data!.data() as Map<String, dynamic>?;

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
                      onPressed: () async {
                        Uint8List? img = await selectImage(context, user);
                        if (img != null) {
                          setState(() {
                            _image = img;
                          });
                          widget.onProfilePicUpdated(img);
                        }
                      },
                      child: Text(
                        'Change Picture',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
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
                  text: userData?['username'] ?? '',
                  sectionName: 'Username',
                  onPressed: () => editField('username'),
                ),
                MyTextBox(
                  text: userData?['bio'] ?? '',
                  sectionName: 'Bio',
                  onPressed: () => editField('bio'),
                ),
                MyTextBox(
                  text: userData?['age']?.toString() ?? '',
                  sectionName: 'Age',
                  onPressed: () => editField('age', isNumeric: true),
                ),
                MyTextBox(
                  text: userData?['gender'] ?? '',
                  sectionName: 'Gender',
                  onPressed: () => editGender(),
                ),
                MyTextBox(
                  text: (userData?['moviePreferences'] as List<dynamic>?)
                          ?.join(', ') ??
                      '',
                  sectionName: 'Movie Preferences',
                  onPressed: () => editMoviePreferences(
                      List<String>.from(userData?['moviePreferences'] ?? [])),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
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
