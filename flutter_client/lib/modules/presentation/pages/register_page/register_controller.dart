//feito por Abdallah
// ignore_for_file: library_private_types_in_public_api
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
      isPhoneValid &&
      email.isNotEmpty &&
      isDocumentValid &&
      hasMinLength &&
      hasUpperAndLower &&
      hasNumberOrSymbol;

  @computed
  bool get isPhoneValid {
    if (phone.isEmpty) return false;

    String numbers = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.startsWith('55') && (numbers.length == 12 || numbers.length == 13)) {
      numbers = numbers.substring(2);
    }

    if (numbers.length != 10 && numbers.length != 11) {
      return false;
    }

    int? ddd = int.tryParse(numbers.substring(0, 2));
    if (ddd == null || ddd < 11) return false;

    if (numbers.length == 11) {
      if (numbers[2] != '9') return false;
    } else {
      if (!['2', '3', '4', '5'].contains(numbers[2])) return false;
    }

    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) return false;

    return true;
  }

  @computed
  bool get isDocumentValid {
    if (document.isEmpty) return false;
    String numbers = document.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length != 11) return false;

    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) return false;

    List<int> digits = numbers.split('').map(int.parse).toList();

    int sum1 = 0;
    for (int i = 0; i < 9; i++) {
      sum1 += digits[i] * (10 - i);
    }
    int calc1 = (sum1 * 10) % 11;
    if (calc1 == 10) calc1 = 0;

    if (calc1 != digits[9]) return false;

    int sum2 = 0;
    for (int i = 0; i < 10; i++) {
      sum2 += digits[i] * (11 - i);
    }
    int calc2 = (sum2 * 10) % 11;
    if (calc2 == 10) calc2 = 0;

    if (calc2 != digits[10]) return false;

    return true;
  }

  @action
  Future<bool> register() async {
    isLoading = true;
    errorMessage = null;

    try {
      await _dio.post(
        'create-account',
        data: {
          'name': fullName.trim(),
          'nome': fullName.trim(),
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
          _extractErrorMessage(error) ?? 'Não foi possível criar a conta.';
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível criar a conta.';
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
