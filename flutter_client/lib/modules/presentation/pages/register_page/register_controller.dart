// feito por marcelo
import 'dart:convert';
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
      password.contains(RegExp(r'[A-Z]')) && password.contains(RegExp(r'[a-z]'));

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
      final response = await _dio.post(
        '/api/create-account',
        data: {
          'nome': fullName,
          'telefone': phone,
          'email': email,
          'senha': password,
          'cpf': document,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
        ),
      );

      // Garante que data é um Map, não uma String
      final responseData = response.data is String
          ? jsonDecode(response.data as String)
          : response.data as Map<String, dynamic>;

      if (responseData['ok'] == true) {
        return true;
      } else {
        errorMessage = responseData['error'] ?? 'Erro ao criar conta';
        return false;
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data == null || data is String) {
        errorMessage = 'Erro de conexão';
      } else {
        errorMessage = (data as Map<String, dynamic>)['error'] ?? 'Erro de conexão';
      }
      return false;
    } finally {
      isLoading = false;
    }
  }
}