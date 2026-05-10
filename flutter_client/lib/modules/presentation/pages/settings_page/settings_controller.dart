// feito por Gabriel Scolfaro

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_client/core/app_settings.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(
    this._homeController, [
    FirebaseAuth? auth,
    ImagePicker? imagePicker,
  ])  : _auth = auth ?? FirebaseAuth.instance,
        _imagePicker = imagePicker ?? ImagePicker(),
        _firestore = FirebaseFirestore.instance,
        _dio = Dio(BaseOptions(baseUrl: AppSettings.baseUrl));

  final HomeController _homeController;
  final FirebaseAuth _auth;
  final ImagePicker _imagePicker;
  final FirebaseFirestore _firestore;
  final Dio _dio;

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

  /// Busca o nome do usuário na coleção 'users' do Firestore.
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

  /// Abre câmera ou galeria, envia para o back que salva no Firebase Storage.
  /// Atualiza a foto na home imediatamente com os bytes locais.
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
      final bytes = await picked.readAsBytes();
      final base64Image = base64Encode(bytes);

      final token = await currentUser?.getIdToken();

      await _dio.post(
        '/upload-profile-photo',
        data: {'imageBase64': base64Image},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Usa os bytes locais para atualizar a home imediatamente
      // (evita nova chamada de rede e problema de CORS na web)
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


  /// Remove a foto de perfil chamando o backend.
  /// Atualiza a home imediatamente para refletir a mudança (mostrar as iniciais).
  Future<bool> deletePhoto() async {
    final uid = currentUser?.uid;
    if (uid == null) return false;

    isUploadingPhoto = true; //  Loading para a deleção
    notifyListeners();

    try {
      final token = await currentUser?.getIdToken();

      await _dio.delete(
        '/delete-profile-photo',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Limpa os bytes locais para atualizar a home imediatamente para as iniciais
      _homeController.localProfilePhotoBytes = null;
      _homeController.notifyListeners();

      return true;
    } catch (error) {
      debugPrint('SettingsController delete error: $error');
      return false;
    } finally {
      isUploadingPhoto = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    // Reseta todo o estado do HomeController antes do logout —
    // garante que o próximo usuário não veja dados do anterior
    _homeController.reset();
    await _auth.signOut();
  }
}