import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pixelpal/global/common/utils.dart';

Future<Uint8List?> selectImage(BuildContext context, User? user) async {
  try {
    Uint8List img = await pickImage(context, ImageSource.gallery);
    final storageref = FirebaseStorage.instance.ref().child('profile_pic/');
    final imageref = storageref.child("${user?.uid}.jpg");
    await imageref.putData(img);
    return img;
  } catch (e) {
    print('Error picking image: $e');
    return null;
  }
}
