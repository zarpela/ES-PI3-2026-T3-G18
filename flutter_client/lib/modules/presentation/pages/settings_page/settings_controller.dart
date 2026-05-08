// feito por Gabriel Scolfaro

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(
    this._homeController, [
    FirebaseAuth? auth,
    ImagePicker? imagePicker,
  ])  : _auth = auth ?? FirebaseAuth.instance,
        _imagePicker = imagePicker ?? ImagePicker(),
        _storage = FirebaseStorage.instance,
        _firestore = FirebaseFirestore.instance;

  final HomeController _homeController;
  final FirebaseAuth _auth;
  final ImagePicker _imagePicker;
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;

  bool isUploadingPhoto = false;
  String? _firestoreName;

  User? get currentUser => _auth.currentUser;

  String get userLabel {
    if (_firestoreName != null && _firestoreName!.isNotEmpty) {
      return _firestoreName!;
    }
    return _homeController.userLabel;
  }

  String get userInitials {
    final parts = userLabel
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'MI';
    if (parts.length == 1) {
      final first = parts.first.toUpperCase();
      return first.length >= 2 ? first.substring(0, 2) : first;
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  ImageProvider? get profileImage => _homeController.profileImage;

  Future<void> loadUserName() async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final nome = doc.data()?['nome'] as String?;
      if (nome != null && nome.trim().isNotEmpty) {
        _firestoreName = nome.trim();
        notifyListeners();
      }
    } catch (error) {
      debugPrint('SettingsController loadUserName error: $error');
    }
  }

  Future<bool> pickAndUploadPhoto(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (picked == null) return false;

    final uid = currentUser?.uid;
    if (uid == null) return false;

    isUploadingPhoto = true;
    notifyListeners();

    try {
      // Lê os bytes diretamente — funciona em todas as plataformas (mobile e web)
      final bytes = await picked.readAsBytes();

      final ref = _storage.ref().child('profile_pictures/$uid.jpg');
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();

      await currentUser?.updatePhotoURL(url);
      await _auth.currentUser?.reload();

      // Atualiza a foto na home imediatamente sem precisar recarregar
      _homeController.localProfilePhotoBytes = bytes;
      _homeController.notifyListeners();

      return true;
    } catch (error) {
      debugPrint('SettingsController upload error: $error');
      return false;
    } finally {
      isUploadingPhoto = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}