//feito por marcelo
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';

part 'login_controller.g.dart';

class LoginController = LoginControllerBase with _$LoginController;

abstract class LoginControllerBase with Store {
  final Dio _dio;
  LoginControllerBase(this._dio);

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

  @action
  Future<bool> login() async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty || password.isEmpty) {
      errorMessage = 'Informe e-mail e senha.';
      return false;
    }

    isLoading = true;
    errorMessage = null;

    try {
      await _dio.post(
        'login',
        data: {'email': trimmedEmail, 'senha': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return true;
    } on DioException catch (error) {
      errorMessage =
          _extractErrorMessage(error) ?? 'E-mail ou senha incorretos';
      return false;
    } catch (_) {
      errorMessage = 'Nao foi possivel fazer login agora.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  String? _extractErrorMessage(DioException error) {
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

    return null;
  }
}
