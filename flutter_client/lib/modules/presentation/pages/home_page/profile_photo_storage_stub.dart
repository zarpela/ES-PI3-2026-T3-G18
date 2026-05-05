import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

Future<Uint8List?> loadProfilePhoto(String userId) async {
  return null;
}

Future<Uint8List> saveProfilePhoto(String userId, XFile pickedFile) {
  return pickedFile.readAsBytes();
}

Future<void> clearProfilePhoto(String userId) async {}
