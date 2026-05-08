import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Carrega a foto do cache local apenas se a [currentUrl] bater com a URL
/// que foi usada quando o cache foi salvo. Se divergir, o cache é descartado
/// e retorna null para forçar o re-download.
Future<Uint8List?> loadProfilePhoto(String userId, {String? currentUrl}) async {
  final file = await _profilePhotoFile(userId);
  if (!await file.exists()) return null;

  // Valida se o cache ainda é válido comparando a URL salva
  if (currentUrl != null && currentUrl.isNotEmpty) {
    final savedUrl = await _readCachedUrl(userId);
    if (savedUrl != currentUrl) {
      // URL mudou (foto trocada) — invalida cache
      await clearProfilePhoto(userId);
      return null;
    }
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

/// Salva bytes já carregados no cache local, junto com a [sourceUrl] para
/// validação futura (detectar quando a foto do usuário foi trocada).
Future<void> saveProfilePhotoBytes(
  String userId,
  Uint8List bytes, {
  String? sourceUrl,
}) async {
  final file = await _profilePhotoFile(userId);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);

  if (sourceUrl != null && sourceUrl.isNotEmpty) {
    await _writeCachedUrl(userId, sourceUrl);
  }
}

Future<void> clearProfilePhoto(String userId) async {
  final file = await _profilePhotoFile(userId);
  if (await file.exists()) await file.delete();

  final urlFile = await _profilePhotoUrlFile(userId);
  if (await urlFile.exists()) await urlFile.delete();
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Future<File> _profilePhotoFile(String userId) async {
  final dir = await getApplicationDocumentsDirectory();
  final safe = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  return File('${dir.path}/profile_photo_$safe.jpg');
}

Future<File> _profilePhotoUrlFile(String userId) async {
  final dir = await getApplicationDocumentsDirectory();
  final safe = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  return File('${dir.path}/profile_photo_$safe.url');
}

Future<String?> _readCachedUrl(String userId) async {
  try {
    final file = await _profilePhotoUrlFile(userId);
    if (!await file.exists()) return null;
    return (await file.readAsString()).trim();
  } catch (_) {
    return null;
  }
}

Future<void> _writeCachedUrl(String userId, String url) async {
  final file = await _profilePhotoUrlFile(userId);
  await file.parent.create(recursive: true);
  await file.writeAsString(url, flush: true);
}