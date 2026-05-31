//feito por marcelo
//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_client/core/app_settings.dart';
import 'package:flutter_client/core/app_session.dart';
import 'package:mobx/mobx.dart';

part 'login_controller.g.dart';

class LoginController = LoginControllerBase with _$LoginController;

abstract class LoginControllerBase with Store {
  LoginControllerBase([
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    Dio? dio,
  ]) : _auth = auth,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _dio = dio ?? Dio(BaseOptions(baseUrl: AppSettings.baseUrl));

  final FirebaseAuth? _auth;
  final FirebaseFirestore _firestore;
  final Dio _dio;

  String? _pendingMfaEmail;

  @observable
  String email = '';

  @observable
  String password = '';

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool obscurePassword = true;

  @action
  void setEmail(String value) => email = value;

  @action
  void setPassword(String value) => password = value;

  @action
  void toggleObscurePassword() => obscurePassword = !obscurePassword;

  @computed
  bool get isFormValid => email.isNotEmpty && password.isNotEmpty;

  FirebaseAuth get auth => _auth ?? FirebaseAuth.instance;
  bool get isAwaitingMfa => _pendingMfaEmail != null;
  String get pendingMfaEmail => _pendingMfaEmail ?? email.trim();

  @action
  Future<bool> login() async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty || password.isEmpty) {
      errorMessage = 'Informe e-mail e senha.';
      return false;
    }

    isLoading = true;
    errorMessage = null;
    _pendingMfaEmail = null;
    AppSession.instance.revokeAccess();

    try {
      await auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      final user = auth.currentUser;
      if (user == null) {
        errorMessage = 'Erro ao fazer login';
        return false;
      }

      final mfaEnabled = await _isMfaEnabledForUser(user.uid);
      if (!mfaEnabled) {
        AppSession.instance.grantAccess();
        return true;
      }

      _pendingMfaEmail = await _requestLoginMfaCode(user);
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential':
          errorMessage = 'E-mail ou senha incorretos';
          break;
        case 'wrong-password':
          errorMessage = 'Senha incorreta';
          break;
        case 'user-disabled':
          errorMessage = 'Usuário desativado';
          break;
        case 'too-many-requests':
          errorMessage = 'Muitas tentativas. Tente novamente mais tarde';
          break;
        default:
          errorMessage = 'Erro ao fazer login';
      }
      return false;
    } on DioException catch (e) {
      await _safeSignOut();
      errorMessage =
          _extractApiMessage(e) ??
          'Não foi possível iniciar a autenticação multifator.';
      return false;
    } catch (_) {
      await _safeSignOut();
      errorMessage = 'Erro ao fazer login';
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<String?> verifyLoginMfaCode(String code) async {
    final trimmedCode = code.trim();
    final user = auth.currentUser;

    if (user == null) {
      return 'Sua sessão expirou. Faça login novamente.';
    }

    if (trimmedCode.length != 6) {
      return 'Digite o código com 6 dígitos.';
    }

    try {
      final token = await user.getIdToken(true);
      await _dio.post(
        'verify-login-mfa',
        data: {'code': trimmedCode},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _pendingMfaEmail = null;
      AppSession.instance.grantAccess();
      return null;
    } on DioException catch (e) {
      return _extractApiMessage(e) ?? 'Não foi possível validar o código.';
    } catch (_) {
      return 'Não foi possível validar o código.';
    }
  }

  Future<String?> resendLoginMfaCode() async {
    final user = auth.currentUser;

    if (user == null) {
      return 'Sua sessão expirou. Faça login novamente.';
    }

    try {
      _pendingMfaEmail = await _requestLoginMfaCode(user);
      return null;
    } on DioException catch (e) {
      return _extractApiMessage(e) ?? 'Não foi possível reenviar o código.';
    } catch (_) {
      return 'Não foi possível reenviar o código.';
    }
  }

  Future<void> cancelPendingMfa() async {
    _pendingMfaEmail = null;
    errorMessage = 'Login cancelado. Faça login novamente para continuar.';
    await _safeSignOut();
  }

  Future<bool> _isMfaEnabledForUser(String uid) async {
    final document = await _firestore.collection('users').doc(uid).get();
    return document.data()?['mfaEnabled'] == true;
  }

  Future<String> _requestLoginMfaCode(User user) async {
    final token = await user.getIdToken(true);
    final response = await _dio.post(
      'request-login-mfa',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};

    return (data['email'] ?? user.email ?? email.trim()).toString();
  }

  String? _extractApiMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final message = map['message'] ?? map['error'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'A solicitação demorou demais. Tente novamente.';
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return 'Não foi possível conectar ao servidor. Verifique a API e tente novamente.';
    }

    return null;
  }

  Future<void> _safeSignOut() async {
    AppSession.instance.revokeAccess();
    await auth.signOut();
  }
}
