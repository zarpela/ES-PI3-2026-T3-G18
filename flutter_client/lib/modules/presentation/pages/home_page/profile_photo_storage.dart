import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'profile_photo_storage_stub.dart'
    if (dart.library.io) 'profile_photo_storage_io.dart' as impl;

/// [currentUrl] é a photoURL atual do usuário (Firebase Auth).
/// Se divergir da URL salva no cache, o cache é invalidado automaticamente.
Future<Uint8List?> loadProfilePhoto(String userId, {String? currentUrl}) {
  return impl.loadProfilePhoto(userId, currentUrl: currentUrl);
}

Future<Uint8List> saveProfilePhoto(String userId, XFile pickedFile) {
  return impl.saveProfilePhoto(userId, pickedFile);
}

/// [sourceUrl] é a URL de origem dos bytes — usada para validar o cache
/// no próximo load e detectar quando a foto foi trocada.
Future<void> saveProfilePhotoBytes(
  String userId,
  Uint8List bytes, {
  String? sourceUrl,
}) {
  return impl.saveProfilePhotoBytes(userId, bytes, sourceUrl: sourceUrl);
}

Future<void> clearProfilePhoto(String userId) {
  return impl.clearProfilePhoto(userId);
}