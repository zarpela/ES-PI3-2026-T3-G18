import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<Uint8List?> loadProfilePhoto(String userId) async {
  final file = await _profilePhotoFile(userId);
  if (!await file.exists()) {
    return null;
  }

  try {
    return await file.readAsBytes();
  } catch (_) {
    await clearProfilePhoto(userId);
    return null;
  }
}

Future<Uint8List> saveProfilePhoto(String userId, XFile pickedFile) async {
  final file = await _profilePhotoFile(userId);
  final bytes = await pickedFile.readAsBytes();

  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);

  return bytes;
}

Future<void> clearProfilePhoto(String userId) async {
  final file = await _profilePhotoFile(userId);
  if (await file.exists()) {
    await file.delete();
  }
}

Future<File> _profilePhotoFile(String userId) async {
  final directory = await getApplicationDocumentsDirectory();
  final safeUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  return File('${directory.path}/profile_photo_$safeUserId.jpg');
}
