// feito por marcelo
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';

part 'register_controller.g.dart';

class RegisterController = _RegisterControllerBase with _$RegisterController;

abstract class _RegisterControllerBase with Store {
  final Dio _dio;
  _RegisterControllerBase(this._dio);

  @observable
  String fullName = '';

  @observable
  String phone = '';

  @observable
  String email = '';

  @observable
  String password = '';

  @observable
  String document = '';

  @observable
  bool obscurePassword = true;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  void clearForm() {
    fullName = '';
    phone = '';
    email = '';
    password = '';
    document = '';
    obscurePassword = true;
    errorMessage = null;
  }

  @action
  void setFullName(String value) => fullName = value;

  @action
  void setPhone(String value) => phone = value;

  @action
  void setEmail(String value) => email = value;

  @action
  void setPassword(String value) => password = value;

  @action
  void setDocument(String value) => document = value;

  @action
  void toggleObscurePassword() => obscurePassword = !obscurePassword;

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
  bool get isFormValid =>
      fullName.isNotEmpty &&
      phone.isNotEmpty &&
      email.isNotEmpty &&
      document.isNotEmpty &&
      hasMinLength &&
      hasUpperAndLower &&
      hasNumberOrSymbol;

  @action
  Future<bool> register() async {
    isLoading = true;
    errorMessage = null;

    try {
      await _dio.post(
        'register',
        data: {
          'name': fullName.trim(),
          'telefone': phone.trim(),
          'email': email.trim(),
          'senha': password,
          'cpf': document.trim(),
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return true;
    } on DioException catch (error) {
      errorMessage =
          _extractErrorMessage(error) ?? 'Nao foi possivel criar a conta.';
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
