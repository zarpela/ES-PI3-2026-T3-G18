//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class MfaVerificationController extends ChangeNotifier {
  MfaVerificationController(this._dio, [FirebaseAuth? auth])
    : _auth = auth ?? FirebaseAuth.instance;

  final Dio _dio;
  final FirebaseAuth _auth;

  String code = '';
  bool isLoading = false;
  String? errorMessage;

  bool get isCodeValid => code.trim().length == 6;

  void setCode(String value) {
    code = value;
    errorMessage = null;
    notifyListeners();
  }

  Future<String?> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    return user.getIdToken();
  }

  String _parseApiMessage(dynamic data, {required String fallback}) {
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return fallback;
  }

  Future<bool> resendCode() async {
    final token = await _getIdToken();
    if (token == null) {
      errorMessage = 'Sessão expirada. Faça login novamente.';
      notifyListeners();
      return false;
    }

    // Reenvia um novo código para o e-mail (backend gera e substitui o anterior).
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _dio.post(
        '/mfa/request-code',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } on DioException catch (e) {
      errorMessage = _parseApiMessage(
        e.response?.data,
        fallback: 'Não foi possível reenviar o código.',
      );
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível reenviar o código.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyCode() async {
    final token = await _getIdToken();
    if (token == null) {
      errorMessage = 'Sessão expirada. Faça login novamente.';
      notifyListeners();
      return false;
    }

    final normalizedCode = code.trim();
    if (normalizedCode.length != 6) {
      errorMessage = 'Informe o código de 6 dígitos.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Valida o código no backend. Em caso de sucesso, o app libera a navegação
      // para a home; em caso de erro, o backend pode retornar mensagem detalhada.
      await _dio.post(
        '/mfa/verify-code',
        data: {'code': normalizedCode},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } on DioException catch (e) {
      errorMessage = _parseApiMessage(
        e.response?.data,
        fallback: 'Codigo invalido ou expirado.',
      );
      return false;
    } catch (_) {
      errorMessage = 'Codigo invalido ou expirado.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
