//feito por marcelo
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';

part 'change_password_controller.g.dart';

// ignore: library_private_types_in_public_api
class ChangePasswordController = _ChangePasswordControllerBase
    with _$ChangePasswordController;

abstract class _ChangePasswordControllerBase with Store {
  final Dio _dio;
  _ChangePasswordControllerBase(this._dio);

  @observable
  String password = '';

  @observable
  String confirmPassword = '';

  @observable
  bool obscurePassword = true;

  @observable
  bool obscureConfirmPassword = true;

  @action
  void clearForm() {
    password = '';
    confirmPassword = '';
    obscurePassword = true;
    obscureConfirmPassword = true;
  }

  @action
  void setPassword(String value) {
    password = value;
  }

  @action
  void setConfirmPassword(String value) => confirmPassword = value;

  @action
  void toggleObscurePassword() => obscurePassword = !obscurePassword;

  @action
  void toggleObscureConfirmPassword() =>
      obscureConfirmPassword = !obscureConfirmPassword;

  @computed
  bool get hasMinLength => password.length >= 8;

  @computed
  bool get hasUpperAndLower =>
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[a-z]'));

  @computed
  bool get hasNumberOrSymbol =>
      password.contains(RegExp(r'[0-9]')) ||
      password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  @computed
  bool get passwordsMatch => password.isNotEmpty && password == confirmPassword;

  @computed
  bool get isFormValid =>
      hasMinLength && hasUpperAndLower && hasNumberOrSymbol && passwordsMatch;

  Future<String?> resetPassword({
    required String email,
    required String code,
  }) async {
    try {
      await _dio.post(
        'reset-password',
        data: {
          'email': email.trim(),
          'novaSenha': password,
          'code': code.trim(),
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return null;
    } on DioException catch (error) {
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
        return 'A solicitacao demorou demais. Tente novamente.';
      }

      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown) {
        return 'Nao foi possivel conectar ao servidor. Verifique a API e tente novamente.';
      }

      return 'Nao foi possivel redefinir a senha.';
    } catch (_) {
      return 'Nao foi possivel redefinir a senha.';
    }
  }

  // Feito por Abdallah - RA: 25018711
  Future<String?> changePasswordLoggedIn() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return 'Usuario nao autenticado.';
      }
      await user.updatePassword(password);
      return null;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        return 'Por seguranca, voce precisa fazer login novamente antes de alterar a senha.';
      }
      return error.message ?? 'Nao foi possivel alterar a senha.';
    } catch (_) {
      return 'Nao foi possivel alterar a senha.';
    }
  }
}
