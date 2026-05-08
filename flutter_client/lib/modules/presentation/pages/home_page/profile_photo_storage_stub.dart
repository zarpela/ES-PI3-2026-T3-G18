import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

Future<Uint8List?> loadProfilePhoto(String userId, {String? currentUrl}) async {
  return null;
}

Future<Uint8List> saveProfilePhoto(String userId, XFile pickedFile) {
  return pickedFile.readAsBytes();
}

/// Web não persiste localmente — sem cache entre sessões.
Future<void> saveProfilePhotoBytes(
  String userId,
  Uint8List bytes, {
  String? sourceUrl,
}) async {}

Future<void> clearProfilePhoto(String userId) async {}