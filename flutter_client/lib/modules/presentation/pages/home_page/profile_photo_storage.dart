import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'profile_photo_storage_stub.dart'
    if (dart.library.io) 'profile_photo_storage_io.dart' as impl;

Future<Uint8List?> loadProfilePhoto(String userId) {
  return impl.loadProfilePhoto(userId);
}

Future<Uint8List> saveProfilePhoto(String userId, XFile pickedFile) {
  return impl.saveProfilePhoto(userId, pickedFile);
}

Future<void> clearProfilePhoto(String userId) {
  return impl.clearProfilePhoto(userId);
}
