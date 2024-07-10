import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:pixelpal/global/common/toast.dart';

pickImage(BuildContext context, ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );

    if (croppedFile != null) {
      return await croppedFile.readAsBytes();
    } else {
      showToast(message: 'Image cropping cancelled.');
    }
  }
  showToast(message: 'No Image Selected.');
}
